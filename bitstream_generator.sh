#!/bin/bash
#
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

function usage {
    echo "usage: $(basename "$0") [options]"
    echo "  options:"
    echo "      -r,     recompile application"
    echo "      -t,     specify the target board name [arty]"
    exit 1
}

function compile_programs {
    cmake -S sw/ -B sw/build -Dtarget:string=fpga && \
    cmake --build sw/build -j "$(nproc)"
}

function generate_boot_mem {
    tools/prs_rom_generator.py boot_mem sw/build/bootloader/bootloader.vmem rtl/soc/memories/boot_mem.sv
}

function generate_spi_mem {
    tools/prs_rom_generator.py spi_mem sw/build/app/app.vmem rtl/misc/spi_flash_memory/spi_mem.sv
}


# ------------------------------------------------------------------------------
# Arguments parsing and checking
# ------------------------------------------------------------------------------

if [[ $# -eq 0 ]]; then
    usage
fi

while getopts rt: option; do
    case ${option} in
        r) recompile_application=1;;
        t) target=${OPTARG};;
        *) usage;;
    esac
done


# ------------------------------------------------------------------------------
# Script internal logic
# ------------------------------------------------------------------------------

if [[ ${recompile_application} ]]; then
    compile_programs
    exit $?
fi

if ! compile_programs; then
    echo "ERROR: programs compilation failed"
    exit 1
elif ! generate_boot_mem; then
    echo "ERROR: boot_mem generation failed"
    exit 1
elif ! generate_spi_mem; then
    echo "ERROR: spi_mem generation failed"
    exit 1
fi

cd fpga
./clear.sh

case ${target} in
    "arty") vivado -mode tcl -source generate_bitstream.tcl -tclargs ${target};;
    *) echo "ERROR: incorrect target"; exit 1;;
esac
