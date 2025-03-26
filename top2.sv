module top2(
    inout wire [7:0] dq,
    inout wire rwds,
    output reg CSNeg,
    output wire CK,
    output wire RESETNeg,

    input wire refclk
);

	 wire [15:0] datain;
    wire [15:0] dataout;

    reg [15:0] buffer_out [0:2];
    reg start = 0;
    reg csnreg = 1;
    reg clken = 0;
		
		wire clk,clk90;
		
		pll2	pll2_inst (
			.areset ( 1'b0 ),
			.inclk0 ( refclk ),
			.c0 ( clk ),
			.c1 (	clk90),
			.locked (  )
		);
		
		assign CK = clken ? clk90 : 1'b0;

		reg [3:0] counter;
		reg [3:0] reg_read;
		localparam  HR_REGRD = 0,
						 DR_CSNL = 1,
						 RD_REG = 2;
		always@(posedge clk or posedge rst) begin
        if (rst) begin
            reg_read <= 0;
            CSNeg <= 0;
            counter <= 0;
				buffer_out[0] <= 'hC0;
				buffer_out[1] <= 0;
				buffer_out[2] <= 0;
//            for (int i = 0; i < 3 ; i++ ) begin
//                buffer_out[i] <= 0;
//            end

        end else begin
        case (reg_read)
            HR_REGRD: begin
                    CSNeg <= 1;
                if (sigr) begin
                    reg_read <= DR_CSNL;
                    CSNeg <= 0;
                end
                
            end
            DR_CSNL: begin
                if (counter == 6) begin
                    reg_read <= RD_REG;
                    counter <= 0;
                end else begin
                    for (int i = 0; i < 3 ; i++ ) begin
                    buffer_out[i] <= buffer_out[i + 1];
                    end
                    buffer_out[2] <= 'hXXXX;
                    counter <= counter + 1;
                end
                CSNeg <= 0;
                
            end
            RD_REG: begin
                ;
            end
            default: ;
        endcase
        end
    
    end
	 
	 always@(posedge clk or posedge rst) begin
    if (rst) begin
        clken <= 0;
    end else begin
        if(CSNeg) begin
            clken <= 0;
        end else begin
            clken <= 1;
        end
    end
end

	dq	dq_inst (
        .datain_h ( datain[15:8] ),
        .datain_l ( datain[7:0] ),
        .inclock ( clock ),
        .oe ( !CSNeg ),
        .outclock ( clock ),
        .dataout_h ( dataout[7:0] ),
        .dataout_l ( dataout[15:8] ),
        .padio ( dq )
	);

    assign datain = buffer_out[0];

endmodule