module topv3(
    output wire       ckout,
    output wire       ckoutn,
    inout  wire [7:0] dq,
    inout  wire       rwds,
    output wire        csn,
    output wire       rstn,
    input  wire       refclk
);
	
    wire rwds_in;
    wire rwds_out;
    assign rwds_in  = rwds;
    assign rwds     = rwds_oe ? rwds_out : 'bZ;
	
	wire clk0, clk90;
    reg [15:0] datain;
	reg        oe_clk, oe_data;
    wire [15:0] dataout;
	wire memrst,rst;
	
	altsource_probe_top #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             ("NONE"),
            .probe_width             (0),
            .source_width            (2),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
    ) rst_control (
        .source     ({memrst,rst}), // sources.source
        .source_ena (1'b1)    // (terminated)
    );

	pll2 pll2_inst (
		.areset ( rst ),
		.inclk0 ( refclk ),
		.c0 ( clk0 ),
		.c1 ( clk90 ),
		.locked ( lock )
	);
	
	//io buffer mgmt
		
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

    
    assign rstn = !memrst;
    //state machine portion

    wire		    clk_clk;                //i
	wire		    clk_reset_reset;        //i
	wire	[31:0]	csr_address;         //o
	wire	[31:0]	csr_readdata;        //i
	wire		    csr_read;            //o
	wire		    csr_write;           //o
	wire	[31:0]	csr_writedata;       //o
	wire		    csr_waitrequest;     //i
	wire		    csr_readdatavalid;   //i

    wire	[31:0]	s0_address;         //o
	wire	[31:0]	s0_readdata;        //i
	wire		    s0_read;            //o
	wire		    s0_write;           //o
	wire	[31:0]	s0_writedata;       //o
	wire		    s0_waitrequest;     //i
	wire		    s0_readdatavalid;   //i


    jamb jamb_csr (
		.clk_clk              (clk0),                 //          clk.clk
		.clk_reset_reset      (rst),                  //    clk_reset.reset
		.master_address       (csr_address),       //       master.address
		.master_readdata      (csr_readdata),      //             .readdata
		.master_read          (csr_read),          //             .read
		.master_write         (csr_write),         //             .write
		.master_writedata     (csr_writedata),     //             .writedata
		.master_waitrequest   (csr_waitrequest),   //             .waitrequest
		.master_readdatavalid (csr_readdatavalid), //             .readdatavalid
		.master_byteenable    (4'hf),                 //             .byteenable
		.master_reset_reset   ()                      // master_reset.reset
	);
    

    jamb jamb_data (
		.clk_clk              (clk0),                 //          clk.clk
		.clk_reset_reset      (rst),                  //    clk_reset.reset
		.master_address       (s0_address),       //       master.address
		.master_readdata      (s0_readdata),      //             .readdata
		.master_read          (s0_read),          //             .read
		.master_write         (s0_write),         //             .write
		.master_writedata     (s0_writedata),     //             .writedata
		.master_waitrequest   (s0_waitrequest),   //             .waitrequest
		.master_readdatavalid (s0_readdatavalid), //             .readdatavalid
		.master_byteenable    (4'hf),                 //             .byteenable
		.master_reset_reset   ()                      // master_reset.reset
	);

    top_stm stm_inst(
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
        .csr_waitrequest   (csr_waitrequest),   //             .waitreques
        .csr_readdatavalid (csr_readdatavalid), //             .readdatavalid

        .s0_address       (s0_address),       //       master.address
        .s0_readdata      (s0_readdata),      //             .readdata
        .s0_read          (s0_read),          //             .read
        .s0_write         (s0_write),         //             .write
        .s0_writedata     (s0_writedata),     //             .writedata
        .s0_waitrequest   (s0_waitrequest),   //             .waitreques
        .s0_readdatavalid (s0_readdatavalid) //             .readdatavalid
    );


    
    


	 
endmodule