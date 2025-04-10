// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ns

// Following localparams are created as a result of hammer failures for quartus_tlg
// quartus_tlg does not process encrypted files & if opcode_def is imported here it does not work.
// MXLEN will be a user parameter when we have 64 bit core implementation
//   localparam MXLEN_LOCAL  = 32;
//   localparam ADDR_W_LOCAL = MXLEN_LOCAL;
//   localparam DATA_W_LOCAL = MXLEN_LOCAL;
// Commenting out above param declarations as it causes redeclarations compile errors in case
// the design has 2 niosv cores instantiated, hardcoding values for 32 bit core now : TODO

module sys_intel_niosv_c_0_hart #(
   parameter DBG_EXPN_VECTOR = 32'h80000000,
   parameter RESET_VECTOR = 32'h00000000,
   parameter CORE_EXTN = 26'h0000100, // RV32I
   parameter HARTID = 32'h00000000,
   parameter DEBUG_ENABLED = 1'b0,
   parameter DEVICE_FAMILY = "Stratix 10",
   parameter DBG_PARK_LOOP_OFFSET = 32'd24,
   parameter USE_RESET_REQ = 1'b0,
   parameter CSR_ENABLED   = 1'b0,
   parameter ECC_EN = 1'b0,
   parameter SHIFT_BY             = 1,
   parameter OPTIMIZE_ALU_AREA    = 1'b1 
) (
   input wire clk,
   input wire reset,
   input wire reset_req,
   output wire reset_req_ack,

   // ================== Instruction Interface ==================

   input [31:0]             instr_avl_rdata,   
   input                    instr_avl_waitrequest,
   input                    instr_avl_rdatavalid,
   input [1:0]              instr_avl_resp,
   output wire [31:0]       instr_avl_addr,   
   output wire              instr_avl_read, 


   // ===================== Data Interface ======================


   input [31:0]       data_avl_rdata,   
   input                    data_avl_waitrequest,
   input                    data_avl_rdatavalid,
   input [1:0]              data_avl_resp,
   output wire [31:0] data_avl_addr,   
   output wire              data_avl_read, 
   output wire              data_avl_write, 
   output wire [31:0] data_avl_wdata,   
   output wire [3:0]        data_avl_byteen,   
   input                    data_avl_wrespvalid,
   


   input wire        irq_timer,
   input wire        irq_sw,
   input wire [15:0] irq_plat_vec,
   input wire        irq_ext,

   input wire        irq_debug,

   output wire [1:0] core_ecc_status,
   output wire [3:0] core_ecc_src
);



         wire shim_instr_awready;
         wire shim_instr_wready;
         wire shim_instr_bvalid;
         wire [1:0] shim_instr_bresp;
         wire shim_instr_arready;

         wire shim_data_arready;
         wire shim_data_awready;
         wire shim_data_wready;
         wire [1:0] shim_data_bresp;

         wire [31:0] shim_instr_rdata;   
         wire        shim_instr_rvalid;
         wire [1:0]  shim_instr_rresp;
         wire [31:0] shim_instr_araddr;   
         wire        shim_instr_arvalid;  

         wire [31:0]       shim_data_rdata;   
         wire              shim_data_rvalid;
         wire [1:0]        shim_data_rresp;
         wire [31:0]       shim_data_araddr;   
         wire              shim_data_arvalid; 
         wire              shim_data_awvalid; 
         wire [31:0]       shim_data_wdata;   
         wire [3:0]        shim_data_wstrb;   
         wire              shim_data_bvalid;

 
         niosv_avl_to_axi_shim shim_inst (
            // avl interface to/from shim
            .shim_instr_avl_rdata         (instr_avl_rdata),   
            .shim_instr_avl_waitrequest   (instr_avl_waitrequest),
            .shim_instr_avl_rdatavalid    (instr_avl_rdatavalid),
            .shim_instr_avl_resp          (instr_avl_resp),
            .shim_instr_avl_addr          (instr_avl_addr),   
            .shim_instr_avl_read          (instr_avl_read), 

            .shim_data_avl_rdata          (data_avl_rdata),   
            .shim_data_avl_waitrequest    (data_avl_waitrequest),
            .shim_data_avl_rdatavalid     (data_avl_rdatavalid),
            .shim_data_avl_resp           (data_avl_resp),
            .shim_data_avl_addr           (data_avl_addr),   
            .shim_data_avl_read           (data_avl_read), 
            .shim_data_avl_write          (data_avl_write), 
            .shim_data_avl_wdata          (data_avl_wdata),   
            .shim_data_avl_byteen         (data_avl_byteen),   
            .shim_data_avl_wrespvalid     (data_avl_wrespvalid),


 
            // shim to/from core
            .shim_instr_rdata          (shim_instr_rdata),   
            .shim_instr_rvalid         (shim_instr_rvalid),
            .shim_instr_rresp          (shim_instr_rresp),
            .shim_instr_araddr         (shim_instr_araddr),   
            .shim_instr_arvalid        (shim_instr_arvalid),

            .shim_data_rdata           (shim_data_rdata),   
            .shim_data_rvalid          (shim_data_rvalid),
            .shim_data_rresp           (shim_data_rresp),
            .shim_data_araddr          (shim_data_araddr),   
            .shim_data_arvalid         (shim_data_arvalid), 
            .shim_data_awvalid         (shim_data_awvalid), 
            .shim_data_wdata           (shim_data_wdata),   
            .shim_data_wstrb           (shim_data_wstrb),   
            .shim_data_bvalid          (shim_data_bvalid),

            
 
            .shim_instr_awready (shim_instr_awready),
            .shim_instr_wready  (shim_instr_wready), 
            .shim_instr_bvalid  (shim_instr_bvalid),
            .shim_instr_bresp   (shim_instr_bresp),
            .shim_instr_arready (shim_instr_arready),

            .shim_data_arready  (shim_data_arready),
            .shim_data_awready  (shim_data_awready), 
            .shim_data_wready   (shim_data_wready), 
            .shim_data_bresp    (shim_data_bresp)

         );



         niosv_c_core # (
            .DBG_EXPN_VECTOR (DBG_EXPN_VECTOR),
            .RESET_VECTOR (RESET_VECTOR),
            .CORE_EXTN (CORE_EXTN),
            .HARTID(HARTID),
            .DEBUG_ENABLED (DEBUG_ENABLED),
            .DEVICE_FAMILY (DEVICE_FAMILY),
            .DBG_PARK_LOOP_OFFSET (DBG_PARK_LOOP_OFFSET),
            .USE_RESET_REQ (USE_RESET_REQ),
            .CSR_ENABLED (CSR_ENABLED),
            .ECC_EN (ECC_EN),
            .SHIFT_BY (SHIFT_BY),
            .OPTIMIZE_ALU_AREA (OPTIMIZE_ALU_AREA)
         ) core_inst (
               // outputs from shim
               .instr_awready (shim_instr_awready),
               .instr_wready  (shim_instr_wready), 
               .instr_bvalid  (shim_instr_bvalid),
               .instr_bresp   (shim_instr_bresp),
               .instr_arready (shim_instr_arready),

               .data_arready  (shim_data_arready),
               .data_awready  (shim_data_awready), 
               .data_wready   (shim_data_wready), 
               .data_bresp    (shim_data_bresp),

               .clk           (clk),
               .reset         (reset),
               .reset_req     (reset_req),
               .reset_req_ack (reset_req_ack),

               .instr_awaddr  (),   // outputs unconnected 
               .instr_awprot  (),   // outputs unconnected 
               .instr_awvalid (),   // outputs unconnected 
               .instr_awsize  (),   // outputs unconnected 

               .instr_wvalid  (),   // outputs unconnected
               .instr_wdata   (),   // outputs unconnected
               .instr_wstrb   (),   // outputs unconnected
               .instr_wlast   (),   // outputs unconnected

               .instr_bready  (),   // outputs unconnected

               .instr_araddr  (shim_instr_araddr),
               .instr_arprot  (),   // outputs unconnected
               .instr_arvalid (shim_instr_arvalid),
               .instr_arsize  (),   // outputs unconnected

               .instr_rdata   (shim_instr_rdata),
               .instr_rvalid  (shim_instr_rvalid),
               .instr_rresp   (shim_instr_rresp),
               .instr_rready  (),   // outputs unconnected

               .data_awaddr   (),   // outputs unconnected
               .data_awprot   (),   // outputs unconnected
               .data_awvalid  (shim_data_awvalid),
               .data_awsize   (),   // outputs unconnected

               .data_wvalid   (),   // outputs unconnected
               .data_wdata    (shim_data_wdata),
               .data_wstrb    (shim_data_wstrb),
               .data_wlast    (),   // outputs unconnected

               .data_bvalid   (shim_data_bvalid),
               .data_bready   (),   // outputs unconnected

               .data_araddr   (shim_data_araddr),
               .data_arprot   (),   // outputs unconnected
               .data_arvalid  (shim_data_arvalid),
               .data_arsize   (),   // outputs unconnected

               .data_rdata    (shim_data_rdata),
               .data_rvalid   (shim_data_rvalid),
               .data_rresp    (shim_data_rresp),
               .data_rready   (),   // outputs unconnected

               .irq_timer     (irq_timer),
               .irq_sw        (irq_sw),
               .irq_plat_vec  (irq_plat_vec),
               .irq_ext       (irq_ext),
               .irq_debug     (irq_debug),

               .core_ecc_status  (core_ecc_status),
               .core_ecc_src     (core_ecc_src)
         );


endmodule

