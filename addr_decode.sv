module addr_decode(
    input  wire [31:0]  in_addr,
    input  wire         read,
    input  wire         write,
    output wire [47:0]  out_addr,
    output wire [13:0]  row_id,
    output wire [4:0]   page_id,
    output wire [4:0]   buffer_addr
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

assign page_id = (in_addr >> 5) << 1;
assign row_id = in_addr[23:10]; //row id is 14 bits
assign buffer_addr = in_addr[4:0]; //modulus 32

endmodule