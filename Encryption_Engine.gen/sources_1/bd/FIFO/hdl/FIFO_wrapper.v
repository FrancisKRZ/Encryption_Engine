//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
//Date        : Sat Jan 18 17:44:02 2025
//Host        : kry-atp running 64-bit unknown
//Command     : generate_target FIFO_wrapper.bd
//Design      : FIFO_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module FIFO_wrapper
   (almost_empty_0,
    almost_full_0,
    din_0,
    dout_0,
    empty_0,
    full_0,
    rd_en_0,
    reset,
    sys_clock,
    wr_en_0);
  output almost_empty_0;
  output almost_full_0;
  input [15:0]din_0;
  output [15:0]dout_0;
  output empty_0;
  output full_0;
  input rd_en_0;
  input reset;
  input sys_clock;
  input wr_en_0;

  wire almost_empty_0;
  wire almost_full_0;
  wire [15:0]din_0;
  wire [15:0]dout_0;
  wire empty_0;
  wire full_0;
  wire rd_en_0;
  wire reset;
  wire sys_clock;
  wire wr_en_0;

  FIFO FIFO_i
       (.almost_empty_0(almost_empty_0),
        .almost_full_0(almost_full_0),
        .din_0(din_0),
        .dout_0(dout_0),
        .empty_0(empty_0),
        .full_0(full_0),
        .rd_en_0(rd_en_0),
        .reset(reset),
        .sys_clock(sys_clock),
        .wr_en_0(wr_en_0));
endmodule
