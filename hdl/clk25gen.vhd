----------------------------------------------------------------------------------
-- This entity converts 50MHz clock to 25MHz clock.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk25gen is
    Port ( clk100 : in  STD_LOGIC;
           clk50  : out  STD_LOGIC;
           clk25  : out  STD_LOGIC);
end clk25gen;

architecture Behavioral of clk25gen is
  signal clk50_i : STD_LOGIC := '0';
  signal clk25_i : STD_LOGIC := '0';
begin

  process (clk100)
  begin
		if rising_edge(clk100) then
      clk50_i <= not(clk50_i);
		end if;
	end process;

  process (clk50_i)
  begin
		if rising_edge(clk50_i) then
      clk25_i <= not(clk25_i);
		end if;
	end process;

  clk50 <=  clk50_i;
  clk25 <=  clk25_i;

end Behavioral;
