/**
 * Copyright (C) 2022  AGH University of Science and Technology
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

module fifo #(
    SIZE = 4
) (
    input logic        clk,
    input logic        rst_n,

    output logic       full,
    output logic       empty,
    output logic [7:0] rdata,
    input logic        push,
    input logic        pop,
    input logic [7:0]  wdata
);


/**
 * Local variables and signals
 */

logic [7:0]              mem [SIZE];
logic [$clog2(SIZE)-1:0] wptr, rptr;
logic                    last_write;


/**
 * Signals assignments
 */

assign rdata = mem[rptr];


/**
 * Tasks and functions definitions
 */

function automatic logic is_fifo_full();
    return (rptr == wptr) && last_write;
endfunction

function automatic logic is_fifo_empty();
    return (rptr == wptr) && !last_write;
endfunction


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wptr <= 0;
        rptr <= 0;
        last_write <= 1'b0;
    end else begin
        case ({pop, push})
        2'b00: ;
        2'b01: begin
            if (!is_fifo_full()) begin
                mem[wptr] <= wdata;
                wptr <= (wptr == SIZE - 1) ? 0 : wptr + 1;
                last_write <= 1'b1;
            end
        end
        2'b10: begin
            if (!is_fifo_empty()) begin
                rptr <= (rptr == SIZE - 1) ? 0 : rptr + 1;
                last_write <= 1'b0;
            end
        end
        2'b11: begin
            mem[wptr] <= wdata;
            wptr <= (wptr == SIZE - 1) ? 0 : wptr + 1;
            rptr <= (rptr == SIZE - 1) ? 0 : rptr + 1;
        end
        endcase
    end
end

always_comb begin
    empty = is_fifo_empty();
    full = is_fifo_full();
end

endmodule
