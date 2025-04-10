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


// $Id: //acds/rel/24.1std/ip/sopc/components/primitives/altera_std_synchronizer/altera_std_synchronizer_bundle.v#1 $
// $Revision: #1 $
// $Date: 2023/12/11 $
//----------------------------------------------------------------
//
// File: altera_std_synchronizer_bundle.v
//
// Abstract: Bundle of bit synchronizers. 
//           WARNING: only use this to synchronize a bundle of 
//           *independent* single bit signals or a Gray encoded 
//           bus of signals. Also remember that pulses entering 
//           the synchronizer will be swallowed upon a metastable
//           condition if the pulse width is shorter than twice
//           the synchronizing clock period.
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//----------------------------------------------------------------

module altera_std_synchronizer_bundle(
				     clk,
				     reset_n,
				     din,
				     dout
				     );
   parameter width = 1;
   parameter depth = 3;   
   
   input clk;
   input reset_n;
   input [width-1:0] din;
   output [width-1:0] dout;
   
   generate
      genvar i;
      for (i=0; i<width; i=i+1)
	begin : sync
	   altera_std_synchronizer #(.depth(depth))
                                   u (
				      .clk(clk), 
				      .reset_n(reset_n), 
				      .din(din[i]), 
				      .dout(dout[i])
				      );
	end
   endgenerate
   
endmodule 

