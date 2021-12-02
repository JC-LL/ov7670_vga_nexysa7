---------------------------------------------------------
-- This entity synchronize hsync and vsync to vga
-- Thanks to Pong P. Chu for creating basic things.
--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_timing_synch is
  port (
    clk25      : in  std_logic;
    hsync      : out std_logic;
    vsync      : out std_logic;
    active_area : out std_logic);
end vga_timing_synch;

architecture Behavioral of VGA_timing_synch is

  constant HD : integer := 640;
  constant HF : integer := 16;
  constant HB : integer := 48;
  constant HR : integer := 96;
  constant HP : integer := HD + HF + HB + HR - 1;

  constant VD : integer := 480;
  constant VF : integer := 10;
  constant VB : integer := 33;
  constant VR : integer := 2;
  constant VP : integer := VD + VF + VB + VR - 1;

  signal hcnt,vcnt : integer range 0 to 1023 := 0;

begin

  count_proc : process(clk25)
  begin
		if rising_edge(clk25) then
			if hcnt = HP then
				hcnt <= 0;
				if vcnt = VP then
					vcnt <= 0;
				else
					vcnt <= vcnt + 1;
				end if;
			else
				hcnt <= hcnt +1;
			end if;
		end if;
  end process count_proc;

  hsync_gen : process(clk25)
  begin
  	if rising_edge(clk25) then
  		if hcnt >= (HD+HF) and hcnt <= (HD+HF+HR-1) then
  			hsync <= '0';
  		else
  			hsync <= '1';
  		end if;
  	end if;
  end process hsync_gen;

  vsync_gen : process(clk25)
  begin
  	if rising_edge(clk25) then
  		if vcnt >= (VD + VF) and vcnt <= (VD + VF + VR - 1) then
  			vsync <= '0';
  		else
  			vsync <= '1';
  		end if;
  	end if;
  end process vsync_gen;

  -- 4*160=640 ; 4*120=480
  active_area <= '1' when (hcnt < 160) and (vcnt < 120) else '0';
  --active_area <= '1' when (hcnt < HD) and (vcnt < VD) else '0';

end Behavioral;
