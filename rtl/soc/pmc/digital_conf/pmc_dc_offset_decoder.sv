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

import pmc_dc_pkg::*;

module pmc_dc_offset_decoder (
    output logic        gnt,
    output logic        rvalid,
    output pmc_dc_reg_t requested_reg,
    input logic         clk,
    input logic         rst_n,
    input logic         req,
    input logic [31:0]  addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rvalid <= 1'b0;
    else
        rvalid <= gnt;
end

always_comb begin
    requested_reg = PMC_DC_NONE;

    if (req) begin
        case (addr[7:0])
        `PMC_DC_REG_0_OFFSET:   requested_reg = PMC_DC_REG_0;
        endcase
    end
    gnt = requested_reg != PMC_DC_NONE;
end

endmodule
