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

module pmc_transmitter (
    output logic [31:0]      pm_din,
    input logic              clk,
    input logic              rst_n,
    input logic              sh,
    input logic              pclk,
    input logic [31:0][15:0] dout
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

state_t      state, state_nxt;
logic [3:0]  bits_counter, bits_counter_nxt;
logic [31:0] pm_din_nxt;


/**
 * Tasks and functions definitions
 */

function logic [31:0] get_bits_from_dout(input logic [3:0] index);
    return {
        dout[31][index], dout[30][index],
        dout[29][index], dout[28][index], dout[27][index], dout[26][index], dout[25][index],
        dout[24][index], dout[23][index], dout[22][index], dout[21][index], dout[20][index],
        dout[19][index], dout[18][index], dout[17][index], dout[16][index], dout[15][index],
        dout[14][index], dout[13][index], dout[12][index], dout[11][index], dout[10][index],
        dout[9][index], dout[8][index], dout[7][index], dout[6][index], dout[5][index],
        dout[4][index], dout[3][index], dout[2][index], dout[1][index], dout[0][index]
    };
endfunction


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
        pm_din <= 32'b0;
    else
        pm_din <= pm_din_nxt;
end

always_comb begin
    pm_din_nxt = pm_din;

    case (state)
    IDLE: begin
        pm_din_nxt = get_bits_from_dout(15);
    end
    WAITING: begin
        pm_din_nxt = get_bits_from_dout(15);
    end
    ACTIVE: begin
        if (!pclk)
            pm_din_nxt = get_bits_from_dout(15 - bits_counter);
    end
    endcase
end

endmodule
