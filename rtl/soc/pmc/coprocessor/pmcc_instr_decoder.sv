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

module pmcc_instr_decoder (
    output logic [1:0] instr_size,
    output logic       store,
    output logic       branch,
    output logic       loop,
    output logic       jump,
    output logic       waitt,
    input logic [31:0] instr
);


/**
 * Patterns used for instructions decoding
 */

`define STORE  3'b11?
`define STOREB 3'b10?
`define LOOP   3'b01?
`define JUMP   3'b001
`define WAITT  3'b000


/**
 * Module internal logic
 */

always_comb begin
    instr_size = 2'b00;
    store = 1'b0;
    branch = 1'b0;
    loop = 1'b0;
    jump = 1'b0;
    waitt = 1'b0;

    case (instr[7:5]) inside
        `STORE: begin
            instr_size = 2'b10;
            store = 1'b1;
        end
        `STOREB: begin
            instr_size = 2'b10;
            store = 1'b1;
            branch = 1'b1;
        end
        `LOOP: begin
            instr_size = 2'b01;
            loop = 1'b1;
        end
        `JUMP: begin
            instr_size = 2'b01;
            jump = 1'b1;
        end
        `WAITT: begin
            instr_size = 2'b00;
            waitt = 1'b1;
        end
        default: begin
            instr_size = 2'b00;
            waitt = 1'b1;
        end
    endcase
end

endmodule
