create_clock -name clk -period 40 [get_ports clk]

set_clock_transition 0.1 [get_clocks clk]
set_clock_uncertainty 0.1 [get_clocks clk]

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

set_output_delay 2.0 -clock clk [all_outputs]

set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [get_ports {
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

set_load 0.5 [all_outputs]

set_false_path -from [get_ports rst_n]