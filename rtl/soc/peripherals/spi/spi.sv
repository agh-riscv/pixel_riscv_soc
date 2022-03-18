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
    output logic        irq,
    soc_spi_bus.master  spi_bus
);


/**
 * Local variables and signals
 */

spi_regs_t  regs, regs_nxt;

logic       clk_divider_valid;

logic [7:0] rx_fifo_rdata;
logic       rx_fifo_full, rx_fifo_empty, rx_fifo_pop,
            tx_fifo_full, tx_fifo_empty, tx_fifo_push,
            txfe_irq;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

assign irq = txfe_irq;
assign txfe_irq = regs.ier.txfeie & regs.isr.txfef;


/**
 * Submodules placement
 */

spi_master u_spi_master (
    .clk,
    .rst_n,

    .ss0(spi_bus.ss0),
    .ss1(spi_bus.ss1),
    .sck(spi_bus.sck),
    .mosi(spi_bus.mosi),
    .miso(spi_bus.miso),

    .clk_divider(regs.cdr.data),
    .clk_divider_valid,
    .active_ss(regs.cr.active_ss),
    .cpol(regs.cr.cpol),
    .cpha(regs.cr.cpha),

    .rx_fifo_full,
    .rx_fifo_empty,
    .rx_fifo_rdata,
    .rx_fifo_pop,

    .tx_fifo_full,
    .tx_fifo_empty,
    .tx_fifo_wdata(regs.tdr.data),
    .tx_fifo_push
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        SPI_CR_OFFSET, SPI_SR_OFFSET, SPI_TDR_OFFSET, SPI_RDR_OFFSET, SPI_CDR_OFFSET,
        SPI_IER_OFFSET, SPI_ISR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return data_bus.req && data_bus.we && data_bus.addr[11:0] == offset;
endfunction

function automatic logic is_reg_read(logic [11:0] offset);
    return data_bus.req && data_bus.addr[11:0] == offset;
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) data_bus.req |-> is_offset_valid(data_bus.addr[11:0])) else
    $warning("incorrect offset requested: 0x%x", data_bus.addr[11:0]);


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
    end else begin
        data_bus.rvalid <= data_bus.gnt;
        data_bus.err <= data_bus.gnt && !is_offset_valid(data_bus.addr[11:0]);
    end
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        regs <= {{7{32'b0}}};
        clk_divider_valid <= 1'b0;
        tx_fifo_push <= 1'b0;
    end else begin
        regs <= regs_nxt;
        clk_divider_valid <= is_reg_written(SPI_CDR_OFFSET);
        tx_fifo_push <= is_reg_written(SPI_TDR_OFFSET);
    end
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        SPI_CR_OFFSET:      regs_nxt.cr = data_bus.wdata;
        SPI_SR_OFFSET:      regs_nxt.sr = data_bus.wdata;
        SPI_TDR_OFFSET:     regs_nxt.tdr = data_bus.wdata;
        SPI_RDR_OFFSET:     regs_nxt.rdr = data_bus.wdata;
        SPI_CDR_OFFSET:     regs_nxt.cdr = data_bus.wdata;
        SPI_IER_OFFSET:     regs_nxt.ier = data_bus.wdata;
        SPI_ISR_OFFSET:     regs_nxt.isr = data_bus.wdata;
        endcase
    end

    rx_fifo_pop = is_reg_read(SPI_RDR_OFFSET);

    /* 0x004: status reg */
    regs_nxt.sr.tx_fifo_empty = tx_fifo_empty;
    regs_nxt.sr.tx_fifo_full = tx_fifo_full;
    regs_nxt.sr.rx_fifo_empty = rx_fifo_empty;
    regs_nxt.sr.rx_fifo_full = rx_fifo_full;

    /* 0x00c: receiver data reg */
    regs_nxt.rdr.data = rx_fifo_rdata;

    /* 0x018: interrupt status reg */
    if (!regs.sr.tx_fifo_empty && regs_nxt.sr.tx_fifo_empty)
        regs_nxt.isr.txfef = 1'b1;
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            SPI_CR_OFFSET:      data_bus.rdata <= regs.cr;
            SPI_SR_OFFSET:      data_bus.rdata <= regs.sr;
            SPI_TDR_OFFSET:     data_bus.rdata <= regs.tdr;
            SPI_RDR_OFFSET:     data_bus.rdata <= regs.rdr;
            SPI_CDR_OFFSET:     data_bus.rdata <= regs.cdr;
            SPI_IER_OFFSET:     data_bus.rdata <= regs.ier;
            SPI_ISR_OFFSET:     data_bus.rdata <= regs.isr;
            endcase
        end
    end
end

endmodule
