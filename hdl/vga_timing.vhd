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
    hsync      : out  std_logic;
    vsync      : out  std_logic;
    activearea : out  std_logic);
end vga_timing_synch;

architecture Behavioral of VGA_timing_synch is

  constant HD : INTEGER := 640;
  constant HF : INTEGER := 16;
  constant HB : INTEGER := 48;
  constant HR : INTEGER := 96;
  constant HP : INTEGER := HD + HF + HB + HR - 1;
  constant VD : INTEGER := 480;
  constant VF : INTEGER := 10;
  constant VB : INTEGER := 33;
  constant VR : INTEGER := 2;
  constant VP : INTEGER := VD + VF + VB + VR - 1;

  signal clk_vga,video : STD_LOGIC;
  signal hcnt,vcnt : INTEGER := 0;

begin

  clk_vga <= clk25;

  count_proc : process(clk_vga) begin
  		if rising_edge(clk_vga) then
  			if (hcnt = HP) then
  				hcnt <= 0;
  				if (vcnt = VP) then
  					vcnt <= 0;
  				else
  					vcnt <= vcnt + 1;
  				end if;
  			else
  				hcnt <= hcnt +1;
  			end if;
  		end if;
  end process count_proc;

  hsync_gen : process(clk_vga) begin
  	if rising_edge(clk_vga) then
  		if (hcnt >= (HD+HF) and hcnt <= (HD+HF+HR-1)) then
  			Hsync <= '0';
  		else
  			Hsync <= '1';
  		end if;
  	end if;
  end process hsync_gen;

  vsync_gen : process(clk_vga) begin
  	if rising_edge(clk_vga) then
  		if (vcnt >= (VD + VF) and vcnt <= (VD + VF + VR - 1)) then
  			Vsync <= '0';
  		else
  			Vsync <= '1';
  		end if;
  	end if;
  end process vsync_gen;

  -- 4*160=640 ; 4*120=480
  video <= '1' when (hcnt < 160) and (vcnt < 120) else '0';
  --video <= '1' when (hcnt < HD) and (vcnt < VD) else '0';

  activeArea <= video;

end Behavioral;
