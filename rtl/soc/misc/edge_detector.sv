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

module edge_detector (
    output logic edge_detected,
    output logic edge_type,         /* 0 - falling, 1 - rising */
    input logic  clk,
    input logic  rst_n,
    input logic  data_in
);


/**
 * Local variables and signals
 */

logic data_in_prv, data_in_prv2, data_in_prv3;


/**
 * Module internal logic
 */

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_in_prv <= 1'b0;
        data_in_prv2 <= 1'b0;
        data_in_prv3 <= 1'b0;
    end
    else begin
        data_in_prv <= data_in;
        data_in_prv2 <= data_in_prv;
        data_in_prv3 <= data_in_prv2;
    end
end

always_comb begin
    edge_detected = data_in_prv2 ^ data_in_prv3;
    edge_type = data_in_prv2;
end

endmodule
