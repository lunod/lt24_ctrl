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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------
entity cpt_addr_rom is

  port(clk              :  in std_logic;
       resetn           :  in std_logic;
       clr_init_rom_addr:  in std_logic;
       inc_init_rom_addr:  in std_logic;
       end_init_rom     : out std_logic;
       address          : out std_logic_vector(6 downto 0));
  
end entity cpt_addr_rom;
---------------------------------------------------------------------------
architecture rtl of cpt_addr_rom is

  constant ROM_SIZE : natural := 101;
  signal counter : unsigned(address'range);
  
begin

  update_cpt: process(clk, resetn)
  begin
    if resetn = '0' then
      counter      <= (others => '0');
      end_init_rom <= '0';

    elsif rising_edge(clk) then
	 
      if clr_init_rom_addr = '1' then
        counter <= (others => '0');
      elsif inc_init_rom_addr = '1' then
        if counter = rom_size - 1 then
          counter <= (others => '0');
        else
          counter <= counter + 1;
	     end if; -- counter = rom_size - 1
      end if; -- clr_init_rom_addr = '1'

      -- DFFs on output signals to minimise critical path
      if counter = rom_size - 2 then
	     end_init_rom <= '1';
      else
        end_init_rom <= '0';
      end if; -- counter = rom_size - 2
    end if; -- resetn = '0'
  end process update_cpt;
 
  address <= std_logic_vector(counter);

end architecture rtl;
---------------------------------------------------------------------------
