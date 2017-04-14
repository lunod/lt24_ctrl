---------------------------------------------------------------------------
-- This file is part of lt24ctrl, a video controler IP core for Terrasic
-- LT24 LCD display
-- Copyright (C) 2017 Ludovic Noury <ludovic.noury@esiee.fr>
-- 
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------
-- Sources :
--  * Altera single port ROM template : https://www.altera.com/support/support-resources/design-examples/design-software/vhdl/vhd-single-port-rom.html
--  * Terrasic LT24 exemple C code for Nios/2 (LT24 C initialization sequence
--    converted to hardware ROM)
--  * TFT LCD Display + Camera (René Beuchat, EPFL) : additional comments in
--  ROM initialization (comments ending with "*1" in rom_init_lt24.vhd) :
--  http://moodle.epfl.ch/pluginfile.php/1589089/mod_resource/content/3/TFT%20LCD%20Display-Camera_2a.pdf
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------
entity rom_init_lt24 is

  port(addr : in  std_logic_vector(6 downto 0);
       clk  : in  std_logic;
       q    : out std_logic_vector(16 downto 0));

end entity;
---------------------------------------------------------------------------
architecture rtl of rom_init_lt24 is

  -- Build a 2-D array type for the ROM
  -- word size = q size, number of words = 2^nbits(addr)
  subtype word_t is std_logic_vector(q'range);
  type memory_t is array(0 to (2**addr'length) - 1) of word_t;

  function init_rom
    return memory_t is
    variable tmp : memory_t := (others => (others => '0'));
  begin
    -- Q[16]='1' if Q[15..0] destination is LT24 command register
    -- Q[16]='0' if Q[15..0] destination is LT24 data register

    -- Exit Sleep
    tmp(000) := '0' & x"0011"; -- LCD_WR_REG(0x0011); 
    -- Power Control B *1
    tmp(001) := '0' & x"00CF"; -- LCD_WR_REG(0x00CF);
    tmp(002) := '1' & x"0000"; --     LCD_WR_DATA(0x0000); // Always 0x00 *1
    tmp(003) := '1' & x"0081"; --     LCD_WR_DATA(0x0081);
    tmp(004) := '1' & x"00C9"; --     LCD_WR_DATA(0X00c0);
    -- Power on sequence control *1
    tmp(005) := '0' & x"00ED"; -- LCD_WR_REG(0x00ED);
    tmp(006) := '1' & x"0064"; --     LCD_WR_DATA(0x0064); // Soft Start keep 1
    tmp(007) := '1' & x"0003"; --     LCD_WR_DATA(0x0003); // frame *1
    tmp(008) := '1' & x"0012"; --     LCD_WR_DATA(0X0012);
    tmp(009) := '1' & x"0081"; --     LCD_WR_DATA(0X0081);
    -- TODO : Why 2 times ? Only once should be enough => test if need to optimize
    -- (just one call in *1)
    tmp(010) := '0' & x"00ED"; -- LCD_WR_REG(0x00ED);
    tmp(011) := '1' & x"0064"; --     LCD_WR_DATA(0x0064);
    tmp(012) := '1' & x"0003"; --     LCD_WR_DATA(0x0003);
    tmp(013) := '1' & x"0012"; --     LCD_WR_DATA(0X0012);
    tmp(014) := '1' & x"0081"; --     LCD_WR_DATA(0X0081);
    -- Driver timing control A *1
    tmp(015) := '0' & x"00E8"; -- LCD_WR_REG(0x00E8);
    tmp(016) := '1' & x"0085"; --     LCD_WR_DATA(0x0085);
    tmp(017) := '1' & x"0001"; --     LCD_WR_DATA(0x0001);
    tmp(018) := '1' & x"0798"; --     LCD_WR_DATA(0x00798);
    -- Power control A *1
    tmp(019) := '0' & x"00CB"; -- LCD_WR_REG(0x00CB);
    tmp(020) := '1' & x"0039"; --    LCD_WR_DATA(0x0039);
    tmp(021) := '1' & x"002C"; --    LCD_WR_DATA(0x002C);
    tmp(022) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(023) := '1' & x"0034"; --    LCD_WR_DATA(0x0034);
    tmp(024) := '1' & x"0002"; --    LCD_WR_DATA(0x0002);
    -- Pump ratio control *1
    tmp(025) := '0' & x"00F7"; -- LCD_WR_REG(0x00F7);
    tmp(026) := '1' & x"0020"; --    LCD_WR_DATA(0x0020);
    -- Driver timming control B *1
    tmp(027) := '0' & x"00EA"; -- LCD_WR_REG(0x00EA);
    tmp(028) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(029) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    -- Frame control (in normal mode) *1
    tmp(030) := '0' & x"00B1"; -- LCD_WR_REG(0x00B1);
    tmp(031) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(032) := '1' & x"001b"; --    LCD_WR_DATA(0x001b);
    -- Display function control *1
    tmp(033) := '0' & x"00B6"; -- LCD_WR_REG(0x00B6);
    tmp(034) := '1' & x"000A"; --    LCD_WR_DATA(0x000A);
    tmp(035) := '1' & x"00A2"; --    LCD_WR_DATA(0x00A2);
    -- Power control 1
    tmp(036) := '0' & x"00C0"; -- LCD_WR_REG(0x00C0);
    tmp(037) := '1' & x"0005"; --    LCD_WR_DATA(0x0005); // VRH[5:0]
    -- Power control 2
    tmp(038) := '0' & x"00C1"; -- LCD_WR_REG(0x00C1);
    tmp(039) := '1' & x"0011"; --    LCD_WR_DATA(0x0011); // SAP[2:0]";BT[3:0]
    -- VCM control 1
    tmp(040) := '0' & x"00C5"; -- LCD_WR_REG(0x00C5);
    tmp(041) := '1' & x"0045"; --    LCD_WR_DATA(0x0045); // 3F
    tmp(042) := '1' & x"0045"; --    LCD_WR_DATA(0x0045); // 3C
    -- VCM control 2
    tmp(043) := '0' & x"00C7"; -- LCD_WR_REG(0x00C7);
    tmp(044) := '1' & x"00a2"; --    LCD_WR_DATA(0X00a2);
    -- Memory Access Control
    tmp(045) := '0' & x"0036"; -- LCD_WR_REG(0x0036);
    tmp(046) := '1' & x"0008"; --    LCD_WR_DATA(0x0008); // BGR order *1
    -- Enable 3G *1
    tmp(047) := '0' & x"00F2"; -- LCD_WR_REG(0x00F2);    // 3Gamma Function Disable
    tmp(048) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    -- Gama set *1
    tmp(049) := '0' & x"0026"; -- LCD_WR_REG(0x0026);    // Gamma curve selected
    tmp(050) := '1' & x"0001"; --    LCD_WR_DATA(0x0001);
    -- Positive gamma correction, set gamma *1
    tmp(051) := '0' & x"00E0"; -- LCD_WR_REG(0x00E0);
    tmp(052) := '1' & x"000F"; --    LCD_WR_DATA(0x000F);
    tmp(053) := '1' & x"0026"; --    LCD_WR_DATA(0x0026);
    tmp(054) := '1' & x"0024"; --    LCD_WR_DATA(0x0024);
    tmp(055) := '1' & x"000b"; --    LCD_WR_DATA(0x000b);
    tmp(056) := '1' & x"000E"; --    LCD_WR_DATA(0x000E);
    tmp(057) := '1' & x"0008"; --    LCD_WR_DATA(0x0008);
    tmp(058) := '1' & x"004b"; --    LCD_WR_DATA(0x004b);
    TMP(059) := '1' & x"00a8"; --    LCD_WR_DATA(0X00a8);
    tmp(060) := '1' & x"003b"; --    LCD_WR_DATA(0x003b);
    tmp(061) := '1' & x"000a"; --    LCD_WR_DATA(0x000a);
    tmp(062) := '1' & x"0014"; --    LCD_WR_DATA(0x0014);
    tmp(063) := '1' & x"0006"; --    LCD_WR_DATA(0x0006);
    tmp(064) := '1' & x"0010"; --    LCD_WR_DATA(0x0010);
    tmp(065) := '1' & x"0009"; --    LCD_WR_DATA(0x0009);
    tmp(066) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    -- Negative gamma correction, set gamma *1
    tmp(067) := '0' & X"00E1"; --    LCD_WR_REG(0X00E1); // Set Gamma
    tmp(068) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(069) := '1' & x"001c"; --    LCD_WR_DATA(0x001c);
    tmp(070) := '1' & x"0020"; --    LCD_WR_DATA(0x0020);
    tmp(071) := '1' & x"0004"; --    LCD_WR_DATA(0x0004);
    tmp(072) := '1' & x"0010"; --    LCD_WR_DATA(0x0010);
    tmp(073) := '1' & x"0008"; --    LCD_WR_DATA(0x0008);
    tmp(074) := '1' & x"0034"; --    LCD_WR_DATA(0x0034);
    tmp(075) := '1' & x"0047"; --    LCD_WR_DATA(0x0047);
    tmp(076) := '1' & x"0044"; --    LCD_WR_DATA(0x0044);
    tmp(077) := '1' & x"0005"; --    LCD_WR_DATA(0x0005);
    tmp(078) := '1' & x"000b"; --    LCD_WR_DATA(0x000b);
    tmp(079) := '1' & x"0009"; --    LCD_WR_DATA(0x0009);
    tmp(080) := '1' & x"002f"; --    LCD_WR_DATA(0x002f);
    tmp(081) := '1' & x"0036"; --    LCD_WR_DATA(0x0036);
    tmp(082) := '1' & x"000f"; --    LCD_WR_DATA(0x000f);
    -- Column address set *1
    tmp(083) := '0' & x"002A"; -- LCD_WR_REG(0x002A);
    tmp(084) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(085) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(086) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(087) := '1' & x"00ef"; --    LCD_WR_DATA(0x00ef);
    -- Page address set *1
    tmp(088) := '0' & x"002B"; -- LCD_WR_REG(0x002B);
    tmp(089) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(090) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    tmp(091) := '1' & x"0001"; --    LCD_WR_DATA(0x0001);
    tmp(092) := '1' & x"003f"; --    LCD_WR_DATA(0x003f);
    -- COLMOD: pixel format set *1
    tmp(093) := '0' & x"003A"; -- LCD_WR_REG(0x003A);
    tmp(094) := '1' & x"0055"; --    LCD_WR_DATA(0x0055);
    -- Interface control *1
    tmp(095) := '0' & x"00f6"; -- LCD_WR_REG(0x00f6);
    tmp(096) := '1' & x"0001"; --    LCD_WR_DATA(0x0001);
    tmp(097) := '1' & x"0030"; --    LCD_WR_DATA(0x0030);
    tmp(098) := '1' & x"0000"; --    LCD_WR_DATA(0x0000);
    -- display on
    tmp(099) := '0' & x"0029"; -- LCD_WR_REG(0x0029);
    -- 0x2C   
    tmp(100) := '0' & x"002c"; -- LCD_WR_REG(0x002c);

    return tmp;
  end init_rom;

  -- Declare the ROM signal and specify a default value. Quartus II
  -- will create a memory initialization file (.mif) based on the 
  -- default value.
  signal rom : memory_t := init_rom;

begin

  process(clk)
  begin
    if(rising_edge(clk)) then
      q <= rom(to_integer(unsigned(addr)));
    end if;
  end process;

end rtl;
---------------------------------------------------------------------------
