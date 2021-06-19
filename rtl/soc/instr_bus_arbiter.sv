/**
 * Copyright (C) 2020  AGH University of Science and Technology
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

import pixel_riscv_soc_pkg::*;

module instr_bus_arbiter (
    output instr_bus_state_t instr_bus_state,
    input logic              clk,
    input logic              rst_n,
    input logic              instr_bus_req,
    input logic [31:0]       instr_bus_addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        instr_bus_state.responding_slave <= INSTR_BUS_NONE;
    else
        instr_bus_state.responding_slave <= instr_bus_state.requested_slave;
end

always_comb begin
    instr_bus_state.requested_slave = INSTR_BUS_NONE;

    if (instr_bus_req) begin
        case (instr_bus_addr) inside
        `BOOT_ROM_ADDRESS_SPACE:    instr_bus_state.requested_slave = INSTR_BUS_BOOT_ROM;
        `CODE_RAM_ADDRESS_SPACE:    instr_bus_state.requested_slave = INSTR_BUS_CODE_RAM;
        endcase
    end
end

endmodule
