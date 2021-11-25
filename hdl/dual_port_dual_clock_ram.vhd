library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity dual_port_dual_clock_ram is
	generic(
			ADDR_WIDTH: integer:= 19;
			DATA_WIDTH : integer :=12
	);
  port (
			clka,clkb:in std_logic;
		  we:in std_logic;
			addr_a,addr_b:in std_logic_vector(ADDR_WIDTH-1 downto 0) ;
			din_a:in std_logic_vector(DATA_WIDTH-1 downto 0);
			dout_a,dout_b: out std_logic_vector(DATA_WIDTH-1 downto 0)
  ) ;
end entity dual_port_dual_clock_ram;

architecture arch of dual_port_dual_clock_ram is
	subtype data_type is std_logic_vector(DATA_WIDTH-1 downto 0);
	constant MAX_ADDR :natural := 2**ADDR_WIDTH-1;
	type ram_type is array (0 to MAX_ADDR) of  data_type;
	signal ram:ram_type := (others=>(others=>'1'));
	signal addr_a_reg,addr_b_reg:std_logic_vector(ADDR_WIDTH-1 downto 0) ;
begin
	process(clka)
	begin
      if rising_edge(clka) then
			if we='1' then
				ram(to_integer(unsigned(addr_a)))<= din_a;
			end if;
			addr_a_reg<= addr_a;
		end if;
	end process;

    process( clkb)
	begin
      if rising_edge(clkb) then
			addr_b_reg<= addr_b;
		end if;
	end process ; --

	dout_a<=ram(to_integer(unsigned(addr_a_reg)));
	dout_b<=ram(to_integer(unsigned(addr_b_reg )));
end architecture ; -- arch
