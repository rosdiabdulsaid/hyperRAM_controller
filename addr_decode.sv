module addr_decode(
    input  wire [21:0]  in_addr,
    input  wire         read,
    input  wire         write,
    output wire [47:0]  out_addr,
    output wire [13:0]  row_id,
    output wire [4:0]   page_id,
    output wire [2:0]   buffer_addr
);


assign out_addr[47] = read ? 1'b1 : 1'b0;

assign out_addr[46:36] = 11'b0;
assign out_addr[15:3]  = 13'b0;

wire [23:0] times4addr;
wire [22:0] time2addr;
assign times2addr = in_addr << 1;
assign times4addr = in_addr << 2;
//row address
assign out_addr[35:22] = 14'h0;
//upper column address
assign out_addr[22:21] = 2'b0;

assign out_addr[21:16] = (times4addr >> 5) << 1; // 2*in_addr/32 
//lower column address
assign out_addr[2:0]   = 0;

assign page_id = (times4addr >> 5) << 1;
assign row_id = times2addr[22:9]; //row id is 14 bits
assign buffer_addr = in_addr[2:0]; 

endmodule