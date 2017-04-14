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
entity cpt_pix is

  port(clk       :  in std_logic;
       resetn    :  in std_logic;

       clr_cptpix:  in std_logic;
       inc_cptpix:  in std_logic;
       end_cptpix: out std_logic;

       x         : out std_logic_vector(7 downto 0);  -- [0:239]
       y         : out std_logic_vector(8 downto 0)); -- [0:319]
  
end entity cpt_pix;
---------------------------------------------------------------------------
architecture rtl of cpt_pix is

  constant X_PIXELS: natural := 240;
  constant Y_PIXELS: natural := 320;

  signal cpt_x: unsigned(x'range);
  signal cpt_y: unsigned(y'range);
  
begin

  update_cpt: process(clk, resetn)
  begin
    if resetn = '0' then

      cpt_x <= (others => '0');
      cpt_y <= (others => '0');
      end_cptpix <= '0';      

    elsif rising_edge(clk) then

      if clr_cptpix = '1' then
        cpt_x <= (others => '0');
        cpt_y <= (others => '0');
		  end_cptpix <= '0';

      elsif inc_cptpix = '1' then
		
		  -- DFFs on output signals to minimise critical path
		  if (cpt_y = Y_PIXELS - 1) and (cpt_x = X_PIXELS - 2) then
				end_cptpix <= '1';
		  else
				end_cptpix <= '0';
		  end if;
		
        if cpt_x = X_PIXELS - 1 then
          cpt_x <= (others => '0');
          if cpt_y = Y_PIXELS - 1 then
            cpt_y      <= (others => '0');
          else
            cpt_y <= cpt_y + 1;
          end if; -- cpt_y = Y_PIXELS - 1
        else
          cpt_x <= cpt_x + 1;
        end if; -- cpt_x = X_PIXELS - 1
		  
      end if; -- if clr_cptpix = '1'
				
    end if; -- if resetn = '0'
  end process update_cpt;

  x <= std_logic_vector(cpt_x);
  y <= std_logic_vector(cpt_y);
  
end architecture rtl;
---------------------------------------------------------------------------
