read_verilog yosys_synth/riscv_netlist.v

read_liberty /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130B/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

link_design riscv_top

# Get all primary inputs properly
set inputs [get_ports *]

set_power_activity -input_port [get_ports *] -activity 0.5
# Power report
report_power > pre_sta/power.rpt