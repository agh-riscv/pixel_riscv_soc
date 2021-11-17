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
    input logic            clk,
    input logic            rst_n,
    input logic            pmcc_rst_n,
    input logic            store,
    input logic [31:0]     instr,
    soc_pmc_pm_ctrl.master pmc_pm_ctrl
);


/**
 * Local variables and signals
 */

logic [15:0] matrix_ctrl;


/**
 * Signals assignments
 */

assign pmc_pm_ctrl.res = matrix_ctrl[15:6];
assign pmc_pm_ctrl.store = matrix_ctrl[5];
assign pmc_pm_ctrl.strobe = matrix_ctrl[4];
assign pmc_pm_ctrl.gate = matrix_ctrl[3];
assign pmc_pm_ctrl.sh_b = matrix_ctrl[2];
assign pmc_pm_ctrl.sh_a = matrix_ctrl[1];
assign pmc_pm_ctrl.clk_sh = matrix_ctrl[0];


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
