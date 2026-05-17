# ==========================================
# main_flow.tcl - FIXED FOR STA-0562
# ==========================================
read_lef /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_verilog yosys_synth/riscv_netlist.v
read_liberty /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
link_design riscv_top
read_sdc yosys_synth/constraints.sdc

# ==========================================
# Initial timing check before physical implementation
# ==========================================
report_checks -path_delay max -format full > PNR/openroad_initial_setup.rpt
report_checks -path_delay min -format full > PNR/openroad_initial_hold.rpt

# ==========================================
# TASK 1: FLOORPLAN & PLACEMENT
# ==========================================
initialize_floorplan \
    -utilization 10 \
    -aspect_ratio 1.0 \
    -core_space 100.0 \
    -site unithd
make_tracks
place_pins -hor_layers met3 -ver_layers met4 -random

set db_block [ord::get_db_block]
set net_one [$db_block findNet "one_"]
if {$net_one != "NULL"} { $net_one setSpecial }
set net_zero [$db_block findNet "zero_"]
if {$net_zero != "NULL"} { $net_zero setSpecial }

# PDN
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {VPWR} -power
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {VGND} -ground
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {VPB}
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {VNB}
global_connect
set_voltage_domain -name CORE -power VDD -ground VSS
define_pdn_grid -name grid -voltage_domains CORE
add_pdn_stripe -grid grid -layer met1 -width 0.48 -followpins
pdngen

tapcell \
    -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1 \
    -endcap_master  sky130_fd_sc_hd__decap_4 \
    -distance 13

# Placement
set_placement_padding -global -left 6 -right 6
global_placement -density 0.2

# Estimate parasitics before repair to stop RSZ-0021 warning
estimate_parasitics -placement
repair_design
detailed_placement -max_displacement {500 500}

write_def 1_placement.def
write_db  1_placement.odb

# ==========================================
# TASK 2: CLOCK TREE SYNTHESIS (CTS)
# ==========================================
set_wire_rc -signal -layer met2
set_wire_rc -clock  -layer met3

catch { report_clock_skew  > PNR/pre_cts_clock_skew.rpt  }
catch { report_clock_latency > PNR/pre_cts_clock_latency.rpt }

clock_tree_synthesis \
    -root_buf sky130_fd_sc_hd__clkbuf_16 \
    -buf_list "sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_1"

catch { report_clock_skew  > PNR/post_cts_clock_skew.rpt  }
catch { report_clock_latency > PNR/post_cts_clock_latency.rpt }

set_propagated_clock [all_clocks]
repair_design
detailed_placement -max_displacement {500 500}

# ==========================================
# TASK 3: Global & Detailed Routing
# ==========================================

set_routing_layers -signal met1-met5
global_route

catch { report_global_route_congestion > congestion.rpt }

set_thread_count 8
detailed_route -output_drc drc.rpt -verbose 1

filler_placement "sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8"

extract_parasitics -ext_model_file "/home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/rules.openrcx.sky130A.min.calibre"

# ==========================================
# Post-layout timing reports
# ==========================================
report_checks -path_delay max -format full > PNR/post_setup.rpt
report_checks -path_delay min -format full > PNR/post_hold.rpt

catch { report_wns                  > PNR/post_timing_summary.rpt }
catch { report_tns                 >> PNR/post_timing_summary.rpt }
catch { report_worst_slack -max    >> PNR/post_timing_summary.rpt }
catch { report_worst_slack -min    >> PNR/post_timing_summary.rpt }

# ==========================================
# Post-layout power activity
# ==========================================
set_power_activity -input_port [get_ports {
    rst_n
    stall_i
    flush_i
    redirect_valid_i
    redirect_pc_i
    alu_op
    alu_src_b_sel
    conv_start
    conv_init
}] -activity 0.01
set_power_activity -input_port [get_ports clk]     -activity 1.0

# ==========================================
# Post-layout power and area reports
# ==========================================
report_power > PNR/post_power.rpt
catch { report_design_area > PNR/post_area.rpt }

# ==========================================
# Final Deliverables
# ==========================================
write_db    PNR/final_layout.odb
write_def   PNR/final_layout.def
write_verilog PNR/final_layout.v
write_spef  PNR/final_layout.spef

# Extra copies (matching original naming convention)
write_def   PNR/out.def
write_verilog PNR/out.v
write_spef  PNR/out.spef
