
module sys_jamb (
	clk_clk,
	reset_reset_n,
	memrst_reset,
	master_reset_reset,
	io_dq,
	io_rwds,
	io_ckout,
	io_ckoutn,
	io_csn,
	io_rstn);	

	input		clk_clk;
	input		reset_reset_n;
	input		memrst_reset;
	output		master_reset_reset;
	inout	[7:0]	io_dq;
	inout		io_rwds;
	output		io_ckout;
	output		io_ckoutn;
	output		io_csn;
	output		io_rstn;
endmodule
