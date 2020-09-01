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

import tmr_pkg::*;

module tmr_offset_decoder (
    output logic       gnt,
    output logic       rvalid,
    output tmr_reg_t   requested_reg,
    input logic        clk,
    input logic        rst_n,
    input logic        req,
    input logic [31:0] addr
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
    requested_reg = TMR_NONE;

    if (req) begin
        case (addr[11:0])
            `TMR_CR_OFFSET:     requested_reg = TMR_CR;
            `TMR_SR_OFFSET:     requested_reg = TMR_SR;
            `TMR_CNTR_OFFSET:   requested_reg = TMR_CNTR;
            `TMR_CMPR_OFFSET:   requested_reg = TMR_CMPR;
        endcase
    end

    gnt = requested_reg != TMR_NONE;
end

endmodule
