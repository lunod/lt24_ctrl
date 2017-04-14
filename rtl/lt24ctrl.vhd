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
-- Remarks :
--  * LT24 is a 320x240 LCD screen but the integrated controller considers
--    a 240x320 display with x=0 and y=0 the pixel on the top left when the
--    screen is held vertically with PCB text "terasic LT24" on the right
--    side.
--    Hence the choice to provide an interface with y=320 lines of x=240
--    pixels.
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
---------------------------------------------------------------------------
entity lt24ctrl is

  generic(system_frequency: real := 50_000_000.0;
	  tmin_cycles     : natural := 1);

  port (
    clk         : in  std_logic;
    resetn      : in  std_logic;
	 
    x           : out std_logic_vector(7 downto 0);    -- 0 .. 239 => 8 bits
    y           : out std_logic_vector(8 downto 0);    -- 0 .. 319 => 9 bits
    c           : in  std_logic_vector(15 downto 0);   -- couleurs 16 bits
	 
    lt24_reset_n: out std_logic;
    lt24_cs_n   : out std_logic;
    lt24_rs     : out std_logic;
    lt24_rd_n   : out std_logic;
    lt24_wr_n   : out std_logic;
    lt24_d      : out std_logic_vector(15 downto 0);
    lt24_lcd_on : out std_logic);
	 
end entity lt24ctrl;
---------------------------------------------------------------------------
architecture inst of lt24ctrl is

  signal rom_addr                               : std_logic_vector(6 downto 0);
  signal rom_data                               : std_logic_vector(16 downto 0);
  signal clr_cptdelay, tick_1ms, tick_10ms,
         tick_120ms, tick_tmin                  : std_logic;
  signal clr_init_rom_addr, inc_init_rom_addr,
         end_init_rom                           : std_logic;
  signal clr_cptpix, inc_cptpix, end_cptpix     : std_logic;
  
  signal lt24_reset_n_noreg, lt24_cs_n_noreg,
         lt24_rs_noreg, lt24_rd_n_noreg,
         lt24_wr_n_noreg, lt24_lcd_on_noreg     : std_logic;
  signal lt24_d_noreg                           : std_logic_vector(lt24_d'range);
 
begin

  rom: entity work.rom_init_lt24
    port map(
      clk  => clk,
      addr => rom_addr,
      q    => rom_data);
						
  cpt_timming: entity work.cpt_delay
    generic map(system_frequency => system_frequency,
                tmin_cycles      => tmin_cycles)		
    port map(clk          => clk,
             resetn       => resetn,
             clr_cptdelay => clr_cptdelay,
             tick_1ms     => tick_1ms,
             tick_10ms    => tick_10ms,
             tick_120ms   => tick_120ms,
             tick_tmin    => tick_tmin);

  cpt_address: entity work.cpt_addr_rom
    port map(clk               => clk,
             resetn            => resetn,
             clr_init_rom_addr => clr_init_rom_addr,
             inc_init_rom_addr => inc_init_rom_addr,
             end_init_rom      => end_init_rom,
             address           => rom_addr);
		
  cpt_pixels: entity work.cpt_pix
    port map(clk        => clk,
             resetn     => resetn,
             clr_cptpix => clr_cptpix,
             inc_cptpix => inc_cptpix,
             end_cptpix => end_cptpix,
             x          => x,
             y          => y);
		
  fsm: entity work.lt24_fsm
    port map(clk          => clk,
             resetn       => resetn,
             tick_1ms     => tick_1ms,
             tick_10ms    => tick_10ms,
             tick_120ms   => tick_120ms,
             tick_tmin    => tick_tmin,
             clr_cptdelay => clr_cptdelay,
           
             clr_init_rom_addr => clr_init_rom_addr,
             inc_init_rom_addr => inc_init_rom_addr,
             end_init_rom      => end_init_rom,
             init_rom_data     => rom_data,
             
             clr_cptpix => clr_cptpix,
             inc_cptpix => inc_cptpix,
             end_cptpix => end_cptpix,
             color      => c,
             
             lt24_reset_n => lt24_reset_n_noreg,
             lt24_lcd_on  => lt24_lcd_on_noreg,
             lt24_cs_n    => lt24_cs_n_noreg,
             lt24_rs      => lt24_rs_noreg,
             lt24_rd_n    => lt24_rd_n_noreg,
             lt24_wr_n    => lt24_wr_n_noreg,
             lt24_d       => lt24_d_noreg);

  -- Register outputs to relax timming delays and have clean/glitchless
  -- outputs from the FPGA to LT24
  sync_out:process(clk)
  begin
    if rising_edge(clk) then
      lt24_reset_n <= lt24_reset_n_noreg;
      lt24_cs_n    <= lt24_cs_n_noreg;
      lt24_rs      <= lt24_rs_noreg;
      lt24_rd_n    <= lt24_rd_n_noreg;
      lt24_wr_n    <= lt24_wr_n_noreg;
      lt24_d       <= lt24_d_noreg;
      lt24_lcd_on  <= lt24_lcd_on_noreg;
    end if;
  end process;						
												
end architecture inst;
---------------------------------------------------------------------------
