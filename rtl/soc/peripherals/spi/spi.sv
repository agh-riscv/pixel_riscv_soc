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
    input logic         clk,
    input logic         rst_n,
    ibex_data_bus.slave data_bus,
    soc_spi_bus.master  spi_bus
);


/**
 * Local variables and signals
 */

spi_regs_t  spi_regs, spi_regs_nxt;
logic [7:0] rx_data;
logic       busy, tx_data_valid, rx_data_valid, clk_divider_valid;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;


/**
 * Submodules placement
 */

spi_master u_spi_master (
    .ss(spi_bus.ss),
    .sck(spi_bus.sck),
    .mosi(spi_bus.mosi),
    .busy,
    .rx_data_valid,
    .rx_data,
    .clk,
    .rst_n,
    .tx_data_valid,
    .tx_data(spi_regs.tdr.data),
    .clk_divider_valid,
    .clk_divider(spi_regs.cdr.data),
    .miso(spi_bus.miso),
    .cpol(spi_regs.cr.cpol),
    .cpha(spi_regs.cr.cpha)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        `SPI_CR_OFFSET, `SPI_SR_OFFSET, `SPI_TDR_OFFSET, `SPI_RDR_OFFSET, `SPI_CDR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return data_bus.req && data_bus.we && data_bus.addr[11:0] == offset;
endfunction

function automatic logic is_reg_read(logic [11:0] offset);
    return data_bus.req && data_bus.addr[11:0] == offset;
endfunction


/**
 * Module internal logic
 */

/* Ibex data bus handling */

always_comb begin
    data_bus.gnt = data_bus.req;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rvalid <= 1'b0;
        data_bus.err <= 1'b0;
    end
    else begin
        data_bus.rvalid <= data_bus.gnt;
        data_bus.err <= data_bus.gnt && !is_offset_valid(data_bus.addr[11:0]);
    end
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        spi_regs <= {{5{32'b0}}};
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;
    end
    else begin
        spi_regs <= spi_regs_nxt;
        tx_data_valid <= is_reg_written(`SPI_TDR_OFFSET);
        clk_divider_valid <= is_reg_written(`SPI_CDR_OFFSET);
    end
end

always_comb begin
    spi_regs_nxt = spi_regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        `SPI_CR_OFFSET:     spi_regs_nxt.cr = data_bus.wdata;
        `SPI_SR_OFFSET:     spi_regs_nxt.sr = data_bus.wdata;
        `SPI_TDR_OFFSET:    spi_regs_nxt.tdr = data_bus.wdata;
        `SPI_RDR_OFFSET:    spi_regs_nxt.rdr = data_bus.wdata;
        `SPI_CDR_OFFSET:    spi_regs_nxt.cdr = data_bus.wdata;
        endcase
    end

    /* 0x04: status reg */
    spi_regs_nxt.sr.txact = busy;

    if (rx_data_valid)
        spi_regs_nxt.sr.rxne = 1'b1;
    else if (is_reg_read(`SPI_RDR_OFFSET))
        spi_regs_nxt.sr.rxne = 1'b0;

    /* 0x00c: receiver data reg */
    if (rx_data_valid)
        spi_regs_nxt.rdr.data = rx_data;
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            `SPI_CR_OFFSET:     data_bus.rdata <= spi_regs.cr;
            `SPI_SR_OFFSET:     data_bus.rdata <= spi_regs.sr;
            `SPI_TDR_OFFSET:    data_bus.rdata <= spi_regs.tdr;
            `SPI_RDR_OFFSET:    data_bus.rdata <= spi_regs.rdr;
            `SPI_CDR_OFFSET:    data_bus.rdata <= spi_regs.cdr;
            endcase
        end
    end
end

endmodule
