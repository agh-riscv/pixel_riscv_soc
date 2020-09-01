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

set project pixel_riscv_soc
set top_module top_pixel_riscv_soc_arty_a7_100
set target xc7a100tcsg324-1

file mkdir build

create_project ${project} build -part ${target} -force

read_xdc {
    constraints/arty_a7_100.xdc
}

source scripts/read_rtls.tcl

read_verilog -sv {
    rtl/top_pixel_riscv_soc_arty_a7_100.sv
}

set_property top ${top_module} [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

exit
