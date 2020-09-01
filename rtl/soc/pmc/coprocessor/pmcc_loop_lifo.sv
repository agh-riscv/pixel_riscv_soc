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

import pmcc_pkg::*;

module pmcc_loop_lifo (
    output pmcc_loop_t rdata,
    output logic       full,
    output logic       empty,
    input logic        clk,
    input logic        rst_n,
    input logic        pmcc_rst_n,
    input logic        push,
    input pmcc_loop_t  wdata,
    input logic        pop
);


/**
 * Local variables and signals
 */

pmcc_loop_t mem [10];

logic [3:0] elements_counter;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n or negedge pmcc_rst_n) begin
    if (!rst_n || !pmcc_rst_n) begin
        rdata.start_address <= 10'b0;
        rdata.iterations <= 14'b0;
        full <= 1'b0;
        empty <= 1'b1;
        elements_counter <= 4'b0;
    end
    else begin
        if (push && !full) begin
            mem[elements_counter] <= wdata;
            elements_counter <= elements_counter + 1;
            full <= (elements_counter == 9);
            empty <= 1'b0;
        end
        else if (pop && !empty) begin
            rdata <= mem[elements_counter - 1];
            elements_counter <= elements_counter - 1;
            full <= 1'b0;
            empty <= (elements_counter == 1);
        end
    end
end

endmodule
