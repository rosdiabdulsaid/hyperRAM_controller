`define DEBUG
module hyperram_controller(
    input wire clk,  
    input wire rst,

    output reg oe_data,
    output reg oe_clk,
    output reg csn,
    input  wire rwds_in,
    output reg  rwds_out,
    output reg  rwds_oe,
    output reg [15:0] datain,
    input  wire [15:0] dataout,

    input  wire [9:0]  csr_address,         //     csr.address
    input  wire        csr_read,            //        .read
    input  wire        csr_write,           //        .write
    output wire [31:0] csr_readdata,        //        .readdata
    output wire        csr_readdatavalid,   //        .readdatavalid
    input  wire [31:0] csr_writedata,       //        .writedata
    // input  wire        csr_waitrequest,      //        .waitrequest

    input  wire [21:0] s0_address,          //       s0.address
    input  wire        s0_read,             //         .read
    input  wire        s0_write,            //         .write
    output reg [31:0]  s0_readdata,         //         .readdata
    output reg         s0_readdatavalid,    //         .readdatavalid
    input  wire [31:0] s0_writedata        //         .writedata
    // output wire        s0_waitrequest       //         .waitrequest

);


    typedef enum logic [3:0] {
        IDLE,
        RDREG,
        WRREG,
        RDMEM1,
        WRMEM1,
        RDMEM2,
        WRMEM2,
        ACCDLY
    } top_state;

    top_state state;
    reg regr,regw;
    reg memr,memw;
    // wire [31:0] s0_address;
    wire [47:0] CA_sig;
    reg  [47:0] CA_sigr;



    reg prev_memr,prev_memw,prev_regr,prev_regw;

    wire [3:0] stm_end;
    reg  [3:0] stm_start;

    wire [15:0] rdreg_datain,wrreg_datain,rdmem_datain,wrmem_datain;
    wire        rdreg_oe,wrreg_oe,rdmem_oe,wrmem_oe;
    wire        rdreg_csn,wrreg_csn,rdmem_csn,wrmem_csn;
    wire        rdreg_oe_clk,wrreg_oe_clk,rdmem_oe_clk,wrmem_oe_clk;

    reg [3:0] acc_counter;  
    reg rd_tmp, wr_tmp;

    wire [13:0] row_id;
    wire [4:0]  page_id;
    wire [4:0] buf_addr;

    reg [13:0] curr_row_id;
    reg [4:0]  curr_page_id;
    reg [21:0] captured_s0_address;
    reg [9:0]  captured_csr_address;
    wire buffer_valid;
    wire [31:0] buffer_dataout;
    reg [255:0] buffer_wrmem;
    // wire [31:0] int_s0_addr;


    addr_decode addr_decode_inst (
        .in_addr        (captured_s0_address),
        .read           (rd_tmp),
        .write          (wr_tmp),
        .out_addr       (CA_sig),
        .row_id         (row_id),
        .page_id        (page_id),
        .buffer_addr    (buf_addr),
    );

    //buffer mechanism
    //initial buffer content should be 0, no need to write to ram yet.
    //if changed address detected, then write buffer to ram

    reg [31:0] buffer [0:7];
    wire buffer_hit; //buffer hit, else buffer miss
    reg row; //read or write
    reg inbuffer_valid;
    assign buffer_hit = (curr_row_id == row_id) && (curr_page_id == page_id);

    


    always@(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            regr <= 0;
            regw <= 0;
            memr <= 0;
            memw <= 0;
            rd_tmp <= 0;
            wr_tmp <= 0;

            prev_memr <= 0;
            prev_memw <= 0;
            prev_regr <= 0;
            prev_regw <= 0;
            CA_sigr <= 0;
            acc_counter <= 0;
            s0_readdata <= 0;
            s0_readdatavalid <= 0;
            curr_row_id <=0;
            curr_page_id <=0;
            buffer_wrmem <= 0;
            row <= 0;
            inbuffer_valid <= 0;
            for (int i = 0;i<8 ;i++ ) begin
                buffer[i] <= 0;
            end

            for (int i = 0;i<4 ;i++ ) begin
                stm_start[i] <= 0;
            end
        end else begin
            regr <= csr_read;
            regw <= csr_write;
            memr <= s0_read;
            memw <= s0_write;

            prev_regr <= regr;
            prev_regw <= regw;
            prev_memr <= memr;
            prev_memw <= memw;
            

            case (state)
                IDLE: begin
                    CA_sigr   <= 0;
                    rd_tmp    <= 0;
                    wr_tmp    <= 0;
                    buffer_wrmem <= 0;
                    s0_readdatavalid <= 0;
                    acc_counter <= 8;
                    inbuffer_valid <= 0;
                    if (regr && !prev_regr) begin
                        state <= RDREG;
                    end else
                    if (regw && !prev_regw) begin
                        state <= WRREG;
                    end else
                    if (memr && !prev_memr) begin
                        row <= 1;
                        if (buffer_hit) begin
                            state <= RDMEM1;
                        end else begin
                            state <= RDMEM2;
                        end
                    end else
                    if (memw && !prev_memw) begin
                        row <= 0;
                        if (buffer_hit) begin
                            state <= WRMEM1;
                        end else begin
                            /*
                            when we write during buffer miss, we need to read data from memory, store it in buffer
                            the buffer is updated with the new data, and then we write to memory.
                            */
                            state <= RDMEM2;
                        end
                    end
                end
                RDREG: begin
                    if(stm_end[0]) begin
                        state <= IDLE;
                        stm_start[0] <= 0;

                    end else begin
                        stm_start[0] <= 1;
                    end

                    case (captured_csr_address)
                            'h0: CA_sigr <= 48'hc000_0000_0000;
                            'h1: CA_sigr <= 48'hc000_0000_0001;
                            'h2: CA_sigr <= 48'hc000_0100_0000;
                            'h3: CA_sigr <= 48'hc000_0100_0001;
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
                RDMEM1: begin
                    case (buf_addr)
                        5'h0: s0_readdata <= buffer[0];
                        5'h1: s0_readdata <= buffer[1];
                        5'h2: s0_readdata <= buffer[2];
                        5'h3: s0_readdata <= buffer[3];
                        5'h4: s0_readdata <= buffer[4];
                        5'h5: s0_readdata <= buffer[5];
                        5'h6: s0_readdata <= buffer[6];
                        5'h7: s0_readdata <= buffer[7];
                        default: s0_readdata <= 32'h0;
                    endcase
                    s0_readdatavalid <= 1;
                    state <= IDLE;
                end
                WRMEM1: begin
                    case (buf_addr)
                        5'h0: buffer[0] <= s0_writedata;
                        5'h1: buffer[1] <= s0_writedata;
                        5'h2: buffer[2] <= s0_writedata;
                        5'h3: buffer[3] <= s0_writedata;
                        5'h4: buffer[4] <= s0_writedata;
                        5'h5: buffer[5] <= s0_writedata;
                        5'h6: buffer[6] <= s0_writedata;
                        5'h7: buffer[7] <= s0_writedata;
                        default: buffer[0]  <= 32'h0;
                    endcase
                    if (buffer_hit) begin
                        state <= IDLE;
                    end else if (!buffer_hit) begin
                        state <= WRMEM2;
                        inbuffer_valid <= 1;
                        buffer_wrmem <= {buffer[0],buffer[1],buffer[2],buffer[3],buffer[4],buffer[5],buffer[6],buffer[7]};
                    end
                    
                end
                RDMEM2: begin
                    if(stm_end[2]) begin
                        if (row) begin
                            state <= RDMEM1;
                            
                            curr_row_id <= row_id;
                            curr_page_id <= page_id;
                        end else if(!row) begin
                            inbuffer_valid <= 0;
                            state <= WRMEM1;
                        end
                        stm_start[2] <= 0;
                    end else begin
                        stm_start[2] <= rd_tmp;
                        rd_tmp <= 1;
                        CA_sigr <= CA_sig;
                    end

                
                    if (buffer_valid) begin
                        for (int i = 0; i<7;i++ ) begin
                            buffer[i] <= buffer[i+1];
                        end
                        
                        buffer[7] <= buffer_dataout;
                    end
                    
                end
                WRMEM2: begin
                    inbuffer_valid <= 0; 
                    if(stm_end[3]) begin
                        state <= ACCDLY;
                        curr_row_id <= row_id;
                        curr_page_id <= page_id;
                        stm_start[3] <= 0;
                    end else begin
                        stm_start[3] <= wr_tmp;
                        wr_tmp  <= 1;
                        CA_sigr <= CA_sig;
                        
                    end
                    
                end
                ACCDLY: begin
                    if (acc_counter == 0) begin
                        state <= IDLE;
                    end else begin
                        acc_counter <= acc_counter - 1;
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
            captured_s0_address <= 0;
            captured_csr_address <= 0;
        end else begin
            
            if(s0_read || s0_write) begin
                captured_s0_address <= s0_address;
            end
            
            if (csr_read || csr_write) begin
                captured_csr_address <= csr_address;
            end

            rwds_out <= stm_start[3] ? wrmem_rwds_out : 1'h0;
            rwds_oe  <= stm_start[3] ? wrmem_rwds_oe  : 1'h0;

            datain  <=  stm_start[0] ? rdreg_datain :
                        stm_start[1] ? wrreg_datain :
                        stm_start[2] ? rdmem_datain :
                        stm_start[3] ? wrmem_datain : 1'h0;

            oe_data <=  stm_start[0] ? rdreg_oe  :
                        stm_start[1] ? wrreg_oe  :
                        stm_start[2] ? rdmem_oe  :
                        stm_start[3] ? wrmem_oe  : 1'h0;

            oe_clk  <=  stm_start[0] ? rdreg_oe_clk  :
                        stm_start[1] ? wrreg_oe_clk  :
                        stm_start[2] ? rdmem_oe_clk  :
                        stm_start[3] ? wrmem_oe_clk  : 1'h0;

            csn     <=  stm_start[0] ? rdreg_csn :
                        stm_start[1] ? wrreg_csn :
                        stm_start[2] ? rdmem_csn :
                        stm_start[3] ? wrmem_csn : 1'h1;

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
        .dataoutr       (buffer_dataout),
        .wordvalid      (buffer_valid),
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
        .databuffer     (buffer_wrmem),
        .valid          (inbuffer_valid),
        .casig          (CA_sigr)
    );

    



endmodule