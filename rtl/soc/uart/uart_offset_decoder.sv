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

import uart_pkg::*;

module uart_offset_decoder (
    output logic       gnt,
    output logic       rvalid,
    output uart_reg_t  requested_reg,
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
    requested_reg = UART_NONE;

    if (req) begin
        case (addr[11:0])
            `UART_CR_OFFSET:    requested_reg = UART_CR;
            `UART_SR_OFFSET:    requested_reg = UART_SR;
            `UART_TDR_OFFSET:   requested_reg = UART_TDR;
            `UART_RDR_OFFSET:   requested_reg = UART_RDR;
            `UART_CDR_OFFSET:   requested_reg = UART_CDR;
        endcase
    end

    gnt = requested_reg != UART_NONE;
end

endmodule
