/**
 * Copyright (C) 2021  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

module memories (
    input logic          clk,
    input logic          rst_n,

    ibex_data_bus.slave  boot_rom_data_bus,
    ibex_data_bus.slave  code_ram_data_bus,
    ibex_data_bus.slave  data_ram_data_bus,

    ibex_instr_bus.slave boot_rom_instr_bus,
    ibex_instr_bus.slave code_ram_instr_bus
);


/**
 * Submodules placement
 */

boot_rom u_boot_rom (
    .clk,
    .rst_n,
    .instr_bus(boot_rom_instr_bus),
    .data_bus(boot_rom_data_bus)
);

code_ram u_code_ram (
    .clk,
    .rst_n,
    .data_bus(code_ram_data_bus),
    .instr_bus(code_ram_instr_bus)
);

data_ram u_data_ram (
    .clk,
    .rst_n,
    .data_bus(data_ram_data_bus)
);

endmodule
