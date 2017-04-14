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
---------------------------------------------------------------------------
entity lt24_fsm is
  port(clk         :  in std_logic;
       resetn      :  in std_logic;

       tick_1ms    :  in std_logic;
       tick_10ms   :  in std_logic;
       tick_120ms  :  in std_logic;
       tick_tmin   :  in std_logic;
       clr_cptdelay: out std_logic;

       clr_init_rom_addr: out std_logic;
       inc_init_rom_addr: out std_logic;
       end_init_rom     :  in std_logic;
       init_rom_data    :  in std_logic_vector(16 downto 0);
       
       clr_cptpix: out std_logic;
       inc_cptpix: out std_logic;
       end_cptpix:  in std_logic;
       color     :  in std_logic_vector(15 downto 0);
       
       lt24_reset_n: out std_logic;
       lt24_lcd_on : out std_logic;
       lt24_cs_n   : out std_logic;
       lt24_rs     : out std_logic;
       lt24_rd_n   : out std_logic;
       lt24_wr_n   : out std_logic;
       lt24_d      : out std_logic_vector(15 downto 0));
end;
---------------------------------------------------------------------------
architecture rtl of lt24_fsm is
  type state_type is (reset0              , reset1              , reset2,
                      init_a              , init_b,
                      display_cmd0_a      , display_cmd0_b,
                      display_cmd0_data0_a, display_cmd0_data0_b,
                      display_cmd0_data1_a, display_cmd0_data1_b,
                      display_cmd1_a      , display_cmd1_b,
                      display_cmd1_data0_a, display_cmd1_data0_b,
                      display_cmd1_data1_a, display_cmd1_data1_b,
                      display_cmd2_a      , display_cmd2_b,
                      display_cmd3_a      , display_cmd3_b,
                      display_pix_a       , display_pix_b);
  signal state, next_state : state_type;
begin
  
  update_state:process (clk, resetn)
  begin
    if resetn = '0' then
      state <= reset0;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;
   
  nextstate_and_outputs:process (state, tick_1ms, tick_10ms, tick_120ms, tick_tmin,
                                 init_rom_data, color, end_init_rom, end_cptpix)
  begin
    next_state <= state;
    
    clr_cptdelay <= '0';
     
    clr_init_rom_addr <= '0';     
    inc_init_rom_addr <= '0';

    clr_cptpix <= '0';
    inc_cptpix <= '0';
     
    lt24_reset_n <= '1';
    lt24_lcd_on  <= '1';
    lt24_cs_n    <= '1';
    lt24_rs      <= '0';
    lt24_rd_n    <= '1';
    lt24_wr_n    <= '1';
    lt24_d       <= x"0000";
     
    case state is
      ----------------------------------------------------------------
      when reset0               =>
        if tick_1ms = '1' then
          next_state <= reset1;
        end if;
                                     lt24_reset_n <= '1';
                                     clr_cptdelay <= tick_1ms;
      ----------------------------------------------------------------
      when reset1               =>
        if tick_10ms = '1' then
          next_state <= reset2;
        end if; 
                                     lt24_reset_n <= '0';
                                     clr_cptdelay <= tick_10ms;
      ----------------------------------------------------------------
      when reset2               =>
        if tick_120ms = '1' then
          next_state <= init_a;
        end if;
                                     lt24_reset_n      <= '1';
                                     clr_init_rom_addr <= '1';
                                     clr_cptdelay      <= tick_120ms;
      ----------------------------------------------------------------
      when init_a               =>
        if tick_tmin = '1' then
          next_state <= init_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= init_rom_data(16);
                                     lt24_d       <= init_rom_data(15 downto 0);
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when init_b               =>
        if (tick_tmin = '1') and (end_init_rom = '1') then
          next_state <= display_cmd0_a;
        elsif (tick_tmin = '1') and (end_init_rom = '0') then
          next_state <= init_a;
        end if;
                                lt24_wr_n         <= '1';
                                lt24_cs_n         <= '0';
                                lt24_rs           <= init_rom_data(16);
                                lt24_d            <= init_rom_data(15 downto 0);
                                inc_init_rom_addr <= tick_tmin; --'1';
                                clr_cptdelay      <= tick_tmin;
      ----------------------------------------------------------------
      when display_cmd0_a       =>
        if tick_tmin = '1' then
          next_state <= display_cmd0_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002A";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd0_b       =>
        if tick_tmin = '1' then
          next_state <= display_cmd0_data0_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002A";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd0_data0_a =>
        if tick_tmin = '1' then
          next_state <= display_cmd0_data0_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd0_data0_b =>
        if tick_tmin = '1' then
          next_state <= display_cmd0_data1_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd0_data1_a =>
        if tick_tmin = '1' then
          next_state <= display_cmd0_data1_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd0_data1_b =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_a       =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002B";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_b       =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_data0_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002B";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_data0_a =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_data0_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_data0_b =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_data1_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_data1_a =>
        if tick_tmin = '1' then
          next_state <= display_cmd1_data1_b;
        end if;
                                     lt24_wr_n <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd1_data1_b =>
        if tick_tmin = '1' then
          next_state <= display_cmd2_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= x"0000";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd2_a       =>
        if tick_tmin = '1' then
          next_state <= display_cmd2_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002C";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd2_b       =>
        if tick_tmin = '1' then
          next_state <= display_cmd3_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002C";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd3_a       =>
        if tick_tmin = '1' then
          next_state <= display_cmd3_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002C";
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_cmd3_b       =>
        if tick_tmin = '1' then
          next_state <= display_pix_a;
        end if;
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '0';
                                     lt24_d       <= x"002C";
                                     clr_cptpix   <= '1';
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_pix_a        =>
        if tick_tmin = '1' then
          next_state <= display_pix_b;
        end if;
                                     lt24_wr_n    <= '0';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= color;
                                     clr_cptdelay <= tick_tmin;
      ----------------------------------------------------------------
      when  display_pix_b        =>
        if (tick_tmin = '1') and (end_cptpix = '1') then
          next_state <= display_cmd0_a;
        elsif (tick_tmin = '1') and (end_cptpix = '0') then
          next_state <= display_pix_a;
        end if;              
                                     lt24_wr_n    <= '1';
                                     lt24_cs_n    <= '0';
                                     lt24_rs      <= '1';
                                     lt24_d       <= color;
                                     inc_cptpix   <= tick_tmin;
                                     clr_cptdelay <= tick_tmin;
      end case;
   end process;
end;
---------------------------------------------------------------------------
