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
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n or negedge pmcc_rst_n) begin
    if (!rst_n || !pmcc_rst_n) begin
        pm_ctrl.store <= 32'b0;
        pm_ctrl.strobe <= 32'b0;
        pm_ctrl.gate <= 32'b0;
        pm_ctrl.sh_b <= 32'b0;
        pm_ctrl.sh_a <= 32'b0;
        pm_ctrl.clk_sh <= 32'b0;
    end else begin
        if (store) begin
            pm_ctrl.store <= {32{instr[13]}};
            pm_ctrl.strobe <= {32{instr[12]}};
            pm_ctrl.gate <= {32{instr[11]}};
            pm_ctrl.sh_b <= {32{instr[10]}};
            pm_ctrl.sh_a <= {32{instr[9]}};
            pm_ctrl.clk_sh <= {32{instr[8]}};
        end
    end
end

endmodule
