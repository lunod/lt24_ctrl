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
-- Color format : 
-- "1111100000000000" : red   (5 bits, 15 downto 11)
-- "0000011111100000" : green (6 bits, 10 downto 5)
-- "0000000000011111" : blue  (5 bits,  4 downto 0)
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------
entity genpix is
  
  generic(system_frequency: real := 50_000_000.0);

  port(x     :  in std_logic_vector(7 downto 0);    -- 0 .. 239 => 8 bits
       y     :  in std_logic_vector(8 downto 0);    -- 0 .. 319 => 9 bits
       c     : out std_logic_vector(15 downto 0);   -- 16 bits colors
       resetn: in std_logic;
       clk   : in std_logic);

end entity genpix;
---------------------------------------------------------------------------
architecture rtl of genpix is
  
  constant t_cycles  : natural := integer(system_frequency * 1.0e-1);
  
  signal pos_x : unsigned(x'range);
  signal pos_y : unsigned(y'range);

  signal c0_reg, c1_reg, c2_reg, c3_reg: std_logic_vector(c'range);
  signal split_x : unsigned(x'range);
  signal split_y : unsigned(y'range);
begin

  update_cpt: process(clk, resetn)
    variable counter : natural range 0 to (t_cycles - 1);
  begin
    if resetn = '0' then
      counter :=  0;
      c0_reg  <= x"0000";
      c1_reg  <= x"F800";
      c2_reg  <= x"07E0";
      c3_reg  <= x"001F";
      split_x <= (others => '0');
      split_y <= (others => '0');
    elsif rising_edge(clk) then  		
      if (counter = t_cycles - 1) then
        counter := 0;
        -- Increments 16 bits color value by 1
        c0_reg <= std_logic_vector(unsigned(c0_reg) + 1);
        -- Increments only RED channel
        c1_reg <= std_logic_vector(unsigned(c1_reg(15 downto 11)) + 1) &
                  "000000" &
                  "00000";
        -- Increments only GREEN channel
        c2_reg <= "00000" &
                  std_logic_vector(unsigned(c2_reg(10 downto 5)) + 1) &
                  "00000";
        -- Increments only BLUE channel
        c3_reg <= "00000" &
                  "000000" &
                  std_logic_vector(unsigned(c3_reg(4 downto 0)) + 1);
        -- Moving line used to split screen into 2 areas
        split_y <= (split_y + 1) mod 320;
        split_x <= (split_x + 1) mod 240;
      else
        counter := counter + 1;
      end if;						
    end if; -- resetn = '0'
  end process update_cpt;

  pos_x <= unsigned(x);
  pos_y <= unsigned(y);

  update_c:process(clk, resetn)
  begin
    if resetn = '0' then
      c <= (others => '0');
    elsif rising_edge(clk) then
      -- Displays 3 colored pixels in a 1 pixel width black box
      -- in the top left corner
      if (pos_x < 5) and (pos_y = 0) then
        c <= x"0000";
      elsif (pos_x = 0) and (pos_y = 1) then
        c <= x"0000";
      elsif (pos_x = 1) and (pos_y = 1) then
        c <= x"F800";
      elsif (pos_x = 2) and (pos_y = 1) then
        c <= x"07E0";
      elsif (pos_x = 3) and (pos_y = 1) then
        c <= x"001F";
      elsif (pos_x = 4) and (pos_y = 1) then
        c <= x"0000";	
      elsif (pos_x < 5) and (pos_y = 2) then
        c <= x"0000";
      
      -- Display 3 colored bands along the left side        
      elsif (pos_x < 10) then 
        c <= "11111" & "000000" & "00000"; -- R
      elsif (pos_x < 20) then
        c <= "00000" & "111111" & "00000"; -- V
      elsif (pos_x < 30) then
        c <= "00000" & "000000" & "11111"; -- B

      -- Display 3 colored bands along the top side                
      elsif (pos_y < 10) then 
        c <= "11111" & "010000" & "01000";
      elsif (pos_y < 20) then
        c <= "01000" & "111111" & "01000";
      elsif (pos_y < 30) then
        c <= "01000" & "010000" & "11111";

      -- Split the remaining screen area into 4 area-changing
      -- sections, each filed with a single color  
      elsif pos_x < split_x then
        if pos_y < split_y then
          c <= c0_reg; -- x"07E0"; -- Green
        else
          c <= c1_reg; --x"001f"; -- Blue
        end if; -- pos_x < 160  
      else
        if pos_y < split_y then
          c <= c2_reg; --x"F800";  -- Red
        else
          c <= c3_reg; --x"ffff";
        end if; -- pos_x < 160
      end if; -- pos_x < 120
    end if; -- rising_edge(clk)
  end process update_c;
  
end architecture rtl;
---------------------------------------------------------------------------
