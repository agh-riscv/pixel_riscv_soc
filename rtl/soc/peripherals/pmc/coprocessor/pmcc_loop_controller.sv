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

import pmcc_pkg::*;

module pmcc_loop_controller (
    output logic       branch_exec,
    output logic [9:0] branch_dst,
    input logic        clk,
    input logic        rst_n,
    input logic        pmcc_rst_n,
    input logic        loop,
    input logic        branch,
    input logic [1:0]  instr_size,
    input logic [31:0] instr,
    input logic [7:0]  pc
);


/**
 * Local variables and signals
 */

pmcc_loop_t  active_loop, active_loop_nxt, lifo_wdata, lifo_rdata;
logic        lifo_readout, lifo_readout_nxt, loop_execution, loop_execution_nxt;
logic        lifo_push, lifo_pop, lifo_full, lifo_empty;
logic [13:0] iterations;


/**
 * Signals assignments
 */

assign iterations = {instr[5:0], instr[15:8]};


/**
 * Submodules placement
 */

pmcc_loop_lifo u_pmcc_loop_lifo (
    .rdata(lifo_rdata),
    .full(lifo_full),
    .empty(lifo_empty),
    .clk,
    .rst_n,
    .pmcc_rst_n,
    .push(lifo_push),
    .wdata(lifo_wdata),
    .pop(lifo_pop)
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n or negedge pmcc_rst_n) begin
    if (!rst_n || !pmcc_rst_n) begin
        active_loop.start_address <=  10'b0;
        active_loop.iterations <= 14'b0;
        loop_execution <= 1'b0;
        lifo_readout <= 1'b0;
    end else begin
        active_loop <= active_loop_nxt;
        loop_execution <= loop_execution_nxt;
        lifo_readout <= lifo_readout_nxt;
    end
end

always_comb begin
    branch_exec = 1'b0;
    branch_dst = 10'b0;
    active_loop_nxt = active_loop;
    loop_execution_nxt = loop_execution;
    lifo_readout_nxt = 1'b0;
    lifo_push = 1'b0;
    lifo_pop = 1'b0;
    lifo_wdata.start_address = 10'b0;
    lifo_wdata.iterations = 14'b0;

    if (!lifo_readout) begin
        if (loop) begin
            if (iterations) begin
                active_loop_nxt.start_address = pc + instr_size + 1;
                active_loop_nxt.iterations = iterations - 1;

                if (loop_execution) begin
                    lifo_wdata = active_loop;
                    lifo_push = 1'b1;
                end else begin
                    loop_execution_nxt = 1'b1;
                end
            end
        end else if (branch) begin
            if (loop_execution) begin
                if (active_loop.iterations) begin
                    branch_dst = active_loop.start_address;
                    branch_exec = 1'b1;
                    active_loop_nxt.iterations = active_loop.iterations - 1;
                end else begin
                    if (!lifo_empty) begin
                        lifo_pop = 1'b1;
                        lifo_readout_nxt = 1'b1;
                    end else begin
                        loop_execution_nxt = 1'b0;
                    end
                end
            end
        end
    end else begin
        if (branch) begin
            if (lifo_rdata.iterations) begin
                branch_dst = lifo_rdata.start_address;
                branch_exec = 1'b1;
                active_loop_nxt.start_address = lifo_rdata.start_address;
                active_loop_nxt.iterations = lifo_rdata.iterations - 1;
            end else begin
                if (!lifo_empty) begin
                    lifo_pop = 1'b1;
                    lifo_readout_nxt = 1'b1;
                end else begin
                    loop_execution_nxt = 1'b0;
                end
            end
        end else if (loop) begin
            if (iterations) begin
                active_loop_nxt.start_address = pc + instr_size + 1;
                active_loop_nxt.iterations = iterations - 1;
                lifo_wdata = lifo_rdata;
                lifo_push = 1'b1;
            end else begin
                active_loop_nxt.start_address = lifo_rdata.start_address;
                active_loop_nxt.iterations = lifo_rdata.iterations - 1;
            end
        end else begin
            active_loop_nxt.start_address = lifo_rdata.start_address;
            active_loop_nxt.iterations = lifo_rdata.iterations - 1;
        end
    end
end

endmodule
