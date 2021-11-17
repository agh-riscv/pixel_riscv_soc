#!/bin/bash
# Copyright (C) 2020  AGH University of Science and Technology
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function compile_programs {
    cmake -S sw/ -B sw/build -Dapp=command_interpreter -Dtarget=arty &&
    cmake --build sw/build -j "$(nproc)"
}

function generate_boot_mem {
    tools/prs_rom_generator.py boot_mem sw/build/bootloader/bootloader.vmem rtl/soc/memories/boot_mem.sv
}

function generate_spi_mem {
    tools/prs_rom_generator.py spi_mem sw/build/command_interpreter/command_interpreter.vmem rtl/misc/spi_flash_memory/spi_mem.sv
}


# ------------------------------------------------------------------------------
# Script internal logic
# ------------------------------------------------------------------------------

compile_programs || { echo "ERROR: programs compilation failed"; exit 1; }
generate_boot_mem || { echo "ERROR: boot_mem generation failed"; exit 1; }
generate_spi_mem || { echo "ERROR: code_mem generation failed"; exit 1; }

cd fpga
./clear.sh
vivado -mode tcl -source generate_bitstream.tcl
