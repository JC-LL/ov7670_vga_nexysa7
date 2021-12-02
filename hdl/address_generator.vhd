library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity address_generator is
  generic (
    NB_BITS_ADDR : natural;
    XVGA_WIDTH : natural  := 160;
    XVGA_HEIGHT : natural := 120
  );
  port (
    clk25   : in  std_logic;
    enable  : in  std_logic;
    vsync   : in  std_logic;
    address : out std_logic_vector (NB_BITS_ADDR-1 downto 0)
  );
end address_generator;


architecture Behavioral of address_generator is

  signal addr: unsigned(address'range) := (others => '0');

begin

  address <= std_logic_vector(addr);
  --address <= "00" & std_logic_vector(addr(NB_BITS_ADDR-1 downto 2));

  process(clk25)
  begin
  	if rising_edge (clk25) then
      if vsync='0' then
        addr <= to_unsigned(0,NB_BITS_ADDR);
      elsif enable='1' then
  			if addr < XVGA_WIDTH * XVGA_HEIGHT then
  				addr <= addr + 1 ;
  			end if;
  		end if;
    end if;
  end process;

end Behavioral;
