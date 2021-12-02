require_relative 'code'

def parse_ppm img_name
  puts "parsing p3 '#{img_name}'"
  lines=IO.readlines(img_name).map(&:chomp)
  magic_number=lines.shift
  raise "not P3 format !" unless magic_number=="P3"
  lines.shift while lines.first.start_with?('#')
  format=lines.shift.split.map(&:to_i)
  dynamics=lines.shift.to_i
  colors=lines.join(" ").split(" ").map(&:to_i)
  pixels=colors.each_slice(3).to_a
  puts "# pixels found: #{pixels.size}"
  pixels
end

def to_vhdl pixels
  code=Code.new
  code << "library ieee;"
  code << "use ieee.std_logic_1164.all;"
  code << "use ieee.numeric_std.all;"
  code.newline
  code << "entity image_rom is"
  code << "  generic("
  code << "    ADDR_WIDTH : natural := 19; --ceil(log2(640*480))=19"
  code << "    DATA_WIDTH : natural := 12  --RGB=4,4,4"
  code << " );"
  code << "  port ("
  code << "    addr   : in unsigned(ADDR_WIDTH-1 downto 0);"
  code << "    data   : in std_logic_vector(DATA_WIDTH-1 downto 0)"
  code << "  );"
  code << "end entity;"
  code.newline
  code << "architecture arch of image_rom is"
  code.indent=2
  code << "type rom_type is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);"
  code << "constant rom : rom_type := ("
  code.indent=2
  pixels.each_with_index do |pixel,idx|
    r,g,b=pixel
    r = r & 0xF0
    g = g & 0xF0
    b = b & 0xF0
    value = ((r << 8) + (g << 4) + b).to_s(16).rjust(4,'0')
    code << "#{idx} => x\"#{value}\","
  end
  code.indent=0
  code << ");"
  code.indent=0
  code << "begin"
  code.indent=2
  code << "data <= rom(to_integer(addr));"
  code.indent=0
  code << "end arch;"
  code
end

img_name=ARGV.first.gsub(".ppm",'')
pixels=parse_ppm(img_name+".ppm")
vhdl=to_vhdl(pixels)
puts vhdl.save_as "image_rom.vhd"
