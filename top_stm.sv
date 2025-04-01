`define DEBUG
module top_stm(
    input wire clk,  
    input wire rst,

    output wire oe_data,
    output wire oe_clk,
    output wire csn,
    input  wire rwds_in,
    output reg  rwds_out,
    output reg  rwds_oe,
    output wire [15:0] datain,
    input  wire [15:0] dataout,

    input  wire [9:0]  csr_address,
    input  wire        csr_read,
    input  wire        csr_write,
    output wire [31:0] csr_readdata,
    output wire        csr_readdatavalid,
    input  wire [31:0] csr_writedata,
    input  wire        csr_waitrequest



);


    typedef enum logic [3:0] {
        IDLE,
        RDREG,
        WRREG,
        RDMEM,
        WRMEM
    } top_state;

    top_state state;
    reg regr,regw;

    `ifdef DEBUG
        wire memr,memw;
        altsource_probe_top #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             ("NONE"),
            .probe_width             (0),
            .source_width            (2),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
        ) control_inst (
            .source     ({memr,memw}), // sources.source
            .source_ena (1'b1)    // (terminated)
        );

        //debug
        wire [47:0] CA_sig;
        reg  [47:0] CA_sigr;
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

    `endif

    reg prev_memr,prev_memw,prev_regr,prev_regw;

    wire [3:0] stm_end;
    reg  [3:0] stm_start;

    wire [15:0] rdreg_datain,wrreg_datain,rdmem_datain,wrmem_datain;
    wire        rdreg_oe,wrreg_oe,rdmem_oe,wrmem_oe;
    wire        rdreg_csn,wrreg_csn,rdmem_csn,wrmem_csn;
    wire        rdreg_oe_clk,wrreg_oe_clk,rdmem_oe_clk,wrmem_oe_clk;


    always@(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            prev_memr <= 0;
            prev_memw <= 0;
            prev_regr <= 0;
            prev_regw <= 0;
            CA_sigr <= 0;
            regr <= 0;
            regw <= 0;
            for (int i = 0;i<4 ;i++ ) begin
                stm_start[i] <= 0;
            end
        end else begin
            regr <= csr_read;
            regw = csr_write;
            prev_memr <= memr;
            prev_memw <= memw;
            prev_regr <= regr;
            prev_regw <= regw;

            case (state)
                IDLE: begin
                    CA_sigr   <= 0;
                    if (regr && !prev_regr) begin
                        state <= RDREG;
                    end else
                    if (regw && !prev_regw) begin
                        state <= WRREG;
                    end else
                    if (memr && !prev_memr) begin
                        state <= RDMEM;
                    end else
                    if (memw && !prev_memw) begin
                        state <= WRMEM;
                    end
                end
                RDREG: begin
                    if(stm_end[0]) begin
                        state <= IDLE;
                        stm_start[0] <= 0;

                    end else begin
                        stm_start[0] <= 1;
                    end

                    case (csr_address)
                            'h0: CA_sigr <= 48'hc000_0000_0000;
                            'h4: CA_sigr <= 48'hc000_0000_0001;
                            'h8: CA_sigr <= 48'hc000_0100_0000;
                            'hc: CA_sigr <= 48'hc000_0100_0001;
                            default: CA_sigr <= 48'hc000_0000_0000;
                    endcase
                end
                WRREG: begin
                    if(stm_end[1]) begin
                        state <= IDLE;
                        stm_start[1] <= 0;
                    end else begin
                        stm_start[1] <= 1;
                    end
                end
                RDMEM: begin
                    if(stm_end[2]) begin
                        state <= IDLE;
                        stm_start[2] <= 0;
                    end else begin
                        stm_start[2] <= 1;
                    end
                end
                WRMEM: begin
                    if(stm_end[3]) begin
                        state <= IDLE;
                        stm_start[3] <= 0;
                    end else begin
                        stm_start[3] <= 1;
                    end
                end 
                default: state <= IDLE;
            endcase
        end
    end

    always@(posedge clk) begin
        if(rst) begin
            
            rwds_out <= 0;
            rwds_oe  <= 0;
            datain <= 0;
            oe_data <= 0;
            oe_clk <= 0;
            csn  <= 1;
        end else begin
            

            
            rwds_out <= stm_start[3] ? wrmem_rwds_out : 'h0;
            rwds_oe  <= stm_start[3] ? wrmem_rwds_oe  : 'h0;

            datain  <=  stm_start[0] ? rdreg_datain :
                        stm_start[1] ? wrreg_datain :
                        stm_start[2] ? rdmem_datain :
                        stm_start[3] ? wrmem_datain : 'h0;

            oe_data <=  stm_start[0] ? rdreg_oe  :
                        stm_start[1] ? wrreg_oe  :
                        stm_start[2] ? rdmem_oe  :
                        stm_start[3] ? wrmem_oe  : 'h0;

            oe_clk  <=  stm_start[0] ? rdreg_oe_clk  :
                        stm_start[1] ? wrreg_oe_clk  :
                        stm_start[2] ? rdmem_oe_clk  :
                        stm_start[3] ? wrmem_oe_clk  : 'h0;

            csn     <=  stm_start[0] ? rdreg_csn :
                        stm_start[1] ? wrreg_csn :
                        stm_start[2] ? rdmem_csn :
                        stm_start[3] ? wrmem_csn : 'h1;

        end
    end

    rdreg_stm rdreg_inst (
        .clk            (clk),
        .rst            (rst),
        .stm_start      (stm_start[0]),
        .stm_end        (stm_end[0]),
        .oe             (rdreg_oe),
        .oe_clk         (rdreg_oe_clk),
        .csn            (rdreg_csn),
        .datain         (rdreg_datain),
        .dataout        (dataout),
		.rwds_in		(rwds_in),
        .casig          (CA_sigr),
        .valid          (csr_readdatavalid),
        .dataoutr       (csr_readdata)
    );

    rdmem_stm rdmem_inst (
        .clk            (clk),
        .rst            (rst),
        .stm_start      (stm_start[2]),
        .stm_end        (stm_end[2]),
        .oe             (rdmem_oe),
        .oe_clk         (rdmem_oe_clk),
        .csn            (rdmem_csn),
        .datain         (rdmem_datain),
        .dataout        (dataout),
		.rwds_in		(rwds_in),
        .casig          (CA_sigr)
    );

    wrmem_stm wrmem_inst (
        .clk            (clk),
        .rst            (rst),
        .stm_start      (stm_start[3]),
        .stm_end        (stm_end[3]),
        .oe             (wrmem_oe),
        .oe_clk         (wrmem_oe_clk),
        .csn            (wrmem_csn),
        .datain         (wrmem_datain),
		.rwds_in		(rwds_in),
        .rwds_out       (wrmem_rwds_out),
        .rwds_oe        (wrmem_rwds_oe),
        .casig          (CA_sigr)
    );

    



endmodule