transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/fifo_generator_v13_2_10
vlib riviera/xil_defaultlib

vmap fifo_generator_v13_2_10 riviera/fifo_generator_v13_2_10
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work fifo_generator_v13_2_10  -incr -v2k5 "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" -l fifo_generator_v13_2_10 -l xil_defaultlib \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_10 -93  -incr \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_10  -incr -v2k5 "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" -l fifo_generator_v13_2_10 -l xil_defaultlib \
"../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/1443/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../Encryption_Engine.gen/sources_1/bd/FIFO/ipshared/3242" -l fifo_generator_v13_2_10 -l xil_defaultlib \
"../../../bd/FIFO/ip/FIFO_fifo_generator_0_0_3/sim/FIFO_fifo_generator_0_0.v" \
"../../../bd/FIFO/ip/FIFO_clk_wiz_1/FIFO_clk_wiz_1_clk_wiz.v" \
"../../../bd/FIFO/ip/FIFO_clk_wiz_1/FIFO_clk_wiz_1.v" \
"../../../bd/FIFO/sim/FIFO.v" \

vlog -work xil_defaultlib \
"glbl.v"

