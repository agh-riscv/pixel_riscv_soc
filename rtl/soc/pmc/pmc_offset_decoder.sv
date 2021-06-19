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

import pmc_pkg::*;

module pmc_offset_decoder (
    output logic       gnt,
    output logic       rvalid,
    output pmc_reg_t   requested_reg,
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
    requested_reg = PMC_NONE;

    if (req) begin
        case (addr[15:0]) inside
        `PMC_CR_OFFSET:         requested_reg = PMC_CR;
        `PMC_SR_OFFSET:         requested_reg = PMC_SR;
        `PMC_CTRL_OFFSET:       requested_reg = PMC_CTRL;
        `PMC_DOUT_0_OFFSET:     requested_reg = PMC_DOUT_0;
        `PMC_DOUT_1_OFFSET:     requested_reg = PMC_DOUT_1;
        `PMC_DOUT_2_OFFSET:     requested_reg = PMC_DOUT_2;
        `PMC_DOUT_3_OFFSET:     requested_reg = PMC_DOUT_3;
        `PMC_DOUT_4_OFFSET:     requested_reg = PMC_DOUT_4;
        `PMC_DOUT_5_OFFSET:     requested_reg = PMC_DOUT_5;
        `PMC_DOUT_6_OFFSET:     requested_reg = PMC_DOUT_6;
        `PMC_DOUT_7_OFFSET:     requested_reg = PMC_DOUT_7;
        `PMC_DOUT_8_OFFSET:     requested_reg = PMC_DOUT_8;
        `PMC_DOUT_9_OFFSET:     requested_reg = PMC_DOUT_9;
        `PMC_DOUT_10_OFFSET:    requested_reg = PMC_DOUT_10;
        `PMC_DOUT_11_OFFSET:    requested_reg = PMC_DOUT_11;
        `PMC_DOUT_12_OFFSET:    requested_reg = PMC_DOUT_12;
        `PMC_DOUT_13_OFFSET:    requested_reg = PMC_DOUT_13;
        `PMC_DOUT_14_OFFSET:    requested_reg = PMC_DOUT_14;
        `PMC_DOUT_15_OFFSET:    requested_reg = PMC_DOUT_15;
        `PMC_DIN_0_OFFSET:      requested_reg = PMC_DIN_0;
        `PMC_DIN_1_OFFSET:      requested_reg = PMC_DIN_1;
        `PMC_DIN_2_OFFSET:      requested_reg = PMC_DIN_2;
        `PMC_DIN_3_OFFSET:      requested_reg = PMC_DIN_3;
        `PMC_DIN_4_OFFSET:      requested_reg = PMC_DIN_4;
        `PMC_DIN_5_OFFSET:      requested_reg = PMC_DIN_5;
        `PMC_DIN_6_OFFSET:      requested_reg = PMC_DIN_6;
        `PMC_DIN_7_OFFSET:      requested_reg = PMC_DIN_7;
        `PMC_DIN_8_OFFSET:      requested_reg = PMC_DIN_8;
        `PMC_DIN_9_OFFSET:      requested_reg = PMC_DIN_9;
        `PMC_DIN_10_OFFSET:     requested_reg = PMC_DIN_10;
        `PMC_DIN_11_OFFSET:     requested_reg = PMC_DIN_11;
        `PMC_DIN_12_OFFSET:     requested_reg = PMC_DIN_12;
        `PMC_DIN_13_OFFSET:     requested_reg = PMC_DIN_13;
        `PMC_DIN_14_OFFSET:     requested_reg = PMC_DIN_14;
        `PMC_DIN_15_OFFSET:     requested_reg = PMC_DIN_15;
        `PMC_AC_OFFSET:         requested_reg = PMC_AC;
        `PMC_DC_OFFSET:         requested_reg = PMC_DC;
        `PMCC_CODE_RAM_OFFSET:  requested_reg = PMCC_CODE_RAM;
        endcase
    end
    gnt = requested_reg != PMC_NONE;
end

endmodule
