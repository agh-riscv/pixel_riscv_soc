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

module data_bus_arbiter (
    output data_bus_state_t data_bus_state,
    input logic             clk,
    input logic             rst_n,
    input logic             data_bus_req,
    input logic [31:0]      data_bus_addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_bus_state.responding_slave <= DATA_BUS_NONE;
    else
        data_bus_state.responding_slave <= data_bus_state.requested_slave;
end

always_comb begin
    data_bus_state.requested_slave = DATA_BUS_NONE;

    if (data_bus_req) begin
        case (data_bus_addr) inside
        `BOOT_ROM_ADDRESS_SPACE:    data_bus_state.requested_slave = DATA_BUS_BOOT_ROM;
        `CODE_RAM_ADDRESS_SPACE:    data_bus_state.requested_slave = DATA_BUS_CODE_RAM;
        `DATA_RAM_ADDRESS_SPACE:    data_bus_state.requested_slave = DATA_BUS_DATA_RAM;
        `GPIO_ADDRESS_SPACE:        data_bus_state.requested_slave = DATA_BUS_GPIO;
        `SPI_ADDRESS_SPACE:         data_bus_state.requested_slave = DATA_BUS_SPI;
        `UART_ADDRESS_SPACE:        data_bus_state.requested_slave = DATA_BUS_UART;
        `TIMER_ADDRESS_SPACE:       data_bus_state.requested_slave = DATA_BUS_TIMER;
        `PMC_ADDRESS_SPACE:         data_bus_state.requested_slave = DATA_BUS_PMC;
        endcase
    end
end

endmodule
