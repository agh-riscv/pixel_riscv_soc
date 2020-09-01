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

module uart_transmitter (
    output logic       sout,
    output logic       busy,
    input logic        clk,
    input logic        rst_n,
    input logic        sck_rising_edge,
    input logic        tx_data_valid,
    input logic [7:0]  tx_data
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    START,
    ACTIVE,
    STOP
} state_t;


/**
 * Local variables and signals
 */

logic       sout_nxt;
logic [2:0] bits_counter, bits_counter_nxt;
logic [3:0] edges_counter, edges_counter_nxt;
logic [7:0] tx_buffer, tx_buffer_nxt;

state_t state, state_nxt;


/**
 * Module internal logic
 */

/* State controller */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bits_counter <= 3'b0;
        edges_counter <= 4'b0;
    end
    else begin
        state <= state_nxt;
        bits_counter <= bits_counter_nxt;
        edges_counter <= edges_counter_nxt;
    end
end

always_comb begin
    state_nxt = state;
    bits_counter_nxt = bits_counter;
    edges_counter_nxt = edges_counter;

    case (state)
        IDLE: begin
            if (tx_data_valid)
                state_nxt = START;
        end
        START: begin
            if (sck_rising_edge) begin
                if (edges_counter == 15) begin
                    state_nxt = ACTIVE;
                    edges_counter_nxt = 4'b0;
                end
                else begin
                    edges_counter_nxt = edges_counter + 1;
                end
            end
        end
        ACTIVE: begin
            if (sck_rising_edge) begin
                if (edges_counter == 15) begin
                    edges_counter_nxt = 4'b0;

                    if (bits_counter == 7) begin
                        state_nxt = STOP;
                        bits_counter_nxt = 3'b0;
                    end
                    else begin
                        bits_counter_nxt = bits_counter + 1;
                    end
                end
                else begin
                    edges_counter_nxt = edges_counter + 1;
                end
            end
        end
        STOP: begin
            if (sck_rising_edge) begin
                if (edges_counter == 15) begin
                    state_nxt = IDLE;
                    edges_counter_nxt = 4'b0;
                end
                else begin
                    edges_counter_nxt = edges_counter + 1;
                end
            end
        end
        default: ;
    endcase
end


/* Transmission controller */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sout <= 1'b1;
        tx_buffer <= 8'b0;
    end
    else begin
        sout <= sout_nxt;
        tx_buffer <= tx_buffer_nxt;
    end
end

always_comb begin
    busy = 1'b1;
    sout_nxt = sout;
    tx_buffer_nxt = tx_buffer;

    case (state)
        IDLE: begin
            busy = 1'b0;
        end
        START: begin
            sout_nxt = 1'b0;
            tx_buffer_nxt = tx_data;

            if (sck_rising_edge && edges_counter == 15) begin
                sout_nxt = tx_buffer[0];
                tx_buffer_nxt = tx_buffer>>1;
            end
        end
        ACTIVE: begin
            if (sck_rising_edge && edges_counter == 15) begin
                if (bits_counter == 7) begin
                    sout_nxt = 1'b1;
                end
                else begin
                    sout_nxt = tx_buffer[0];
                    tx_buffer_nxt = tx_buffer>>1;
                end
            end
        end
        STOP: ;
        default: ;
    endcase
end

endmodule
