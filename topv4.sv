module topv4(
    input wire refclk,
    inout wire [7:0] dq,
    inout wire rwds,
    output wire ckout,
    output wire ckoutn,
    output wire csn,
    output wire rstn
);


    sys sys_inst (
		.rst_reset           (1'b0),           //             rst.reset
		.io_dq               (dq),               //              io.dq
		.io_rwds             (rwds),             //                .rwds
		.io_ckout            (ckout),            //                .ckout
		.io_ckoutn           (ckoutn),           //                .ckoutn
		.io_csn              (csn),              //                .csn
		.io_rstn             (rstn),             //                .rstn
		.memrst_reset        (1'b0),        //          memrst.reset
		.refclk_clk          (refclk),          //          refclk.clk
		.jtag_uart_0_irq_irq ()  // jtag_uart_0_irq.irq
	);

    // sys_jamb sys_inst (
	// 	.clk_clk            (refclk),            //          clk.clk
	// 	.reset_reset_n      (1'b1),      //        reset.reset_n
	// 	.memrst_reset       (1'b0),       //       memrst.reset
	// 	.master_reset_reset (), // master_reset.reset
	// 	.io_dq              (dq),              //           io.dq
	// 	.io_rwds            (rwds),            //             .rwds
	// 	.io_ckout           (ckout),           //             .ckout
	// 	.io_ckoutn          (ckoutn),          //             .ckoutn
	// 	.io_csn             (csn),             //             .csn
	// 	.io_rstn            (rstn)             //             .rstn
	// );



endmodule