----------------------------------------------------------------------------------
-- OV7670 -- FPGA -- VGA -- Monitor
-- The 1st revision
-- Revision :
	-- Adjustment several entities so they can fit with the top module.
	-- Generate single clock modificator.
-- Credit:
	-- Thanks to Mike Field for Registers Reference
-- Your design might has diffent pin assignment.
-- Discuss with me by email : Jason Danny Setiawan [jasondannysetiawan@gmail.com]
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
	Port	(
		clk100	   : in STD_LOGIC; -- Crystal Oscilator 100MHz
		---------------------------------------------------------
		-- switches & buttons
		---------------------------------------------------------
		button_d	 : in STD_LOGIC; -- Push Button
		---------------------------------------------------------
		-- LEDs for monitoring
		---------------------------------------------------------
		led        : out STD_LOGIC_vector(15 downto 0);
		-- 0 : Indicates configuration has been done
		---------------------------------------------------------
		-- OV7670
		---------------------------------------------------------
		ov7670_pclk  : in  STD_LOGIC;
		ov7670_xclk  : out STD_LOGIC;
		ov7670_vsync : in  STD_LOGIC;
		ov7670_href  : in  STD_LOGIC;
		ov7670_data  : in  STD_LOGIC_vector(7 downto 0);
		ov7670_sioc  : out STD_LOGIC;
		ov7670_siod  : inout STD_LOGIC;
		ov7670_pwdn  : out STD_LOGIC;
		ov7670_reset : out STD_LOGIC;
		---------------------------------------------------------
		--VGA
		---------------------------------------------------------
		vga_hsync : out STD_LOGIC; --T4
		vga_vsync : out STD_LOGIC; --U3
		vga_rgb	  : out STD_LOGIC_VECTOR(11 downto 0)
	);
end top;

architecture structural of top is

	signal clk25 : STD_LOGIC;
	signal clk50 : STD_LOGIC;
	signal resend : STD_LOGIC;

	-- RAM
	signal wren : STD_LOGIC;
	signal wr_d: STD_LOGIC_VECTOR(11 downto 0);
	signal wr_a: STD_LOGIC_VECTOR(14 downto 0);
	signal rd_d: STD_LOGIC_VECTOR(11 downto 0);
	signal rd_a: STD_LOGIC_VECTOR(14 downto 0);

	--VGA
	signal active : STD_LOGIC;
	signal vga_vsync_sig : STD_LOGIC;

	-- LED monitoring
	signal conf_done : std_logic;
begin

	led(0) <= conf_done;

	inst_clk25: entity work.clk25gen
		port map(
			clk100 => clk100,
			clk50  => clk50,
			clk25  => clk25);

	inst_debounce: entity work.debounce_circuit
		port map(
			clk    => clk50,
			input  => button_d,
			output => resend);

	inst_ov7670contr: entity work.ov7670_controller
		port map(
			clk       => clk50,
			resend    => resend,
			sioc      => ov7670_sioc,
			siod      => ov7670_siod,
			conf_done => conf_done,
			pwdn      => ov7670_pwdn,
			reset     => ov7670_reset,
			xclk_in   => clk25,
			xclk_out  => ov7670_xclk);

	inst_ov7670capt: entity work.ov7670_capture
		port map(
			pclk  => ov7670_pclk,
			vsync => ov7670_vsync,
			href  => ov7670_href,
			d     => ov7670_data,
			addr  => wr_a,
			dout  => wr_d,
			we    => wren);

	frame_buffer : entity work.dual_port_dual_clock_ram
		generic map(
			ADDR_WIDTH => 15, --15,
			DATA_WIDTH => 12  --16
		)
		port map(
			clka   => ov7670_pclk,
			clkb   => clk25,
			we     => wren,
			addr_a => wr_a,
			addr_b => rd_a,
			din_a  => wr_d,
			dout_a => open,
			dout_b => rd_d
		);

	inst_addrgen : entity work.address_generator
		port map(
			clk25   => clk25,
			enable  => active,
			vsync   => vga_vsync_sig,
			address => rd_a
		);

	inst_imagegen : entity work.vga_imagegenerator
		port map(
			Data_in     => rd_d,
			active_area => active,
			RGB_out     => vga_rgb
		);

	inst_vgatiming : entity work.VGA_timing_synch
		port map(
			clk25      => clk25,
			Hsync      => vga_hsync,
			Vsync      => vga_vsync_sig,
			activeArea => active
		);

	vga_vsync <= vga_vsync_sig;

end structural;
