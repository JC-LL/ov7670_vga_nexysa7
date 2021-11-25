echo "cleaning..."
rm -rf *.cf *.o

echo "analyzing..."
ghdl -a ../hdl/clk25gen.vhd
ghdl -a ../hdl/debounce_circuit.vhd

ghdl -a ../hdl/ov7670_registers.vhd
ghdl -a ../hdl/ov7670_controller.vhd
ghdl -a ../hdl/ov7670_capture.vhd
ghdl -a ../hdl/ov7670_SCCB.vhd

ghdl -a ../hdl/vga_timing.vhd
ghdl -a ../hdl/vga_imagegenerator.vhd
ghdl -a ../hdl/address_generator.vhd

ghdl -a ../hdl/dual_port_dual_clock_ram.vhd

ghdl -a ../hdl/top.vhd
