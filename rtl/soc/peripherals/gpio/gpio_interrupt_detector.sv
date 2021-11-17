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

import gpio_pkg::*;

module gpio_interrupt_detector (
    output logic [31:0] interrupt_detected,
    input logic         clk,
    input logic         rst_n,
    input logic [31:0]  io_in,
    input gpio_ier_t    ier,
    input gpio_rier_t   rier,
    input gpio_fier_t   fier
);


/**
 * Local variables and signals
 */

logic [31:0] edge_detected, edge_type;


/**
 * Submodules placement
 */

edge_detector u_edge_detector[31:0] (
    .edge_detected,
    .edge_type,         /* 0 - falling, 1 - rising */
    .clk,
    .rst_n,
    .data_in(io_in)
);


/**
 * Module internal logic
 */

genvar i;

generate
    for (i = 0; i < 32; ++i) begin
        always_comb begin
            interrupt_detected[i] = 1'b0;

            if (ier.data[i] && edge_detected[i])
                interrupt_detected[i] = (rier.data[i] & edge_type[i]) || (fier.data[i] & ~edge_type[i]);
        end
    end
endgenerate

endmodule
