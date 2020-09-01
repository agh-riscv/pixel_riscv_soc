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

module spi_master (
    output logic       ss,
    output logic       sck,
    output logic       mosi,
    output logic       busy,
    output logic       rx_data_valid,
    output logic [7:0] rx_data,

    input logic        clk,
    input logic        rst_n,
    input logic        tx_data_valid,
    input logic [7:0]  tx_data,
    input logic        clk_divider_valid,
    input logic [7:0]  clk_divider,
    input logic        miso,
    input logic        cpol,
    input logic        cpha
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

logic       ss_nxt, sck_nxt, mosi_nxt, rx_data_valid_nxt;
logic [3:0] bits_counter, bits_counter_nxt;
logic [7:0] tx_buffer, tx_buffer_nxt;
logic [7:0] rx_data_nxt, rx_buffer, rx_buffer_nxt;
logic       sck_generator_en, sck_generator_en_nxt, leading_edge, trailing_edge;
logic       sck_polarity, sck_phase, sck_polarity_nxt, sck_phase_nxt;

state_t state, state_nxt;


/**
 * Submodules placement
 */

serial_clock_generator u_serial_clock_generator (
    .sck(),
    .rising_edge(leading_edge),
    .falling_edge(trailing_edge),
    .clk,
    .rst_n,
    .en(sck_generator_en),
    .clk_divider_valid,
    .clk_divider
);


/**
 * Module internal logic
 */

/* State controller */

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
            if (tx_data_valid)
                state_nxt = START;
        end
        START: begin
            state_nxt = ACTIVE;
        end
        ACTIVE: begin
            if (leading_edge) begin
                bits_counter_nxt = bits_counter + 1;
            end
            else if (trailing_edge) begin
                if (bits_counter == 8) begin
                    state_nxt = STOP;
                    bits_counter_nxt = 4'b0;
                end
            end
        end
        STOP: begin
            if (leading_edge)
                state_nxt = IDLE;
        end
        default: begin
            state_nxt = IDLE;
        end
    endcase
end


/* Transmission controller */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ss <= 1'b1;
        sck <= 1'b0;
        mosi <= 1'b0;
        rx_data_valid <= 1'b0;
        rx_data <= 8'b0;
        sck_generator_en <= 1'b0;
        tx_buffer <= 8'b0;
        rx_buffer <= 8'b0;
        sck_polarity <= 1'b0;
        sck_phase <= 1'b0;
    end
    else begin
        ss <= ss_nxt;
        sck <= sck_nxt;
        mosi <= mosi_nxt;
        rx_data_valid <= rx_data_valid_nxt;
        rx_data <= rx_data_nxt;
        sck_generator_en <= sck_generator_en_nxt;
        tx_buffer <= tx_buffer_nxt;
        rx_buffer <= rx_buffer_nxt;
        sck_polarity <= sck_polarity_nxt;
        sck_phase <= sck_phase_nxt;
    end
end

always_comb begin
    busy = 1'b1;
    ss_nxt = ss;
    sck_nxt = sck;
    mosi_nxt = mosi;
    rx_data_valid_nxt = 1'b0;
    rx_data_nxt = rx_data;
    sck_generator_en_nxt = sck_generator_en;
    tx_buffer_nxt = tx_buffer;
    rx_buffer_nxt = rx_buffer;
    sck_polarity_nxt = sck_polarity;
    sck_phase_nxt = sck_phase;

    case (state)
        IDLE: begin
            busy = 1'b0;
            sck_nxt = cpol;
            sck_polarity_nxt = cpol;
            sck_phase_nxt = cpha;
        end
        START: begin
            ss_nxt = 1'b0;
            sck_generator_en_nxt = 1'b1;
            rx_buffer_nxt = 8'b0;
            tx_buffer_nxt = tx_data;

            if (~sck_phase) begin
                mosi_nxt = tx_data[7];
                tx_buffer_nxt = {tx_data[6:0], 1'b0};
            end
        end
        ACTIVE: begin
            if (leading_edge) begin
                sck_nxt = ~sck_polarity;

                if (~sck_phase) begin
                    rx_buffer_nxt = {rx_buffer[6:0], miso};
                end
                else begin
                    mosi_nxt = tx_buffer[7];
                    tx_buffer_nxt = {tx_buffer[6:0], 1'b0};
                end
            end
            else if (trailing_edge) begin
                sck_nxt = sck_polarity;

                if (~sck_phase) begin
                    mosi_nxt = tx_buffer[7];
                    tx_buffer_nxt = {tx_buffer[6:0], 1'b0};
                end
                else begin
                    rx_buffer_nxt = {rx_buffer[6:0], miso};
                end

                if (bits_counter == 8) begin
                    rx_data_valid_nxt = 1'b1;

                    if (sck_phase)
                        rx_data_nxt = {rx_buffer[6:0], miso};
                    else
                        rx_data_nxt = rx_buffer;
                end
            end
        end
        STOP: begin
            if (leading_edge) begin
                ss_nxt = 1'b1;
                sck_generator_en_nxt = 1'b0;
            end
        end
        default: ;
    endcase
end

endmodule
