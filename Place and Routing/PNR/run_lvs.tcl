set setup_file "/home/asiclab/.ciel/sky130A/libs.tech/netgen/sky130A_setup.tcl"

# Load PDK standard cells FIRST into their own namespace
set pdk "/home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"

if {![file exists $pdk]} {
    puts "ERROR: PDK file not found: $pdk"
    exit 1
}

# Run LVS directly with file paths — netgen handles library loading via setup file
lvs "/home/asiclab/shams_sem10/RISCV-ASICF_LOW/PNR/riscv_top_magic.spice riscv_top" \
    "/home/asiclab/shams_sem10/RISCV-ASICF_LOW/PNR/riscv_top_yosys_wrapped.spice riscv_top" \
    $setup_file lvs_report.log -full
