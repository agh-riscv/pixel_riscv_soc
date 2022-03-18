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
    output logic        irq,
    soc_uart_bus.master uart_bus
);


/**
 * Local variables and signals
 */

uart_regs_t regs, regs_nxt;
logic [7:0] rx_data;
logic       tx_data_valid, rx_data_valid, clk_divider_valid, tx_busy, rx_error,
            sck_rising_edge, sck, txact_irq, rxne_irq;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

assign irq = txact_irq | rxne_irq;
assign txact_irq = regs.ier.txactie & regs.isr.txactf;
assign rxne_irq = regs.ier.rxneie & regs.isr.rxnef;


/**
 * Submodules placement
 */

serial_clock_generator u_serial_clock_generator (
    .sck,
    .rising_edge(sck_rising_edge),
    .falling_edge(),
    .clk,
    .rst_n,
    .en(regs.cr.en),
    .clk_divider_valid,
    .clk_divider(regs.cdr.data)
);

uart_transmitter u_uart_transmitter (
    .busy(tx_busy),
    .sout(uart_bus.sout),
    .clk,
    .rst_n,
    .sck_rising_edge,
    .tx_data_valid,
    .tx_data(regs.tdr.data)
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
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        UART_CR_OFFSET, UART_SR_OFFSET, UART_TDR_OFFSET, UART_RDR_OFFSET, UART_CDR_OFFSET,
        UART_IER_OFFSET, UART_ISR_OFFSET
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
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;
    end else begin
        regs <= regs_nxt;
        tx_data_valid <= is_reg_written(UART_TDR_OFFSET);
        clk_divider_valid <= is_reg_written(UART_CDR_OFFSET);
    end
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        UART_CR_OFFSET:     regs_nxt.cr = data_bus.wdata;
        UART_SR_OFFSET:     regs_nxt.sr = data_bus.wdata;
        UART_TDR_OFFSET:    regs_nxt.tdr = data_bus.wdata;
        UART_RDR_OFFSET:    regs_nxt.rdr = data_bus.wdata;
        UART_CDR_OFFSET:    regs_nxt.cdr = data_bus.wdata;
        UART_IER_OFFSET:    regs_nxt.ier = data_bus.wdata;
        UART_ISR_OFFSET:    regs_nxt.isr = data_bus.wdata;
        endcase
    end

    /* 0x004: status reg */
    if (rx_error)
        regs_nxt.sr.rxerr = 1'b1;

    regs_nxt.sr.txact = tx_busy;

    if (rx_data_valid)
        regs_nxt.sr.rxne = 1'b1;
    else if (is_reg_read(UART_RDR_OFFSET))
        regs_nxt.sr.rxne = 1'b0;

    /* 0x00c: receiver data reg */
    if (rx_data_valid)
        regs_nxt.rdr.data = rx_data;

    /* 0x018: interrupt status reg */
    if (regs.sr.txact && !regs_nxt.sr.txact)
        regs_nxt.isr.txactf = 1'b1;

    if (!regs.sr.rxne && regs_nxt.sr.rxne)
        regs_nxt.isr.rxnef = 1'b1;
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            UART_CR_OFFSET:     data_bus.rdata <= regs.cr;
            UART_SR_OFFSET:     data_bus.rdata <= regs.sr;
            UART_TDR_OFFSET:    data_bus.rdata <= regs.tdr;
            UART_RDR_OFFSET:    data_bus.rdata <= regs.rdr;
            UART_CDR_OFFSET:    data_bus.rdata <= regs.cdr;
            UART_IER_OFFSET:    data_bus.rdata <= regs.ier;
            UART_ISR_OFFSET:    data_bus.rdata <= regs.isr;
            endcase
        end
    end
end

endmodule
