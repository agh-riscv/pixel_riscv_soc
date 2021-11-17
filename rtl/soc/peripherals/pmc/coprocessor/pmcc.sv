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

module pmcc (
    output logic [9:0]     pc_if,
    output logic           waitt,
    input logic            clk,
    input logic            rst_n,
    input logic            pmcc_rst_n,
    input logic            trigger,
    input logic [31:0]     instr,
    soc_pmc_pm_ctrl.master pmc_pm_ctrl
);


/**
 * Local variables and signals
 */

logic [9:0] pc_id, branch_dst;
logic [1:0] instr_size;
logic       store, branch, loop, jump, waiting, branch_exec;


/**
 * Submodules placement
 */

pmcc_instr_decoder u_pmcc_instr_decoder (
    .instr_size,
    .store,
    .branch,
    .loop,
    .jump,
    .waitt,
    .instr
);

pmcc_matrix_controller u_pmcc_matrix_controller (
    .clk,
    .rst_n,
    .pmcc_rst_n,
    .store,
    .instr,
    .pmc_pm_ctrl
);

pmcc_loop_controller u_pmcc_loop_controller (
    .branch_exec,
    .branch_dst,
    .clk,
    .rst_n,
    .pmcc_rst_n,
    .loop,
    .branch,
    .instr_size,
    .instr,
    .pc(pc_id)
);

pmcc_wait_controller u_pmcc_wait_controller (
    .waiting,
    .waitt,
    .trigger
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n or negedge pmcc_rst_n) begin
    if (!rst_n || !pmcc_rst_n)
        pc_id <= 10'b0;
    else
        pc_id <= pc_if;
end

always_comb begin
    case ({rst_n & pmcc_rst_n, waiting, jump, branch_exec}) inside
    4'b0???:    pc_if = 10'b0;
    4'b11??:    pc_if = pc_id;
    4'b101?:    pc_if = {instr[5:0], instr[15:8]};
    4'b1001:    pc_if = branch_dst;
    4'b1000:    pc_if = pc_id + instr_size + 1;
    endcase
end

endmodule
