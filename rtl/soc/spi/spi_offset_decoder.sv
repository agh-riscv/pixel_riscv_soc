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

import spi_pkg::*;

module spi_offset_decoder (
    output logic       gnt,
    output logic       rvalid,
    output spi_reg_t   requested_reg,
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
    requested_reg = SPI_NONE;

    if (req) begin
        case (addr[11:0])
        `SPI_CR_OFFSET:     requested_reg = SPI_CR;
        `SPI_SR_OFFSET:     requested_reg = SPI_SR;
        `SPI_TDR_OFFSET:    requested_reg = SPI_TDR;
        `SPI_RDR_OFFSET:    requested_reg = SPI_RDR;
        `SPI_CDR_OFFSET:    requested_reg = SPI_CDR;
        endcase
    end
    gnt = requested_reg != SPI_NONE;
end

endmodule
