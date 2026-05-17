read_verilog yosys_synth/riscv_netlist.v
read_liberty /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130B/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

link_design riscv_top

create_clock -name clk -period 40 [get_ports clk]

set_input_delay 2.0 -clock clk [get_ports {
    rst_n
    stall_i
    flush_i
    redirect_valid_i
    redirect_pc_i
    alu_op
    alu_src_b_sel
    conv_start
    conv_init
}]

set_false_path -from [get_ports rst_n]

set_output_delay 2.0 -clock clk [all_outputs]

set_load 0.5 [all_outputs]

report_checks -path_delay max -format full > pre_sta/setup.rpt
report_checks -path_delay min -format full > pre_sta/hold.rpt
report_wns > pre_sta/time.rpt
report_tns >> pre_sta/time.rpt