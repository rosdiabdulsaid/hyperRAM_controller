module top(
	input wire refclk

);
	wire clk,locked;
	
	pll pll_inst (
		.areset ( 1'b0 ),
		.inclk0 ( refclk ),
		.c0 ( clk ),
		.locked ( locked )
	);


	controller u0 (
		.clk_clk       (clk),       //   clk.clk
		.reset_reset_n (locked)  // reset.reset_n
	);



endmodule