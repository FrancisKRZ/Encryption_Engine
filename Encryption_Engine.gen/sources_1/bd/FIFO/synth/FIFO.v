//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
//Date        : Sat Jan 18 17:44:02 2025
//Host        : kry-atp running 64-bit unknown
//Command     : generate_target FIFO.bd
//Design      : FIFO
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "FIFO,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=FIFO,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=12,da_clkrst_cnt=7,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "FIFO.hwdef" *) 
module FIFO
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLOCK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLOCK, CLK_DOMAIN FIFO_sys_clock, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input sys_clock;
  input wr_en_0;

  wire clk_wiz_clk_out1;
  wire [15:0]din_0_1;
  wire fifo_generator_0_almost_empty;
  wire fifo_generator_0_almost_full;
  wire [15:0]fifo_generator_0_dout;
  wire fifo_generator_0_empty;
  wire fifo_generator_0_full;
  wire rd_en_0_1;
  wire reset_1;
  wire sys_clock_1;
  wire wr_en_0_1;

  assign almost_empty_0 = fifo_generator_0_almost_empty;
  assign almost_full_0 = fifo_generator_0_almost_full;
  assign din_0_1 = din_0[15:0];
  assign dout_0[15:0] = fifo_generator_0_dout;
  assign empty_0 = fifo_generator_0_empty;
  assign full_0 = fifo_generator_0_full;
  assign rd_en_0_1 = rd_en_0;
  assign reset_1 = reset;
  assign sys_clock_1 = sys_clock;
  assign wr_en_0_1 = wr_en_0;
  FIFO_clk_wiz_1 clk_wiz
       (.clk_in1(sys_clock_1),
        .clk_out1(clk_wiz_clk_out1),
        .reset(reset_1));
  FIFO_fifo_generator_0_0 fifo_generator_0
       (.almost_empty(fifo_generator_0_almost_empty),
        .almost_full(fifo_generator_0_almost_full),
        .clk(clk_wiz_clk_out1),
        .din(din_0_1),
        .dout(fifo_generator_0_dout),
        .empty(fifo_generator_0_empty),
        .full(fifo_generator_0_full),
        .rd_en(rd_en_0_1),
        .srst(1'b0),
        .wr_en(wr_en_0_1));
endmodule
