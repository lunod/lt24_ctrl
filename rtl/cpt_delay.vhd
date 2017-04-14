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
entity cpt_delay is

  generic(system_frequency: real    := 50_000_000.0;
          tmin_cycles     : natural := 1);
  
  port(clk         : in std_logic;
       resetn      : in std_logic;
       clr_cptdelay: in std_logic;
       tick_1ms    : out std_logic;
       tick_10ms   : out std_logic;
       tick_120ms  : out std_logic;
       tick_tmin   : out std_logic);
  
end entity cpt_delay;
---------------------------------------------------------------------------
architecture rtl of cpt_delay is

  constant t1ms_cycles  : natural := integer(system_frequency * 1.0e-3);
  constant t10ms_cycles : natural := integer(system_frequency * 10.0e-3);  
  constant t120ms_cycles: natural := integer(system_frequency * 120.0e-3);  
  
begin

  update_cpt: process(clk, resetn)
    variable counter : natural range 0 to (t120ms_cycles - 1);
  begin
    if resetn = '0' then
      counter    :=  0;
      tick_tmin  <= '0';
      tick_1ms   <= '0';
      tick_10ms  <= '0';
      tick_120ms <= '0';
    elsif rising_edge(clk) then
      tick_tmin  <= '0';
      tick_1ms   <= '0';
      tick_10ms  <= '0';
      tick_120ms <= '0';
      
      if counter = t120ms_cycles - 1 then      
        tick_120ms <= '1';
      elsif counter = t10ms_cycles - 1 then
        tick_10ms  <= '1';
      elsif counter = t1ms_cycles - 1 then
        tick_1ms   <= '1';
 		elsif counter = tmin_cycles then
        tick_tmin  <= '1';
      else
        null;
      end if; -- clr_cptdelay = '1'
		
      if (clr_cptdelay = '1') or (counter = t120ms_cycles - 1) then
        counter := 0;
      else
        counter := counter + 1;
      end if;		
				
    end if; -- resetn = '0'
  end process update_cpt;
  
end architecture rtl;
---------------------------------------------------------------------------
