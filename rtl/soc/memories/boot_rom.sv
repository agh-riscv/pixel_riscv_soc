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

module boot_rom (
    input logic clk,
    input logic rst_n,

    ibex_data_bus.slave  data_bus,
    ibex_instr_bus.slave instr_bus
);


/**
 * Local variables and signals
 */

logic [31:0] addr, rdata;


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;
assign instr_bus.err = 1'b0;


/**
 * Submodules placement
 */

boot_mem u_boot_mem (
    .rdata,
    .addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rvalid <= 1'b0;
        data_bus.rdata <= 32'b0;

        instr_bus.rvalid <= 1'b0;
        instr_bus.rdata <= 32'b0;
    end
    else begin
        data_bus.rvalid <= data_bus.gnt;
        data_bus.rdata <= rdata;

        instr_bus.rvalid <= instr_bus.gnt;
        instr_bus.rdata <= rdata;
    end
end

always_comb begin
    addr = 32'b0;
    data_bus.gnt = 1'b0;
    instr_bus.gnt = 1'b0;

    if (data_bus.req) begin
        addr = data_bus.addr;
        data_bus.gnt = 1'b1;
    end
    else if (instr_bus.req) begin
        addr = instr_bus.addr;
        instr_bus.gnt = 1'b1;
    end
end

endmodule
