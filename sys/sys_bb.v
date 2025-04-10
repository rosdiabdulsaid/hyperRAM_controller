
module sys (
	jtag_uart_0_irq_irq,
	rst_reset,
	refclk_clk,
	memrst_reset,
	io_dq,
	io_rwds,
	io_ckout,
	io_ckoutn,
	io_csn,
	io_rstn);	

	output		jtag_uart_0_irq_irq;
	input		rst_reset;
	input		refclk_clk;
	input		memrst_reset;
	inout	[7:0]	io_dq;
	inout		io_rwds;
	output		io_ckout;
	output		io_ckoutn;
	output		io_csn;
	output		io_rstn;
endmodule
