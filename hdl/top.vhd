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
		clk100	   : in std_logic; -- Crystal Oscilator 100MHz
		---------------------------------------------------------
		-- switches & buttons
		---------------------------------------------------------
		button_d	 : in std_logic; -- Push Button
		switch     : in std_logic; --to switch between camera and image ROM.
		---------------------------------------------------------
		-- LEDs for monitoring
		---------------------------------------------------------
		led        : out std_logic_vector(1 downto 0);
		-- 0 : Indicates configuration has been done
		---------------------------------------------------------
		-- OV7670
		---------------------------------------------------------
		ov7670_pclk  : in  std_logic;
		ov7670_xclk  : out std_logic;
		ov7670_vsync : in  std_logic;
		ov7670_href  : in  std_logic;
		ov7670_data  : in  std_logic_vector(7 downto 0);
		ov7670_sioc  : out std_logic;
		ov7670_siod  : inout std_logic;
		ov7670_pwdn  : out std_logic;
		ov7670_reset : out std_logic;
		---------------------------------------------------------
		--VGA
		---------------------------------------------------------
		vga_hsync : out std_logic; --t4
		vga_vsync : out std_logic; --u3
		vga_r     : out std_logic_vector(3 downto 0);
		vga_g     : out std_logic_vector(3 downto 0);
		vga_b     : out std_logic_vector(3 downto 0)

	);
end top;

architecture structural of top is

	constant NB_BITS_QVGA_ADDR : natural := 15; --2**15=32768  =~ 320*240 =  76800
	constant NB_BITS_VGA_ADDR  : natural := 19; --2**19=524288 =~ 640*480 = 307200

	constant STORED_RGB_DATA_SIZE : natural := 12;
	-- CONFIGURE here :
	constant NB_BITS_ADDR : natural := NB_BITS_QVGA_ADDR;
	--constant NB_BITS_ADDR : natural := NB_BITS_VGA_ADDR;

	signal clk25  : std_logic;
	signal clk50  : std_logic;
	signal resend : std_logic;

	-- ram
	signal wren : std_logic;
	signal wr_d: std_logic_vector(11 downto 0);
	signal rd_d: std_logic_vector(11 downto 0);
	signal wr_a: std_logic_vector(NB_BITS_ADDR-1 downto 0);
	signal rd_a: std_logic_vector(NB_BITS_ADDR-1 downto 0);

	--vga
	signal active : std_logic;
	signal vga_vsync_sig : std_logic;
	signal vga_rgb : std_logic_vector(11 downto 0);
	-- led monitoring
	signal conf_done : std_logic;
begin
	----------------------------------------------
	-- Monitoring
	----------------------------------------------
	led(0) <= conf_done;--does not appear on board ?
	led(1) <= clk25;--does not appear on board ?

	-----------------------------------------------
	inst_clk25: entity work.clk25gen
		port map(
			clk100 => clk100,
			clk50  => clk50,
			clk25  => clk25);

	resend <= button_d;

	inst_ov7670_controller: entity work.ov7670_controller
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

	inst_ov7670_capt: entity work.ov7670_capture
		generic map(NB_BITS_ADDRESS => NB_BITS_ADDR)
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
			ADDR_WIDTH => NB_BITS_ADDR, --22 to get VGA 640*480. was 15,
			DATA_WIDTH => STORED_RGB_DATA_SIZE  --3*4
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

	inst_addr_gen : entity work.address_generator
		generic map(
			NB_BITS_ADDR => NB_BITS_ADDR,
			XVGA_WIDTH   => 160,
			XVGA_HEIGHT  => 120
		)
		port map(
			clk25   => clk25,
			enable  => active,
			vsync   => vga_vsync_sig,
			address => rd_a
		);

	inst_image_gen : entity work.vga_image_generator
		port map(
			Data_in     => rd_d,
			active_area => active,
			rgb_out     => vga_rgb
		);

	inst_vga_timing : entity work.vga_timing_synch
		port map(
			clk25       => clk25,
			Hsync       => vga_hsync,
			Vsync       => vga_vsync_sig,
			active_area => active
		);

	-- img_rom : entity work.image_rom
	-- port map(
	-- 	addr => addr_rom,
	-- 	data => data_rom
	-- );
	--
	-- chu_vga : entity work.vga_sync
	-- 	port map(
	-- 		reset       => reset,
	-- 		clk         => clk50, --as for CHU
	-- 		hsync       => vga_hsync,
	-- 		vsync       => vga_vsync_sig,
	-- 		video_on    => video_on,
	-- 		p_tick      => p_tick,
	-- 		pixel_x     => pixel_x,
	-- 		pixel_y     => pixel_y
	-- 	);

	vga_vsync <= vga_vsync_sig;

	vga_r     <= vga_rgb(11 downto 8);
	vga_g     <= vga_rgb( 7 downto 4);
	vga_b     <= vga_rgb( 3 downto 0);


end structural;
