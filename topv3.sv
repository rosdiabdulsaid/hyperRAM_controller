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
        .dataout        (dataout)
    );


    
    


	 
endmodule