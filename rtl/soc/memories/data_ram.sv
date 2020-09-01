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

module data_ram (
    input logic clk,
    input logic rst_n,

    ibex_data_bus.slave data_bus
);


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;


/**
 * Submodules placement
 */

ram u_ram (
    .rdata(data_bus.rdata),
    .clk,
    .req(data_bus.req),
    .addr(data_bus.addr),
    .we(data_bus.we),
    .be(data_bus.be),
    .wdata(data_bus.wdata)
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_bus.rvalid <= 1'b0;
    else
        data_bus.rvalid <= data_bus.gnt;
end

always_comb begin
    data_bus.gnt = data_bus.req;
end

endmodule
