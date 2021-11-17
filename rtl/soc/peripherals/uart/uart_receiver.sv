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

module uart_receiver (
    output logic       busy,
    output logic       rx_data_valid,
    output logic [7:0] rx_data,
    output logic       error,
    input logic        clk,
    input logic        rst_n,
    input logic        sck_rising_edge,
    input logic        sin
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

state_t     state, state_nxt;
logic       rx_data_valid_nxt;
logic [7:0] rx_data_nxt;
logic [2:0] bits_counter, bits_counter_nxt;
logic [3:0] edges_counter, edges_counter_nxt;
logic [7:0] rx_buffer, rx_buffer_nxt;
logic       error_nxt;


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
        if (!sin)
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
        rx_data_valid <= 1'b0;
        rx_data <= 8'b0;
        error <= 1'b0;
        rx_buffer <= 8'b0;
    end
    else begin
        rx_data_valid <= rx_data_valid_nxt;
        rx_data <= rx_data_nxt;
        error <= error_nxt;
        rx_buffer <= rx_buffer_nxt;
    end
end

always_comb begin
    busy = 1'b1;
    rx_data_valid_nxt = 1'b0;
    rx_data_nxt = rx_data;
    error_nxt = error;
    rx_buffer_nxt = rx_buffer;

    case (state)
    IDLE: begin
        busy = 1'b0;
    end
    START: begin
        rx_buffer_nxt = 8'b0;
        error_nxt = 1'b0;
    end
    ACTIVE: begin
        if (sck_rising_edge && edges_counter == 7)
            rx_buffer_nxt = {sin, rx_buffer[7:1]};
    end
    STOP: begin
        if (sck_rising_edge) begin
            if (edges_counter == 7) begin
                rx_data_valid_nxt = 1'b1;
                rx_data_nxt = rx_buffer;
                error_nxt = ~sin;
            end
        end
    end
    default: ;
    endcase
end

endmodule
