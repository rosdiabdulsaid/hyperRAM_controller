module addr_decode(
    input  wire [31:0]  in_addr,
    input  wire         read,
    input  wire         write,
    output wire [47:0]  out_addr
);


assign out_addr[47] = read ? 1'b1 : 1'b0;

assign out_addr[46:36] = 11'b0;
assign out_addr[15:3]  = 13'b0;

//row address
assign out_addr[35:22] = 14'h0;
//upper column address
assign out_addr[21:16] = (in_addr >> 5) << 1; // 2*in_addr/32 
//lower column address
assign out_addr[2:0]   = 0;

endmodule