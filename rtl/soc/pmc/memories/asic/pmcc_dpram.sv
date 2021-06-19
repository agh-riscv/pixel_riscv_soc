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

module pmcc_dpram #(
    DEPTH = 1024
) (
    output logic [31:0] rdata_a,
    output logic [31:0] rdata_b,
    input logic         clk,
    input logic         req_a,
    input logic [31:0]  addr_a,
    input logic [31:0]  addr_b,
    input logic         we_a,
    input logic [3:0]   be_a,
    input logic [31:0]  wdata_a
);

endmodule
