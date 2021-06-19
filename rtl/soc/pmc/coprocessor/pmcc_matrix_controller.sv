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

module pmcc_matrix_controller (
    input logic        clk,
    input logic        rst_n,
    input logic        pmcc_rst_n,
    input logic        store,
    input logic [31:0] instr,
    soc_pm_ctrl.master pm_ctrl
);


/**
 * Local variables and signals
 */

logic [15:0] matrix_ctrl;


/**
 * Signals assignments
 */

assign pm_ctrl.res = matrix_ctrl[15:6];
assign pm_ctrl.write_cfg = matrix_ctrl[5];
assign pm_ctrl.strobe = matrix_ctrl[4];
assign pm_ctrl.gate = matrix_ctrl[3];
assign pm_ctrl.shB = matrix_ctrl[2];
assign pm_ctrl.shA = matrix_ctrl[1];
assign pm_ctrl.clkSh = matrix_ctrl[0];


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n or negedge pmcc_rst_n) begin
    if (!rst_n || !pmcc_rst_n)
        matrix_ctrl <= 16'b0;
    else
        matrix_ctrl <= store ? instr[23:8] : matrix_ctrl;
end

endmodule
