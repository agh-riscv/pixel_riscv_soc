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

timer_t      timer;
timer_reg_t  requested_reg;
logic [31:0] counter;
logic        active, match_occurred;


/**
 * Signals assignments
 */

assign data_bus.err = 1'b0;
assign timer_bus.irq = timer.sr.mtch;


/**
 * Submodules placement
 */

timer_offset_decoder u_timer_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

timer_core u_timer_core (
    .active,
    .match_occurred,
    .counter,
    .clk,
    .rst_n,
    .trigger(timer.cr.trg),
    .halt(timer.cr.hlt),
    .single_shot(timer.cr.sngl),
    .compare_value(timer.cmpr)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer.cr <= 32'b0;
        timer.sr <= 32'b0;
        timer.cntr <= 32'b0;
        timer.cmpr <= 32'b0;
    end
    else begin
        timer.cntr <= counter;

        if (data_bus.we) begin
            case (requested_reg)
            TIMER_CR:   timer.cr <= data_bus.wdata;
            TIMER_SR:   timer.sr <= data_bus.wdata;
            TIMER_CNTR: timer.cntr <= data_bus.wdata;
            TIMER_CMPR: timer.cmpr <= data_bus.wdata;
            endcase
        end

        if (timer.cr.trg)
            timer.cr.trg <= 1'b0;

        if (timer.cr.hlt)
            timer.cr.hlt <= 1'b0;

        if (match_occurred)
            timer.sr.mtch <= 1'b1;

        timer.sr.act <= active;
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case (requested_reg)
        TIMER_CR:   data_bus.rdata <= timer.cr;
        TIMER_SR:   data_bus.rdata <= timer.sr;
        TIMER_CNTR: data_bus.rdata <= timer.cntr;
        TIMER_CMPR: data_bus.rdata <= timer.cmpr;
        endcase
    end
end

endmodule
