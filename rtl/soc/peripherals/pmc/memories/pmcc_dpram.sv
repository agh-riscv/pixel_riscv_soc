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
    DEPTH = 256
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


/**
 * Local variables and signals
 */

localparam ADDR_MSB = $clog2(DEPTH) - 1;

logic [7:0] mem [DEPTH];


/**
 * Module internal logic
 */

always_ff @(posedge clk) begin
    if (req_a) begin
        if (we_a) begin
            if (be_a[3])
                mem[addr_a[ADDR_MSB:0] + 3] <= wdata_a[31:24];
            if (be_a[2])
                mem[addr_a[ADDR_MSB:0] + 2] <= wdata_a[23:16];
            if (be_a[1])
                mem[addr_a[ADDR_MSB:0] + 1]<= wdata_a[15:8];
            if (be_a[0])
                mem[addr_a[ADDR_MSB:0]] <= wdata_a[7:0];
        end
        rdata_a[31:24] <= mem[addr_a[ADDR_MSB:0] + 3];
        rdata_a[23:16] <= mem[addr_a[ADDR_MSB:0] + 2];
        rdata_a[15:8] <= mem[addr_a[ADDR_MSB:0] + 1];
        rdata_a[7:0] <= mem[addr_a[ADDR_MSB:0]];
    end
    rdata_b[31:24] <= mem[addr_b[ADDR_MSB:0] + 3];
    rdata_b[23:16] <= mem[addr_b[ADDR_MSB:0] + 2];
    rdata_b[15:8] <= mem[addr_b[ADDR_MSB:0] + 1];
    rdata_b[7:0] <= mem[addr_b[ADDR_MSB:0]];
end

endmodule
