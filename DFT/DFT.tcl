fault synth   -l /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib   -t risc_top   -o netlist.v   sources/riscv_top.v

fault cut netlist.v   --dff sky130_fd_sc_hd__dfxtp_1   --dff sky130_fd_sc_hd__dfrtp_1   --clock clk   --reset reset

source DFT/build_cell_model.sh netlist.v custom_cells.v

fault atpg \
   -c custom_cells.v \
   -v 100 -r 50 -m 95 \
   --ceiling 1000 \
   netlist.v.cut.v \
  --clock clk \
  --reset rst_n \
   --bypassing VDD=1 \
   --bypassing GND=0

   
fault chain \
   -l /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib \
   -c custom_cells.v \
   -o netlist.v.chained.v \
   --clock clk \
   --reset rst_n \
   netlist.v \
   --dff sky130_fd_sc_hd__dfxtp_1 \
   --dff sky130_fd_sc_hd__dfrtp_1 \
   --bypassing VDD=1 \
   --bypassing GND=0