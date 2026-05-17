iverilog -o sim.vvp \
    sources/ex_stage.v \
    sources/alu.v \
    sources/conv.v \
    testbenches/ex_stage_tb.v

vvp sim.vvp

gtkwave simulation.vcd