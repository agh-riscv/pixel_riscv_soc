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

import timer_pkg::*;

module timer (
    input logic          clk,
    input logic          rst_n,
    ibex_data_bus.slave  data_bus,
    output logic         irq
);


/**
 * Local variables and signals
 */

timer_regs_t regs, regs_nxt;
logic [31:0] counter;
logic        active, match_occurred, mtch_irq;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

assign irq = mtch_irq;
assign mtch_irq = regs.ier.mtchie & regs.isr.mtchf;


/**
 * Submodules placement
 */

timer_core u_timer_core (
    .active,
    .match_occurred,
    .counter,
    .clk,
    .rst_n,
    .trigger(regs.cr.trg),
    .halt(regs.cr.hlt),
    .single_shot(regs.cr.sngl),
    .compare_value(regs.cmpr)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        TIMER_CR_OFFSET, TIMER_SR_OFFSET, TIMER_CNTR_OFFSET, TIMER_CMPR_OFFSET,
        TIMER_IER_OFFSET, TIMER_ISR_OFFSET
    };
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
    if (!rst_n)
        regs <= {{6{32'b0}}};
    else
        regs <= regs_nxt;
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        TIMER_CR_OFFSET:    regs_nxt.cr = data_bus.wdata;
        TIMER_SR_OFFSET:    regs_nxt.sr = data_bus.wdata;
        TIMER_CNTR_OFFSET:  regs_nxt.cntr = data_bus.wdata;
        TIMER_CMPR_OFFSET:  regs_nxt.cmpr = data_bus.wdata;
        TIMER_IER_OFFSET:   regs_nxt.ier = data_bus.wdata;
        TIMER_ISR_OFFSET:   regs_nxt.isr = data_bus.wdata;
        endcase
    end

    /* 0x000: control reg */
    if (regs.cr.hlt)
        regs_nxt.cr.hlt = 1'b0;

    if (regs.cr.trg)
        regs_nxt.cr.trg = 1'b0;

    /* 0x004: status reg */
    regs_nxt.sr.act = active;

    if (match_occurred)
        regs_nxt.sr.mtch = 1'b1;

    /* 0x014: interrupt status reg */
    if (!regs.sr.mtch && regs_nxt.sr.mtch)
        regs_nxt.isr.mtchf = 1'b1;
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            TIMER_CR_OFFSET:    data_bus.rdata <= regs.cr;
            TIMER_SR_OFFSET:    data_bus.rdata <= regs.sr;
            TIMER_CNTR_OFFSET:  data_bus.rdata <= regs.cntr;
            TIMER_CMPR_OFFSET:  data_bus.rdata <= regs.cmpr;
            TIMER_IER_OFFSET:   data_bus.rdata <= regs.ier;
            TIMER_ISR_OFFSET:   data_bus.rdata <= regs.isr;
            endcase
        end
    end
end

endmodule
