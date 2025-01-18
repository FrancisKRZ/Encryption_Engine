vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/fifo_generator_v13_2_10
vlib modelsim_lib/msim/xil_defaultlib

vmap fifo_generator_v13_2_10 modelsim_lib/msim/fifo_generator_v13_2_10
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work fifo_generator_v13_2_10 -64 -incr -mfcu  "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_10 -64 -93  \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_10 -64 -incr -mfcu  "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" \
"../../../bd/FIFO/ip/FIFO_fifo_generator_0_0_3/sim/FIFO_fifo_generator_0_0.v" \
"../../../bd/FIFO/ip/FIFO_clk_wiz_1/FIFO_clk_wiz_1_clk_wiz.v" \
"../../../bd/FIFO/ip/FIFO_clk_wiz_1/FIFO_clk_wiz_1.v" \
"../../../bd/FIFO/sim/FIFO.v" \

vlog -work xil_defaultlib \
"glbl.v"

