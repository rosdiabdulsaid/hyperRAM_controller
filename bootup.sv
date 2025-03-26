module bootup(
    inout  wire [7:0] dq,
    inout  wire       rwds,
    output reg        CSNeg,
    output wire       CK,
    output wire       RESETNeg,
    input  wire       refclk
    // input  wire       rst
);

    wire clk, clk90, rst, lock;

    pll2	pll2_inst (
        .areset ( rst ),
        .inclk0 ( refclk ),
        .c0 ( clk ),
        .c1 ( clk90 ),
        .locked ( lock )
	);

//    assign rst = !lock;

    // Data signals
    wire [15:0] dataout;
    reg  [15:0] dataout_reg;
    wire [15:0] regdata;

    // Buffer for shifting data (3 words)
    reg [15:0] buffer_out [0:15]; //32 bytes burst buffer

    // State machine for hyperram register read
    typedef enum logic [3:0] {
        HR_IDLE,  // HyperRam register read request
        SET_CA,
        RD_REG0,   // Data read and chip-select de-assertion delay
        WR_REG0,     // Read register capture state
        MEM_WR0,
        MEM_WR1,
        MEM_RD0,
        MEM_RD1
    } state_t;
    state_t state;

    // Other control signals
    reg oe;           // Output enable for dq interface
    wire regr,regw;         // Trigger signal for starting a register read (drive externally)
    wire memr,memw;
    wire memrst;
    reg [4:0] counter;  // Counter for delay in RD_REG0 state
	 wire [47:0] CA_sig;

    // reg clock;
    // initial begin
    //     clock =0;
    //     #1.5 
    //     forever #3 clock = ~clock;
    // end

    // Chip select clock enable: when chip is selected (CSNeg low) then enable clock
    wire clken = (CSNeg == 1'b0) ? 1'b1 : 1'b0;
    assign CK = clken ? clk : 1'b0;

    // Hyperram reset is tied high (active high reset input to hyperram)
    assign RESETNeg = !memrst;

    // dq module instance: interfaces with the hyperram I/O
    dq dq_inst (
        .datain_h   (buffer_out[0][15:8]),
        .datain_l   (buffer_out[0][7:0]),
        .inclock    (rwds),
        .oe         (oe),
        .outclock   (clk),   // Using external clock instead of a simulation-generated clock
        .dataout_h  (dataout[15:8]),
        .dataout_l  (dataout[7:0]),
        .padio      (dq)
    );

    altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (16),
		.source_width            (5),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
    ) sp_inst (
		.source     ({memr,memw,regr,regw,memrst,rst}), // sources.source
		.probe      (dataout_reg),  //  probes.probe
		.source_ena (1'b1)    // (terminated)
	);
	
	altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (0),
		.source_width            (48),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
    ) ca_input_inst (
		.source     (CA_sig), // sources.source
		.source_ena (1'b1)    // (terminated)
	);

    altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (0),
		.source_width            (16),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
    ) regdata_inst (
		.source     (regdata), // sources.source
		.source_ena (1'b1)    // (terminated)
	);

    reg prev_regw;
    reg prev_regr;
    // Synchronous state machine and control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset state: initialize registers and buffer
            state     <= HR_IDLE;
            CSNeg        <= 1'b0;
            counter      <= 4'd0;
            oe           <= 1'b0;
            dataout_reg  <= 16'd0;
            prev_regw   <= 1'b0;
            prev_regr   <= 1'b0;
            for (int i = 0;i<16 ;i++ ) begin
                buffer_out[i] <= 16'd0;
            end
        end else begin
            prev_regw <= regw;
            case (state)
                HR_IDLE: begin
                    // Assert chip-select inactive until regr is received
                    CSNeg <= 1'b1;
                    
                    if ((regr && !prev_regr)||memw||memr) begin
                        state <= SET_CA;
                        CSNeg    <= 1'b0;  // Activate chip-select
                        oe       <= 1'b1;
                        buffer_out[0] <= CA_sig[47:32];
                        buffer_out[1] <= CA_sig[31:16];
                        buffer_out[2] <= CA_sig[15:0];
                    end

                    if(regw && !prev_regw) begin 
                        state <= WR_REG0;
                        CSNeg    <= 1'b0;  // Activate chip-select
                        oe       <= 1'b1;
                        buffer_out[0] <= CA_sig[47:32];
                        buffer_out[1] <= CA_sig[31:16];
                        buffer_out[2] <= CA_sig[15:0];
                        buffer_out[3] <= regdata[15:0];
                    end
                end
                SET_CA: begin
                    if (counter == 4'd3) begin
                        if (regr) begin
                            state <= RD_REG0;
                        end else if(memw) begin
                            state <= MEM_WR0;
                        end else if(memr) begin
                            state <= MEM_RD0;
                        end
                        
                        counter  <= 4'd0;
                        oe       <= 1'b0;
                    end else begin
                        // Shift the buffer left: move element [1] to [0] and [2] to [1]
                        buffer_out[0] <= buffer_out[1];
                        buffer_out[1] <= buffer_out[2];
                        // Load a default value into the last element (avoid X's for synthesis)
                        buffer_out[2] <= 16'h0000;
                        counter <= counter + 1;
                    end
                    CSNeg <= 1'b0;
                end
                MEM_RD0: begin
                    if (counter == 5'd15) begin
                        counter  <= 4'd0;
                        state <= HR_IDLE;
                        // Capture the output data from hyperram
                        dataout_reg <= dataout;
                    end else begin
                        counter <= counter + 1;
                    end
                    
                end
                WR_REG0: begin
                    if (counter == 5'd5) begin
                        counter  <= 4'd0;
                        oe       <= 1'b0;
                        state <= HR_IDLE;
                    end else begin
                        // Shift the buffer left: move element [1] to [0] and [2] to [1]
                        buffer_out[0] <= buffer_out[1];
                        buffer_out[1] <= buffer_out[2];
                        buffer_out[2] <= buffer_out[3];
                        // Load a default value into the last element (avoid X's for synthesis)
                        buffer_out[3] <= 16'h0000;
                        counter <= counter + 1;
                    end
                    CSNeg <= 1'b0;
                end
                RD_REG0: begin
                    if (counter == 5'd15) begin
                        counter  <= 4'd0;
                        state <= HR_IDLE;
                        // Capture the output data from hyperram
                        dataout_reg <= dataout;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                default: begin
                    state <= HR_IDLE;
                end
            endcase
        end
    end

endmodule