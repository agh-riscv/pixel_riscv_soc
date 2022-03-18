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
    input logic        clk,
    input logic        rst_n,

    output logic       ss0,
    output logic       ss1,
    output logic       sck,
    output logic       mosi,
    input logic        miso,

    input logic [7:0]  clk_divider,
    input logic        clk_divider_valid,
    input logic        active_ss,
    input logic        cpol,
    input logic        cpha,

    output logic       rx_fifo_full,
    output logic       rx_fifo_empty,
    output logic [7:0] rx_fifo_rdata,
    input logic        rx_fifo_pop,

    output logic       tx_fifo_full,
    output logic       tx_fifo_empty,
    input logic [7:0]  tx_fifo_wdata,
    input logic        tx_fifo_push
);


/**
 * User defined types
 */

typedef enum logic [2:0] {
    IDLE,
    START,
    BYTE_TRANSMISSION,
    INTER_BYTE_DELAY,
    STOP
} state_t;


/**
 * Local variables and signals
 */

localparam  FIFO_SIZE = 8;

state_t     state, state_nxt;
logic [3:0] bits_counter, bits_counter_nxt;

logic       ss, ss_nxt, sck_nxt, mosi_nxt;

logic       sck_generator_en, sck_generator_en_nxt, leading_edge, trailing_edge;

logic [7:0] rx_fifo_wdata, tx_fifo_rdata;
logic       rx_fifo_push, tx_fifo_pop;

logic [7:0] rx_buffer, rx_buffer_nxt, tx_buffer, tx_buffer_nxt;


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

fifo #(
    .SIZE(FIFO_SIZE)
) u_rx_fifo (
    .clk,
    .rst_n,

    .full(rx_fifo_full),
    .empty(rx_fifo_empty),
    .rdata(rx_fifo_rdata),
    .push(rx_fifo_push),
    .pop(rx_fifo_pop),
    .wdata(rx_fifo_wdata)
);

fifo #(
    .SIZE(FIFO_SIZE)
) u_tx_fifo (
    .clk,
    .rst_n,

    .full(tx_fifo_full),
    .empty(tx_fifo_empty),
    .rdata(tx_fifo_rdata),
    .push(tx_fifo_push),
    .pop(tx_fifo_pop),
    .wdata(tx_fifo_wdata)
);


/**
 * Module internal logic
 */

/* State controller */

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
        if (!tx_fifo_empty)
            state_nxt = START;
    end
    START: begin
        if (trailing_edge)
            state_nxt = BYTE_TRANSMISSION;
    end
    BYTE_TRANSMISSION: begin
        if (leading_edge) begin
            bits_counter_nxt = bits_counter + 1;
        end else if (trailing_edge) begin
            if (bits_counter == 8) begin
                state_nxt = tx_fifo_empty ? STOP : INTER_BYTE_DELAY;
                bits_counter_nxt = 4'b0;
            end
        end
    end
    INTER_BYTE_DELAY: begin
        if (trailing_edge)
            state_nxt = BYTE_TRANSMISSION;
    end
    STOP: begin
        if (trailing_edge)
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
        sck_generator_en <= 1'b0;
        rx_buffer <= 8'b0;
        tx_buffer <= 8'b0;
    end else begin
        ss <= ss_nxt;
        sck <= sck_nxt;
        mosi <= mosi_nxt;
        sck_generator_en <= sck_generator_en_nxt;
        rx_buffer <= rx_buffer_nxt;
        tx_buffer <= tx_buffer_nxt;
    end
end

always_comb begin
    ss_nxt = ss;
    sck_nxt = sck;
    mosi_nxt = mosi;
    sck_generator_en_nxt = sck_generator_en;
    tx_buffer_nxt = tx_buffer;
    rx_buffer_nxt = rx_buffer;
    tx_fifo_pop = 1'b0;
    rx_fifo_push = 1'b0;
    rx_fifo_wdata = 8'b0;

    case (state)
    IDLE: begin
        sck_nxt = cpol;
    end
    START: begin
        ss_nxt = 1'b0;
        sck_generator_en_nxt = 1'b1;

        if (trailing_edge) begin
            rx_buffer_nxt = 8'b0;
            tx_buffer_nxt = tx_fifo_rdata;
            tx_fifo_pop = 1'b1;

            if (~cpha) begin
                mosi_nxt = tx_fifo_rdata[7];
                tx_buffer_nxt = {tx_fifo_rdata[6:0], 1'b0};
            end
        end
    end
    BYTE_TRANSMISSION: begin
        if (leading_edge) begin
            sck_nxt = ~cpol;

            if (~cpha) begin
                rx_buffer_nxt = {rx_buffer[6:0], miso};
            end else begin
                mosi_nxt = tx_buffer[7];
                tx_buffer_nxt = {tx_buffer[6:0], 1'b0};
            end
        end else if (trailing_edge) begin
            sck_nxt = cpol;

            if (~cpha) begin
                mosi_nxt = tx_buffer[7];
                tx_buffer_nxt = {tx_buffer[6:0], 1'b0};
            end else begin
                rx_buffer_nxt = {rx_buffer[6:0], miso};
            end

            if (bits_counter == 8) begin
                rx_fifo_wdata = rx_buffer_nxt;
                rx_fifo_push = 1'b1;
            end
        end
    end
    INTER_BYTE_DELAY: begin
        if (trailing_edge) begin
            tx_buffer_nxt = tx_fifo_rdata;
            tx_fifo_pop = 1'b1;

            if (~cpha) begin
                mosi_nxt = tx_fifo_rdata[7];
                tx_buffer_nxt = {tx_fifo_rdata[6:0], 1'b0};
            end
        end
    end
    STOP: begin
        if (trailing_edge) begin
            ss_nxt = 1'b1;
            sck_generator_en_nxt = 1'b0;
        end
    end
    default: ;
    endcase
end

always_comb begin
    if (active_ss) begin
        ss1 = ss;
        ss0 = 1'b1;
    end else begin
        ss1 = 1'b1;
        ss0 = ss;
    end
end

endmodule
