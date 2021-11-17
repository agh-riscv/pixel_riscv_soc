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
    soc_timer_bus.master timer_bus
);


/**
 * Local variables and signals
 */

timer_regs_t timer_regs, timer_regs_nxt;
logic [31:0] counter;
logic        active, match_occurred;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

/* 0x004: status reg */
assign timer_bus.irq = timer_regs.sr.mtch;


/**
 * Submodules placement
 */

timer_core u_timer_core (
    .active,
    .match_occurred,
    .counter,
    .clk,
    .rst_n,
    .trigger(timer_regs.cr.trg),
    .halt(timer_regs.cr.hlt),
    .single_shot(timer_regs.cr.sngl),
    .compare_value(timer_regs.cmpr)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        `TIMER_CR_OFFSET, `TIMER_SR_OFFSET, `TIMER_CNTR_OFFSET, `TIMER_CMPR_OFFSET
    };
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
    if (!rst_n)
        timer_regs <= {{4{32'b0}}};
    else
        timer_regs <= timer_regs_nxt;
end

always_comb begin
    timer_regs_nxt = timer_regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[11:0])
        `TIMER_CR_OFFSET:   timer_regs_nxt.cr = data_bus.wdata;
        `TIMER_SR_OFFSET:   timer_regs_nxt.sr = data_bus.wdata;
        `TIMER_CNTR_OFFSET: timer_regs_nxt.cntr = data_bus.wdata;
        `TIMER_CMPR_OFFSET: timer_regs_nxt.cmpr = data_bus.wdata;
        endcase
    end

    /* 0x000: control reg */
    if (timer_regs.cr.hlt)
        timer_regs_nxt.cr.hlt = 1'b0;

    if (timer_regs.cr.trg)
        timer_regs_nxt.cr.trg = 1'b0;

    /* 0x004: status reg */
    timer_regs_nxt.sr.act = active;

    if (match_occurred)
        timer_regs_nxt.sr.mtch = 1'b1;
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        if (data_bus.req) begin
            case (data_bus.addr[11:0])
            `TIMER_CR_OFFSET:   data_bus.rdata <= timer_regs.cr;
            `TIMER_SR_OFFSET:   data_bus.rdata <= timer_regs.sr;
            `TIMER_CNTR_OFFSET: data_bus.rdata <= timer_regs.cntr;
            `TIMER_CMPR_OFFSET: data_bus.rdata <= timer_regs.cmpr;
            endcase
        end
    end
end

endmodule
