`define SYNTH
module topv2(
    inout  wire [7:0] dq,
    inout  wire       rwds,
    output reg        csn,
    output wire       ckout,
    output wire       ckoutn,
    output wire       rstn,
    input  wire       refclk
);
	
    wire rwds_in;
    reg  rwds_out;
    reg rwds_oe;
   
    assign rwds_in = rwds;
    assign rwds = rwds_oe ? rwds_out : 'bZ;

    // Buffer for shifting data (3 words)
    reg  [15:0] buffer_out [0:18]; //32 bytes burst buffer
    // Data signals
    wire [15:0] dataout;
    reg  [15:0] dataout_reg [0:2];
    wire [15:0] regdata;
    reg  [15:0] regdatar;
    reg datavalid;

    // State machine for hyperram register read
    typedef enum logic [3:0] {
        HR_IDLE,  // HyperRam register read request
        SET_CA,
        RD_REG0,   // Data read and chip-select de-assertion delay
        RD_REG1,   // Data read and chip-select de-assertion delay
        WR_REG0,     // Read register capture state
        MEM_WR0,
        MEM_WR1,
        MEM_RD0,
        MEM_RD1
    } state_t;
    state_t state;

    state_t next_state;

    // Other control signals
    reg  oe,clken;           // Output enable for dq interface
    wire regr,regw;         // Trigger signal for starting a register read (drive externally)
    reg  prev_regr,prev_regw, prev_memw, prev_memr;
    reg  regr_done;
    wire memr,memw;
    reg [5:0] counter;  // Counter for delay in RD_REG0 state
    wire [47:0] CA_sig;
    reg  [47:0] CA_sigr [2:0];
	 
	 wire [3:0] latency;
	 reg  [3:0] latencyr;

     `ifdef SIM
		reg rst,memrst;
	 `else
		
		wire clk, rst,memrst, lock;
        altsource_probe_top #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             ("NONE"),
            .probe_width             (17),
            .source_width            (6),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
        ) sp_inst (
            .source     ({memr,memw,regr,regw,memrst,rst}), // sources.source
            .probe      ({datavalid,captured_data}),  //  probes.probe
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
		  

	 `endif

    wire clk90;
     pll2	pll2_inst (
        .areset ( rst ),
        .inclk0 ( refclk ),
        .c0 ( clk ),
        .c1 (clk90),
        .locked ( lock )
	);
    
    reg [2:0] rwr_counter;
    reg       rwr_stall;
    reg       rwr_clear;
    reg prev_csn_d0,prev_csn_d1;
    reg [15:0] captured_data;

    

    //this block handle rwr delay. always track csn and start counting to clear stall reg.
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            prev_csn_d0 <= 0;
            prev_csn_d1 <= 0;
            rwr_counter <= 0;
            rwr_stall   <= 0;
            regdatar    <= 0;
            CA_sigr[0]     <= 0;
            CA_sigr[1]     <= 0;
            CA_sigr[2]     <= 0;
				latencyr		<= 0;
        end else begin
            prev_csn_d1 <= prev_csn_d0;
            prev_csn_d0 <= csn;
            regdatar    <= regdata;
            CA_sigr[0]     <= CA_sigr[1];
            CA_sigr[1]     <= CA_sigr[2];
            CA_sigr[2]     <= CA_sig;
				latencyr		<= latency;
            if (!prev_csn_d1 && prev_csn_d0) begin
                rwr_counter <= 7;
            end else if(rwr_counter == 0) begin
                rwr_stall <= 0;
            end else begin
                rwr_stall <= 1;
                rwr_counter <= rwr_counter - 1;
            end 
        end
    end

    assign ckout = clken ? clk : 1'b0;
    assign ckoutn = clken ? ~clk : 1'b0;

    // Hyperram reset is tied high (active high reset input to hyperram)
    assign rstn = !memrst;

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


    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= HR_IDLE;
            csn   <= 0;
            regr_done <= 0;
            oe <= 0;
            clken <= 0;
            counter <= 0;
            prev_regw <= 0;
            prev_regr <= 0;
            dataout_reg[0] <= 0;
            dataout_reg[1] <= 0;
            dataout_reg[2] <= 0;
            captured_data <= 0;
            datavalid <= 0;
            for (int i = 0;i< 16 ;i++ ) begin
                buffer_out[i] <= 0;
            end
        end else begin
            prev_regw <= regw;
            prev_regr <= regr;
            prev_memw <= memw;
            prev_memr <= memr;
            case (state)
                HR_IDLE: begin
                    csn    <= 1'b1;  // Activate chip-select
                    buffer_out[0] <= CA_sigr[0][47:32];
                    buffer_out[1] <= CA_sigr[0][31:16];
                    buffer_out[2] <= CA_sigr[0][15:0];

                    if ((regr && !prev_regr) && !rwr_stall) begin
                        state <= RD_REG0;
                        csn    <= 1'b0;  // Activate chip-select
                        oe       <= 1'b0;
                        clken <= 1'b0;
                        counter <= 0;
                        
                    end 

                    if ((memw && !prev_memw) && !rwr_stall) begin
                        state <= MEM_WR0;
                        csn    <= 1'b0;  // Activate chip-select
                        oe       <= 1'b0;
                        clken <= 1'b0;
                        counter <= 0;
                        // for (int i = 3; i < 19 ; i++) begin
                        //     buffer_out[i] <= i - 3;
                        // end
                        buffer_out[3] <= 'habcd;
                        buffer_out[4] <= 'h1234;
                        buffer_out[5] <= 'ha515;
                        buffer_out[6] <= 'hbab1;

                        buffer_out[7] <= 'hdead;
                        buffer_out[8] <= 'hfa11;
                        buffer_out[9] <= 'h7373;
                        buffer_out[10] <= 'h8811;

                        buffer_out[11] <= 'h8181;
                        buffer_out[12] <= 'habab;
                        buffer_out[13] <= 'hbaba;
                        buffer_out[14] <= 'hc1c1;

                        buffer_out[15] <= 'hdeda;
                        buffer_out[16] <= 'hdada;
                        buffer_out[17] <= 'hf3d1;
                        buffer_out[18] <= 'h9092;
                    end 

                    if ((memr && !prev_memr) && !rwr_stall) begin
                        state <= MEM_RD0;
                        csn    <= 1'b0;  // Activate chip-select
                        oe       <= 1'b0;
                        clken <= 1'b0;
                        counter <= 0;
                    end 
                   
                end
                RD_REG0: begin
                    if (counter == 4) begin
                        state <= RD_REG1;
                        counter <= 0;
                        oe       <= 1'b0;
                    end else if (counter > 0 && counter < 4) begin
                        buffer_out[0] <= buffer_out[1];
                        buffer_out[1] <= buffer_out[2];
                        buffer_out[2] <= 16'h0000;
                        oe       <= 1'b1;
                        clken <= 1'b1;
                        counter <= counter + 1;
                        
                    end else if (rwds_in) begin
                        counter <= 1;
                        oe       <= 1'b1;
                        clken <= 1'b0;
                    end
                end
                RD_REG1: begin
                    if (counter == 16) begin
                        state <= HR_IDLE;
                        counter <= 0;
								csn    <= 1'b1;
								clken <= 1'b0;
                    end else if (counter > 12 && counter < 16) begin
                        counter = counter + 1;
                        dataout_reg[0] <= dataout_reg[1];
                        dataout_reg[1] <= dataout_reg[2];
                        dataout_reg[2] <= dataout;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                MEM_WR0: begin
					 if (counter == 4) begin
                        state <= MEM_WR1;
                        counter <= 0;
                        oe       <= 1'b0;
                    end else if (counter > 0 && counter < 4) begin
                        for (int i = 0;i< 18 ;i++ ) begin
                            buffer_out[i] <= buffer_out[i+1];
                        end
                        buffer_out[18] <= 'h0;
                        
                        oe       <= 1'b1;
                        clken <= 1'b1;
                        counter <= counter + 1;
                        
                    end else if (rwds_in) begin
                        counter <= 1;
                        oe       <= 1'b1;
                        clken <= 1'b0;
                    end
                end
                MEM_WR1: begin
                    if (counter == 28) begin
                        state <= HR_IDLE;
                        counter <= 0;
                        csn    <= 1'b1;
                        oe       <= 1'b0;
                        clken <= 1'b0;
                        rwds_oe  <= 1'b0;
                    end else if (counter > 12 && counter < 28) begin
                        for (int i = 0;i< 18 ;i++ ) begin
                            buffer_out[i] <= buffer_out[i+1];
                        end
                        
                        buffer_out[18] <= 'h0;
                        counter = counter + 1;
                        oe       <= 1'b1;
                        clken <= 1'b1;
                        rwds_out <= 1'b0;
                        rwds_oe  <= 1'b1;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                MEM_RD0: begin
					if (counter == 4) begin
                        state <= MEM_RD1;
                        counter <= 0;
                        oe       <= 1'b0;
                    end else if (counter > 0 && counter < 4) begin
                        buffer_out[0] <= buffer_out[1];
                        buffer_out[1] <= buffer_out[2];
                        buffer_out[2] <= 16'h0000;
                        oe       <= 1'b1;
                        clken <= 1'b1;
                        counter <= counter + 1;
                        
                    end else if (rwds_in) begin
                        counter <= 1;
                        oe       <= 1'b1;
                        clken <= 1'b0;
                    end
                end
                MEM_RD1: begin
                    dataout_reg[0] <= dataout_reg[1];
                    dataout_reg[1] <= dataout_reg[2];
                    dataout_reg[2] <= dataout;
                    counter <= counter + 1;
                    if (counter == 32) begin
                        state <= HR_IDLE;
                        counter <= 0;
                        csn    <= 1'b1;
                        clken <= 1'b0;
                        captured_data <= 0;
                        datavalid <= 0;

                    end else if (counter > 17) begin
                        captured_data <= dataout_reg[0];
                        datavalid <= 1;
                    end else begin
                        datavalid <= 0;
                        captured_data <= 0;
                    end
                end
                default: 
						state <= HR_IDLE;
            endcase

        end
    end

    

endmodule

