transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+FIFO  -L fifo_generator_v13_2_10 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.FIFO xil_defaultlib.glbl

do {FIFO.udo}

run

endsim

quit -force
