//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
//Date        : Sat Jan 18 17:24:59 2025
//Host        : kry-atp running 64-bit unknown
//Command     : generate_target FIFO_wrapper.bd
//Design      : FIFO_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module FIFO_wrapper
   (reset,
    sys_clock);
  input reset;
  input sys_clock;

  wire reset;
  wire sys_clock;

  FIFO FIFO_i
       (.reset(reset),
        .sys_clock(sys_clock));
endmodule
