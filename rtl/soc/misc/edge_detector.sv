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

logic data_in_prv, data_in_prv_2, edge_detected_nxt, edge_type_nxt;


/**
 * Module internal logic
 */

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        edge_detected <= 1'b0;
        edge_type <= 1'b0;
        data_in_prv_2 <= 1'b0;
        data_in_prv <= 1'b0;
    end
    else begin
        edge_detected <= edge_detected_nxt;
        edge_type <= edge_type_nxt;
        data_in_prv_2 <= data_in_prv;
        data_in_prv <= data_in;
    end
end

always_comb begin
    if (data_in_prv != data_in_prv_2) begin
        edge_detected_nxt = 1'b1;
        edge_type_nxt = data_in_prv;
    end
    else begin
        edge_detected_nxt = 1'b0;
        edge_type_nxt = 1'b0;
    end
end

endmodule
