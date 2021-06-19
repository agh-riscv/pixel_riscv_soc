/**
 * Copyright (C) 2021  AGH University of Science and Technology
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

module pmc_receiver (
    output logic [31:0][15:0] din,
    input logic               clk,
    input logic               rst_n,
    input logic               sh,
    input logic               pclk,
    input logic [31:0]        pm_dout
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    WAITING,
    ACTIVE
} state_t;


/**
 * Local variables and signals
 */

state_t            state, state_nxt;
logic [3:0]        bits_counter, bits_counter_nxt;
logic [31:0][15:0] din_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bits_counter <= 4'b0;
    end
    else begin
        state <= state_nxt;
        bits_counter <= bits_counter_nxt;
    end
end

always_comb begin
    state_nxt = state;
    bits_counter_nxt = bits_counter;

    case (state)
    IDLE: begin
        if (sh)
            state_nxt = WAITING;
    end
    WAITING: begin
        if (pclk) begin
            state_nxt = ACTIVE;
            bits_counter_nxt = bits_counter + 1;
        end
        else if (!sh) begin
            state_nxt = IDLE;
        end
    end
    ACTIVE: begin
        if (pclk) begin
            if (bits_counter == 15) begin
                state_nxt = WAITING;
                bits_counter_nxt = 0;
            end
            else begin
                bits_counter_nxt = bits_counter + 1;
            end
        end
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        din <= {16{32'b0}};
    else
        din <= din_nxt;
end

always_comb begin
    din_nxt = din;

    case (state)
    IDLE: ;
    WAITING: begin
        if (pclk) begin
            for (int i = 0; i < 32; ++i)
                din_nxt[i][15] = pm_dout[i];
        end
    end
    ACTIVE: begin
        if (pclk) begin
            for (int i = 0; i < 32; ++i)
                din_nxt[i][15-bits_counter] = pm_dout[i];
        end
    end
    endcase
end

endmodule
