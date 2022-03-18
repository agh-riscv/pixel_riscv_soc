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

module spi_slave (
    output logic       busy,
    output logic [7:0] rx_data,
    input logic        clk,
    input logic        rst_n,
    input logic [7:0]  tx_data,

    output logic       miso,
    input logic        ss,
    input logic        sck,
    input logic        mosi
);


/**
 * User defined types
 */

typedef enum logic {
    IDLE,
    TRANSMISSION
} state_t;


/**
 * Local variables and signals
 */

logic [3:0] bits_counter, bits_counter_nxt;
logic       sck_edge_detected, sck_edge_type, sck_rising_edge, sck_falling_edge;
logic [7:0] tx_buffer, tx_buffer_nxt;
logic [7:0] rx_data_nxt, rx_buffer, rx_buffer_nxt;
logic       miso_nxt;

state_t state, state_nxt;


/**
 * Signals assignments
 */

assign busy = (state != IDLE);
assign sck_rising_edge = sck_edge_detected & sck_edge_type;
assign sck_falling_edge = sck_edge_detected & ~sck_edge_type;


/**
 * Submodules placement
 */

edge_detector u_edge_detector (
    .edge_detected(sck_edge_detected),
    .edge_type(sck_edge_type),          /* 0 - falling, 1 - rising */
    .clk,
    .rst_n,
    .data_in(sck)
);


/**
 * Module internal logic
 */

/* State controller */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state        <= IDLE;
        bits_counter <= 4'b0;
    end else begin
        state        <= state_nxt;
        bits_counter <= bits_counter_nxt;
    end
end

always_comb begin
    case (state)
        IDLE: begin
            state_nxt        = !ss ? TRANSMISSION : IDLE;
            bits_counter_nxt = 0;
        end
        TRANSMISSION: begin
            if (ss) begin
                state_nxt        = IDLE;
                bits_counter_nxt = 4'b0;
            end else begin
                state_nxt        = TRANSMISSION;
                bits_counter_nxt = sck_rising_edge ? bits_counter + 1 : bits_counter;
            end
        end
        default: begin
            state_nxt        = IDLE;
            bits_counter_nxt = 0;
        end
    endcase
end


/* Transmission controller */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        miso      <= 1'b0;
        rx_data   <= 8'b0;
        tx_buffer <= 8'b0;
        rx_buffer <= 8'b0;
    end else begin
        miso      <= miso_nxt;
        rx_data   <= rx_data_nxt;
        tx_buffer <= tx_buffer_nxt;
        rx_buffer <= rx_buffer_nxt;
    end
end

always_comb begin
    miso_nxt      = miso;
    rx_data_nxt   = rx_data;
    tx_buffer_nxt = tx_buffer;
    rx_buffer_nxt = rx_buffer;

    case (state)
        IDLE: begin
            miso_nxt  = 1'b0;
        end
        TRANSMISSION: begin
            if (sck_rising_edge) begin
                if (bits_counter == 0) begin
                    miso_nxt      = tx_data[7];
                    tx_buffer_nxt = {tx_data[6:0], 1'b0};
                end else begin
                    miso_nxt      = tx_buffer[7];
                    tx_buffer_nxt = {tx_buffer[6:0], 1'b0};
                end
            end else if (sck_falling_edge) begin
                rx_buffer_nxt = {rx_buffer[6:0], mosi};
                if (bits_counter == 8)
                    rx_data_nxt = {rx_buffer[6:0], mosi};
            end
        end
        default: ;
    endcase
end

endmodule
