library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity address_generator is
  generic (
    NB_BITS_ADDR : natural;
    XVGA_WIDTH : natural  := 160;
    XVGA_HEIGHT : natural := 120
  );
  Port (
    clk25 : in STD_LOGIC;
    enable : in STD_LOGIC;
    vsync : in STD_LOGIC;
    address : out STD_LOGIC_VECTOR (NB_BITS_ADDR-1 downto 0)
  );
end address_generator;


architecture Behavioral of address_generator is

  signal addr: unsigned(address'range) := (others => '0');

begin

  address <= std_logic_vector(addr);
  --address <= "00" & std_logic_vector(addr(NB_BITS_ADDR-1 downto 2));

  process (clk25) begin
  	if rising_edge (clk25) then
  		if (enable='1') then
  			if (addr < XVGA_WIDTH * XVGA_HEIGHT) then
  				addr <= addr + 1 ;
  			end if;
  		end if;

  		if vsync = '0' then
  			addr <= (others => '0');
  		end if;
  	end if;
  end process;

end Behavioral;
