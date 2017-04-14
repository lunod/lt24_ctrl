## ------------------------------------------------------------------------
## This file is part of lt24ctrl, a video controler IP core for Terrasic
## LT24 LCD display
## Copyright (C) 2017 Ludovic Noury <ludovic.noury@esiee.fr>
## 
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.
# ---------------------------------------------------------------
# Specify clock constraints
# 190 MHz => slack -0.5, register to rom_img
# 180 MHz => OK
create_clock -period "50 MHz" -name clk [get_ports clock_50]
derive_clock_uncertainty

# ---------------------------------------------------------------
# Constrains inputs
set_false_path -from [get_ports {key[0] key[1]}]

# ---------------------------------------------------------------
# Constrains outputs
# Try to force Pads DFF usage for output ports connected to 
# LT24 pins.
# TODO : extract real timming constraints from datasheet.
set_output_delay -clock clk -max 1   [get_ports lt24_*]
set_output_delay -clock clk -min -1  [get_ports lt24_*]
# ---------------------------------------------------------------
