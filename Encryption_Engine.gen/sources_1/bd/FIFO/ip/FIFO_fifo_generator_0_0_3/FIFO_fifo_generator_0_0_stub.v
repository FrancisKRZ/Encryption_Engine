// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Sat Jan 18 17:59:19 2025
// Host        : kry-atp running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/kryozek/Shrine/FPGA/Encryption_Engine/Encryption_Engine.gen/sources_1/bd/FIFO/ip/FIFO_fifo_generator_0_0_3/FIFO_fifo_generator_0_0_stub.v
// Design      : FIFO_fifo_generator_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_10,Vivado 2024.1" *)
module FIFO_fifo_generator_0_0(clk, srst, din, wr_en, rd_en, dout, full, almost_full, 
  empty, almost_empty)
/* synthesis syn_black_box black_box_pad_pin="srst,din[15:0],wr_en,rd_en,dout[15:0],full,almost_full,empty,almost_empty" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input srst;
  input [15:0]din;
  input wr_en;
  input rd_en;
  output [15:0]dout;
  output full;
  output almost_full;
  output empty;
  output almost_empty;
endmodule
