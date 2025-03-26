module iobuf(
	input  wire 		clk0,
	input  wire 		clk90,
	input  wire [15:0] 	datain,
	output wire [15:0]	dataout,
	input  wire 		oe_clk,
	input  wire			oe_data,
	output wire 		ckout,
	output wire 		ckoutn,
	inout  wire [7:0] 	dq,
	inout  wire			rwds
	
);


	dq dq_inst (
		.outclock 	( clk0 ), // <-- center aligned to pad
		.datain_h 	( datain[15:8] ),
		.datain_l 	( datain[7:0] ),
		.inclock  	( rwds ),  //<-- edge aligned to pad
		.dataout_h 	( dataout[15:8] ),
		.dataout_l 	( dataout[7:0] ),
		.oe 		( oe_data ),
		.padio 		( dq )
	);
	
	// assign ckout = oe_clk ? clk0 : 1'b0;
	// assign ckoutn = oe_clk ? ~clk0 : 1'b0;

	ck	ckp_inst (
		.aclr 		( 1'b0 ),
		.datain_h 	( oe_clk ),
		.datain_l 	( 1'b0 ),
		.oe 			( 1'b1 ),
		.outclock 	( clk90 ),
		.dataout 	( ckout )
	);

	ck	ckn_inst (
		.aclr 		( 1'b0 ),
		.datain_h 	( 1'b0 ),
		.datain_l 	( oe_clk ),
		.oe 			( 1'b1 ),
		.outclock 	( clk90 ),
		.dataout 	( ckoutn )
	);

endmodule