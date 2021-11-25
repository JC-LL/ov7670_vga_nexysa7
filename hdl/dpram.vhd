library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dpram is
  port(
    CLKA    : in std_logic ;
    CLKB    : in std_logic ;
    d_in    : in std_logic_vector(7 downto 0);
    ADDR_A  : in std_logic_vector(2 downto 0);
    ADDR_B  : in std_logic_vector(2 downto 0);
    we_A    : in std_logic ;
    re_b    : in std_logic ;
    d_out   : out std_logic_vector(7 downto 0)
  );
end dpram ;

architecture behav of RAM is

  type Memory is ARRAY(7 downto 0) of std_logic_vector(7 downto 0);
  signal mem : Memory;

BEGIN

  process(CLKA)
  begin
      if(rising_edge(CLKA)) then
          if(WEA = '1') then
              mem(to_integer(signed(ADDRA))) <= d_in;
          end if;
      end if;
  end process;

  process(CLKB)
  begin
      if(rising_edge(CLKB)) then
          if ( REA = '1') then
            d_out <= mem(to_integer(signed(ADDRB))) ;
          end if;
      end if;
  end process;
end behav ;
