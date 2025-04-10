	sys u0 (
		.jtag_uart_0_irq_irq (<connected-to-jtag_uart_0_irq_irq>), // jtag_uart_0_irq.irq
		.rst_reset           (<connected-to-rst_reset>),           //             rst.reset
		.refclk_clk          (<connected-to-refclk_clk>),          //          refclk.clk
		.memrst_reset        (<connected-to-memrst_reset>),        //          memrst.reset
		.io_dq               (<connected-to-io_dq>),               //              io.dq
		.io_rwds             (<connected-to-io_rwds>),             //                .rwds
		.io_ckout            (<connected-to-io_ckout>),            //                .ckout
		.io_ckoutn           (<connected-to-io_ckoutn>),           //                .ckoutn
		.io_csn              (<connected-to-io_csn>),              //                .csn
		.io_rstn             (<connected-to-io_rstn>)              //                .rstn
	);

