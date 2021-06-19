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

import uart_pkg::*;

module uart (
    input logic         clk,
    input logic         rst_n,
    ibex_data_bus.slave data_bus,
    soc_uart_bus.master uart_bus
);


/**
 * Local variables and signals
 */

uart_t      uart;
uart_reg_t  requested_reg;
logic [7:0] rx_data;
logic       tx_data_valid, rx_data_valid, clk_divider_valid, tx_busy, rx_error;
logic       sck_rising_edge, sck;


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;


/**
 * Submodules placement
 */

uart_offset_decoder u_uart_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

serial_clock_generator u_serial_clock_generator (
    .sck,
    .rising_edge(sck_rising_edge),
    .falling_edge(),
    .clk,
    .rst_n,
    .en(uart.cr.en),
    .clk_divider_valid,
    .clk_divider(uart.cdr.data)
);

uart_transmitter u_uart_transmitter (
    .busy(tx_busy),
    .sout(uart_bus.sout),
    .clk,
    .rst_n,
    .sck_rising_edge,
    .tx_data_valid,
    .tx_data(uart.tdr.data)
);

uart_receiver u_uart_receiver (
    .busy(),
    .rx_data_valid,
    .rx_data,
    .error(rx_error),
    .clk,
    .rst_n,
    .sck_rising_edge,
    .sin(uart_bus.sin)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart.cr <= 32'b0;
        uart.sr <= 32'b0;
        uart.tdr <= 32'b0;
        uart.rdr <= 32'b0;
        uart.cdr <= 32'b0;
        clk_divider_valid <= 1'b0;
        tx_data_valid <= 1'b0;
    end
    else begin
        clk_divider_valid <= 1'b0;
        tx_data_valid <= 1'b0;

        if (data_bus.we) begin
            case (requested_reg)
            UART_CR: begin
                uart.cr <= data_bus.wdata;
            end
            UART_SR: begin
                uart.sr <= data_bus.wdata;
            end
            UART_TDR: begin
                uart.tdr <= data_bus.wdata;
                tx_data_valid <= 1'b1;
            end
            UART_CDR: begin
                uart.cdr <= data_bus.wdata;
                clk_divider_valid <= 1'b1;
            end
            endcase
        end

        if (uart.sr.rxne && requested_reg == UART_RDR)
            uart.sr.rxne <= 1'b0;

        if (rx_error)
            uart.sr.rxerr <= 1'b1;

        if (rx_data_valid) begin
            uart.rdr.data <= rx_data;
            uart.sr.rxne <= 1'b1;
        end

        uart.sr.txact <= tx_busy;
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case (requested_reg)
        UART_CR:    data_bus.rdata <= uart.cr;
        UART_SR:    data_bus.rdata <= uart.sr;
        UART_TDR:   data_bus.rdata <= uart.tdr;
        UART_RDR:   data_bus.rdata <= uart.rdr;
        UART_CDR:   data_bus.rdata <= uart.cdr;
        endcase
    end
end

endmodule
