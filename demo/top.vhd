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
entity top is

  port (
    clock_50                   : in    std_logic;
    key                        : in    std_logic_vector(1 downto 0);
    lt24_reset_n               : out   std_logic;
    lt24_cs_n                  : out   std_logic;
    lt24_rs                    : out   std_logic;
    lt24_rd_n                  : out   std_logic;
    lt24_wr_n                  : out   std_logic;
    lt24_d                     : out   std_logic_vector(15 downto 0);
    lt24_lcd_on                : out   std_logic);

-- attribute useioff : boolean;
-- attribute useioff of lt24_reset_n : signal is true;
-- attribute useioff of lt24_cs_n : signal is true;
-- attribute useioff of lt24_rs : signal is true;
-- --attribute useioff of lt24_rd_n : signal is true;
-- attribute useioff of lt24_wr_n : signal is true;
-- attribute useioff of lt24_d : signal is true;
-- --attribute useioff of lt24_lcd_on : signal is true;
--    
end entity top;
---------------------------------------------------------------------------
architecture inst of top is

  signal x              : std_logic_vector(7 downto 0);  -- 0 .. 319 => 9 bits
  signal y              : std_logic_vector(8 downto 0);  -- 0 .. 239 => 8 bits
  signal c, c_rom, c_rom_reg, c_pat: std_logic_vector(15 downto 0); -- 16 bits colors
  
  signal clk, resetn_pad, resetn_pad_reg1, resetn_sync : std_logic;
  
  signal xy_to_address : std_logic_vector(17 downto 0);
  
  -- Registers key(1) to exclude key(1) from critical path
  signal selected_input : std_logic;
  
begin
  --------------------------------------------------------------------
  -- Synchronize reset (synchronous reset_sync assertion, but synchronous 
  -- reset_sync removal)
  resetn_pad <= key(0);
  clk        <= clock_50;

  sync_reset:process(resetn_pad, clk)		
    variable resetn_pad_reg0 : std_logic;
  begin
    if resetn_pad = '0' then
      resetn_pad_reg0 := '0';
      resetn_pad_reg1 <= '0';
    elsif rising_edge(clk) then
      resetn_pad_reg1 <= resetn_pad_reg0;
      resetn_pad_reg0 := '1';
    end if;
  end process;
  resetn_sync <= resetn_pad_reg1;

  --------------------------------------------------------------------
  -- registers used to split some critical paths
	update_regs: process(resetn_sync, clk)
	begin
		if (resetn_sync = '0') then
			selected_input <= '0';		
			c_rom_reg <= (others => '0');
			xy_to_address<= (others => '0');
      elsif rising_edge(clk) then
			selected_input <= key(1);
			c_rom_reg <= c_rom;
			
			xy_to_address <= std_logic_vector(unsigned(x) +
									unsigned(y)*to_unsigned(240,9)
												-- -1 -- to compensate c_reg delay
												);
		end if;
  end process;
	 
  --------------------------------------------------------------------
  -- LT24 controller 
  -- Remark : LT24_RD_N and LR24_LCD_ON are always set.
  lt24ctrl_0:entity work.lt24ctrl
    generic map (
      system_frequency => 50_000_000.0,
      tmin_cycles      => 1)
    port map (
      clk         => clock_50,
      resetn      => resetn_sync,
      
      x           => x,
      y           => y,
      c           => c,
      
      lt24_reset_n => lt24_reset_n,
      lt24_cs_n    => lt24_cs_n,
      lt24_rs      => lt24_rs,
      lt24_rd_n    => lt24_rd_n,
      lt24_wr_n    => lt24_wr_n,
      lt24_d       => lt24_d,
      lt24_lcd_on  => lt24_lcd_on);

  --------------------------------------------------------------------
  -- Select LCD screen input depending on key(1)
  c <= c_rom_reg when selected_input = '1' else
       c_pat;	
  
  -- Input 1 : static picture stored into a ROM
  rom_img: entity work.rom_img
    port map(
      addr => xy_to_address(16 downto 0),
      q    => c_rom,
      clk  => clk);
  
  -- Input 2 : pattern generator
  genpix0: entity work.genpix	
    port map(
      x      => x,
      y      => y,
      c      => c_pat,
      resetn => resetn_sync,
      clk    => clock_50);
  
end architecture inst;
---------------------------------------------------------------------------
