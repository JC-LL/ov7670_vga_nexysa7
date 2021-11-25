# FPGA device
set partname "xc7a100tcsg324-1"
set xdc_constraints "./nexysa7.xdc"
# STEP#1: define the output directory area.
#
set outputDir ./SYNTH_OUTPUTS
file mkdir $outputDir
#
# STEP#2: setup design sources and constraints

read_vhdl  ../hdl/clk25gen.vhd
read_vhdl  ../hdl/debounce_circuit.vhd
read_vhdl  ../hdl/ov7670_registers.vhd
read_vhdl  ../hdl/ov7670_controller.vhd
read_vhdl  ../hdl/ov7670_capture.vhd
read_vhdl  ../hdl/ov7670_SCCB.vhd
read_vhdl  ../hdl/vga_timing.vhd
read_vhdl  ../hdl/vga_imagegenerator.vhd
read_vhdl  ../hdl/address_generator.vhd
read_vhdl  ../hdl/dual_port_dual_clock_ram.vhd
read_vhdl  ../hdl/top.vhd
read_xdc $xdc_constraints
#
# STEP#3: run synthesis, write design checkpoint, report timing,
# and utilization estimates
#
synth_design -top top -part $partname
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt

#
# Run custom script to report critical timing paths
#   reportCriticalPaths $outputDir/post_synth_critpath_report.csv
#
# STEP#4: run logic optimization, placement and physical logic optimization,
# write design checkpoint, report utilization and timing estimates
#
opt_design
#    reportCriticalPaths $outputDir/post_opt_critpath_report.csv
place_design
#     report_clock_utilization -file $outputDir/clock_util.rpt
#

write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
# STEP#5: run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
# write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true

# STEP#6: generate a bitstream
#
write_bitstream -force $outputDir/top.bit
exit
