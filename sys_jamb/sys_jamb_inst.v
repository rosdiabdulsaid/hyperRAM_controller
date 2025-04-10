	sys_jamb u0 (
		.clk_clk            (<connected-to-clk_clk>),            //          clk.clk
		.reset_reset_n      (<connected-to-reset_reset_n>),      //        reset.reset_n
		.memrst_reset       (<connected-to-memrst_reset>),       //       memrst.reset
		.master_reset_reset (<connected-to-master_reset_reset>), // master_reset.reset
		.io_dq              (<connected-to-io_dq>),              //           io.dq
		.io_rwds            (<connected-to-io_rwds>),            //             .rwds
		.io_ckout           (<connected-to-io_ckout>),           //             .ckout
		.io_ckoutn          (<connected-to-io_ckoutn>),          //             .ckoutn
		.io_csn             (<connected-to-io_csn>),             //             .csn
		.io_rstn            (<connected-to-io_rstn>)             //             .rstn
	);

