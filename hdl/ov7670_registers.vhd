----------------------------------------------------------------------------------
-- 'Command' contains the registers address (8 bit) and
-- the value assigned to those registers (8 bit). Both of them is concantenated.
-- View datasheet page 10 - 19.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_registers is
  Port (
    clk     : in  STD_LOGIC;
    resend  : in  STD_LOGIC;
    advance : in  STD_LOGIC;
    command : out  STD_LOGIC_VECTOR (15 downto 0);
    done    : out  STD_LOGIC);
end ov7670_registers;

architecture Behavioral of ov7670_registers is

  signal cmd_reg : STD_LOGIC_VECTOR (15 downto 0);
  signal sequence : INTEGER := 0;

  type cmd_rom is array (0 to 55) of STD_LOGIC_VECTOR (15 downto 0);

  -- constant command_rom_cfg1 : cmd_rom :=(
  -- 	0  => x"1280", -- COM7 Reset
  -- 	1  => x"1280", -- COM7 Reset
  -- 	2  => x"1100", -- CLKRC Prescaler - F(clkin)/(2), disable double speed pll
  -- 	3  => x"1214", -- COM7 QVGA image with RGB output
  -- 	4  => x"0C04", -- COM3 enable scaling
  -- 	5  => x"3E00", -- COM14 PCLK scaling off ,3E19 to div by 2
  -- 	6  => x"4010", -- COM15 Full 0-255 output, RGB 565
  -- 	7  => x"3A04", -- TSLB Set UV ordering, do not auto-reset window
  -- 	8  => x"8C00", -- RGB444 Set RGB format
  -- 	9  => x"1714", -- HSTART HREF start (high 8 bits)
  -- 	10 => x"1802", -- HSTOP HREF stop (high 8 bits)
  -- 	11 => x"32A4", -- HREF Edge offset and low 3 bits of HSTART and HSTOP
  -- 	12 => x"1903", -- VSTART VSYNC start (high 8 bits)
  -- 	13 => x"1A7B", -- VSTOP VSYNC stop (high 8 bits)
  -- 	14 => x"030A", -- VREF VSYNC low two bits
  -- 	15 => x"703A", -- SCALING_XSC
  -- 	16 => x"7135", -- SCALING_YSC
  -- 	17 => x"7211", -- SCALING_DCWCTR
  -- 	18 => x"73f1", -- SCALING_PCLK_DIV
  -- 	19 => x"A202", -- SCALING_PCLK_DELAY PCLK scaling = 4, must match COM14
  -- 	20 => x"1500", -- COM10 Use HREF not hSYNC
  -- 	21 => x"7A20", -- SLOP
  -- 	22 => x"7B10", -- GAM1
  -- 	23 => x"7C1E", -- GAM2
  -- 	24 => x"7D35", -- GAM3
  -- 	25 => x"7E5A", -- GAM4
  -- 	26 => x"7F69", -- GAM5
  -- 	27 => x"8076", -- GAM6
  -- 	28 => x"8180", -- GAM7
  -- 	29 => x"8288", -- GAM8
  -- 	30 => x"838F", -- GAM9
  -- 	31 => x"8496", -- GAM10
  -- 	32 => x"85A3", -- GAM11
  -- 	33 => x"86AF", -- GAM12
  -- 	34 => x"87C4", -- GAM13
  -- 	35 => x"88D7", -- GAM14
  -- 	36 => x"89E8", -- GAM15
  -- 	37 => x"13E0", -- COM8 - AGC, White balance
  -- 	38 => x"0000", -- GAIN AGC
  -- 	39 => x"1000", -- AECH Exposure
  -- 	40 => x"0D40", -- COMM4 - Window Size
  -- 	41 => x"1418", -- COMM9 AGC
  -- 	42 => x"A505", -- AECGMAX banding filter step
  -- 	43 => x"2495", -- AEW AGC Stable upper limite
  -- 	44 => x"2533", -- AEB AGC Stable lower limi
  -- 	45 => x"26E3", -- VPT AGC fast mode limits
  -- 	46 => x"9F78", -- HRL High reference level
  -- 	47 => x"A068", -- LRL low reference level
  -- 	48 => x"A103", -- DSPC3 DSP control
  -- 	49 => x"A6D8", -- LPH Lower Prob High
  -- 	50 => x"A7D8", -- UPL Upper Prob Low
  -- 	51 => x"A8F0", -- TPL Total Prob Low
  -- 	52 => x"A990", -- TPH Total Prob High
  -- 	53 => x"AA94", -- NALG AEC Algo select
  -- 	54 => x"13E5", -- COM8 AGC Settings
  -- 	55 => x"FFFF");-- STOP (using WITH .. SELECT below)


    constant command_rom_cfg2 : cmd_rom :=(
      0  => x"1280",-- COM7   Reset
      1  => x"1214",-- COM7   QVGA & RGB output
      2  => x"1100",-- CLKRC  Prescaler - Fin/(1+1)e double speed pll
      3  => x"0C00",-- COM3   Lots of stuff, enable scaling, all others off
      4  => x"3E00",-- COM14  PCLK scaling off
      5  => x"8C00",-- RGB444 Set RGB format 2
      6  => x"0400",-- COM1   no CCIR601
      7  => x"4010",-- COM15  Full 0-255 output, RGB 565t window
      8  => x"3a04",-- TSLB   Set UV ordering,  do not auto-reset window
      9  => x"1438",-- COM9  - AGC Celling
      10 => x"4f40",-- MTX1  - colour conversion matrix
      11 => x"5034",-- MTX2  - colour conversion matrixART and HSTOP
      12 => x"510C",-- MTX3  - colour conversion matrix
      13 => x"5217",-- MTX4  - colour conversion matrix
      14 => x"5329",-- MTX5  - colour conversion matrix
      15 => x"5440",-- MTX6  - colour conversion matrix
      16 => x"581e",-- MTXS  - Matrix sign and auto contrast
      17 => x"3dc0",-- COM13 - Turn on GAMMA and UV Auto adjust
      18 => x"1100",-- CLKRC  Prescaler - Fin/(1+1)
      19 => x"1711",-- HSTART HREF start (high 8 bits)ust match COM14
      20 => x"1861",-- HSTOP  HREF stop (high 8 bits)
      21 => x"32A4",-- HREF   Edge offset and low 3 bits of HSTART and HSTOP
      22 => x"1903",-- VSTART VSYNC start (high 8 bits)
      23 => x"1A7b",-- VSTOP  VSYNC stop (high 8 bits)
      24 => x"030a",-- VREF   VSYNC low two bits
      25 => x"0e61",-- COM5(0x0E) 0x61
      26 => x"0f4b",-- COM6(0x0F) 0x4B
      27 => x"1602",--
      28 => x"1e37",-- MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
      29 => x"2102",
      30 => x"2291",
      31 => x"2907",
      32 => x"330b",
      33 => x"350b",
      34 => x"371d",
      35 => x"3871",
      36 => x"392a",
      37 => x"3c78",-- COM12 (0x3C) 0x78
      38 => x"4d40",
      39 => x"4e20",
      40 => x"6900",-- GFIX (0x69) 0x00
      41 => x"6b4a",
      42 => x"7410",
      43 => x"8d4f",
      44 => x"8e00",
      45 => x"8f00",
      46 => x"9000",
      47 => x"9100",
      48 => x"9600",
      49 => x"9a00",
      50 => x"b084",
      51 => x"b10c",
      52 => x"b20e",
      53 => x"b382",
      54 => x"b80a",
      55 =>  x"ffff");
begin
  command <= cmd_reg;

  with cmd_reg select done <= '1' when x"FFFF", '0' when others;

  sequence_proc : process (clk) begin
  	if rising_edge(clk) then
  		if resend = '1' then
  			sequence <= 0;
  		elsif advance = '1' then
  			sequence <= sequence + 1;
  		end if;

  		cmd_reg <= command_rom_cfg2(sequence);
  		if sequence > 55 then
  			cmd_reg <= x"FFFF";
  		end if;
  	end if;
  end process sequence_proc;
end Behavioral;
