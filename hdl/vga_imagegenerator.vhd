---------------------------------------------------------------
-- this entity prepare the color of a pixel which will be sent
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_imagegenerator is
    port ( data_in     : in  std_logic_vector (11 downto 0);
           active_area : in  std_logic;
           rgb_out     : out  std_logic_vector (11 downto 0));
end vga_imagegenerator;

architecture behavioral of vga_imagegenerator is
begin
	rgb_out <= data_in when active_area <= '1' else (others=>'0');
end behavioral;
