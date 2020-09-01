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

import spi_pkg::*;

module spi (
    output logic ss,
    output logic sck,
    output logic mosi,
    input logic  clk,
    input logic  rst_n,
    input logic  miso,

    ibex_data_bus.slave data_bus
);


/**
 * Local variables and signals
 */

spi_t       spi;
spi_reg_t   requested_reg;
logic [7:0] rx_data;
logic       busy, tx_data_valid, rx_data_valid, clk_divider_valid;


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;


/**
 * Submodules placement
 */

spi_offset_decoder u_spi_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

spi_master u_spi_master (
    .ss,
    .sck,
    .mosi,
    .busy,
    .rx_data_valid,
    .rx_data,
    .clk,
    .rst_n,
    .tx_data_valid,
    .tx_data(spi.tdr.data),
    .clk_divider_valid,
    .clk_divider(spi.cdr.data),
    .miso,
    .cpol(spi.cr.cpol),
    .cpha(spi.cr.cpha)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        spi.cr <= 32'b0;
        spi.sr <= 32'b0;
        spi.tdr <= 32'b0;
        spi.rdr <= 32'b0;
        spi.cdr <= 32'b0;
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;
    end
    else begin
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;

        if (data_bus.we) begin
            case (requested_reg)
                SPI_CR: begin
                    spi.cr <= data_bus.wdata;
                end
                SPI_SR: begin
                    spi.sr <= data_bus.wdata;
                end
                SPI_TDR: begin
                    spi.tdr <= data_bus.wdata;
                    tx_data_valid <= 1'b1;
                end
                SPI_CDR: begin
                    spi.cdr <= data_bus.wdata;
                    clk_divider_valid <= 1'b1;
                end
            endcase
        end

        if (spi.sr.rxne && requested_reg == SPI_RDR)
            spi.sr.rxne <= 1'b0;

        if (rx_data_valid) begin
            spi.rdr.data <= rx_data;
            spi.sr.rxne <= 1'b1;
        end

        spi.sr.txact <= busy;
    end
end


/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case(requested_reg)
            SPI_CR:     data_bus.rdata <= spi.cr;
            SPI_SR:     data_bus.rdata <= spi.sr;
            SPI_TDR:    data_bus.rdata <= spi.tdr;
            SPI_RDR:    data_bus.rdata <= spi.rdr;
            SPI_CDR:    data_bus.rdata <= spi.cdr;
        endcase
    end
end

endmodule
