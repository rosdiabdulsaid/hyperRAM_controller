module hyperram_controller_top (

    input  wire       refclk,
    input  wire       memrst,
    input  wire       rst,
    output wire       coreclk,
    output wire       corerst,
    
    output wire       ckout,
    output wire       ckoutn,
    inout  wire [7:0] dq,
    inout  wire       rwds,
    output wire       csn,
    output wire       rstn,

    input  wire [9:0]  csr_address,         //     csr.address
    input  wire        csr_read,            //        .read
    input  wire        csr_write,           //        .write
    output wire [31:0] csr_readdata,        //        .readdata
    output wire        csr_readdatavalid,   //        .readdatavalid
    input  wire [31:0] csr_writedata,       //        .writedata
    // output  wire        csr_waitrequest,      //        .waitrequest

    input  wire [21:0] s0_address,          //       s0.address
    input  wire        s0_read,             //         .read
    input  wire        s0_write,            //         .write
    output reg [31:0]  s0_readdata,         //         .readdata
    output reg         s0_readdatavalid,    //         .readdatavalid
    input  wire [31:0] s0_writedata        //         .writedata
    // output wire        s0_waitrequest       //         .waitrequest
);


wire rwds_in;
wire rwds_out;
assign rwds_in  = rwds;
assign rwds     = rwds_oe ? rwds_out : 'bZ;

wire clk0, clk90;
reg [15:0] datain;
reg        oe_clk, oe_data;
wire [15:0] dataout;
assign rstn = !memrst;
assign coreclk = clk0;
assign corerst = rst;


pll2 pll2_inst (
		.areset ( rst ),
		.inclk0 ( refclk ),
		.c0 ( clk0 ),
		.c1 ( clk90 ),
		.locked ( lock )
	);

iobuf iobuf_inst(
		.clk0		(clk0),
		.clk90	    (clk90),
		.datain	    (datain),
		.dataout    (dataout),
		.oe_clk		(oe_clk),
		.oe_data    (oe_data),
		.ckout	    (ckout),
        .ckoutn     (ckoutn),
		.dq		    (dq),
		.rwds		(rwds_in)
	);

hyperram_controller hc_inst(
        .clk            (clk0),
        .rst            (rst),
        .oe_data        (oe_data),
        .oe_clk         (oe_clk),
        .csn            (csn),
        .datain         (datain),
        .rwds_in        (rwds_in),
        .rwds_out       (rwds_out),
        .rwds_oe        (rwds_oe),
        .dataout        (dataout),

        .csr_address       (csr_address),       //       master.address
        .csr_readdata      (csr_readdata),      //             .readdata
        .csr_read          (csr_read),          //             .read
        .csr_write         (csr_write),         //             .write
        .csr_writedata     (csr_writedata),     //             .writedata
        // .csr_waitrequest   (csr_waitrequest),   //             .waitrequest
        .csr_readdatavalid (csr_readdatavalid), //             .readdatavalid

        .s0_address       (s0_address),       //       master.address
        .s0_readdata      (s0_readdata),      //             .readdata
        .s0_read          (s0_read),          //             .read
        .s0_write         (s0_write),         //             .write
        .s0_writedata     (s0_writedata),     //             .writedata
        // .s0_waitrequest   (s0_waitrequest),   //             .waitrequest
        .s0_readdatavalid (s0_readdatavalid) //             .readdatavalid
    );


endmodule