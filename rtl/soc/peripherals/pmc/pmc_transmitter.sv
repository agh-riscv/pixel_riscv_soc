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
    output logic [31:0]      pm_data_din,
    input logic              clk,
    input logic              rst_n,
    input logic              sh,
    input logic              pclk,
    input logic [31:0][15:0] wdata
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
logic [31:0] pm_data_din_nxt;


/**
 * Tasks and functions definitions
 */

function logic [31:0] get_bits_from_wdata(input logic [3:0] index);
    return {
        wdata[31][index], wdata[30][index],
        wdata[29][index], wdata[28][index], wdata[27][index], wdata[26][index], wdata[25][index],
        wdata[24][index], wdata[23][index], wdata[22][index], wdata[21][index], wdata[20][index],
        wdata[19][index], wdata[18][index], wdata[17][index], wdata[16][index], wdata[15][index],
        wdata[14][index], wdata[13][index], wdata[12][index], wdata[11][index], wdata[10][index],
        wdata[9][index], wdata[8][index], wdata[7][index], wdata[6][index], wdata[5][index],
        wdata[4][index], wdata[3][index], wdata[2][index], wdata[1][index], wdata[0][index]
    };
endfunction


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bits_counter <= 4'b0;
    end else begin
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
        end else if (!sh) begin
            state_nxt = IDLE;
        end
    end
    ACTIVE: begin
        if (pclk) begin
            if (bits_counter == 15) begin
                state_nxt = WAITING;
                bits_counter_nxt = 0;
            end else begin
                bits_counter_nxt = bits_counter + 1;
            end
        end
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pm_data_din <= 32'b0;
    else
        pm_data_din <= pm_data_din_nxt;
end

always_comb begin
    pm_data_din_nxt = pm_data_din;

    case (state)
    IDLE: begin
        pm_data_din_nxt = get_bits_from_wdata(15);
    end
    WAITING: begin
        pm_data_din_nxt = get_bits_from_wdata(15);
    end
    ACTIVE: begin
        if (!pclk)
            pm_data_din_nxt = get_bits_from_wdata(15 - bits_counter);
    end
    endcase
end

endmodule
