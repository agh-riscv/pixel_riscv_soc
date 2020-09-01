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

import tmr_pkg::*;

module tmr (
    output logic irq,
    input logic  clk,
    input logic  rst_n,

    ibex_data_bus.slave data_bus
);


/**
 * Local variables and signals
 */

tmr_t        tmr;
tmr_reg_t    requested_reg;
logic [31:0] counter;
logic        active, match_occurred;


/**
 * Signals assignments
 */

assign irq = tmr.sr.mtch;

assign data_bus.err = 1'b0;


/**
 * Submodules placement
 */

tmr_offset_decoder u_tmr_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

timer u_timer (
    .active,
    .match_occurred,
    .counter,
    .clk,
    .rst_n,
    .trigger(tmr.cr.trg),
    .halt(tmr.cr.hlt),
    .single_shot(tmr.cr.sngl),
    .compare_value(tmr.cmpr)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmr.cr <= 32'b0;
        tmr.sr <= 32'b0;
        tmr.cntr <= 32'b0;
        tmr.cmpr <= 32'b0;
    end
    else begin
        tmr.cntr <= counter;

        if (data_bus.we) begin
            case (requested_reg)
                TMR_CR:     tmr.cr <= data_bus.wdata;
                TMR_SR:     tmr.sr <= data_bus.wdata;
                TMR_CNTR:   tmr.cntr <= data_bus.wdata;
                TMR_CMPR:   tmr.cmpr <= data_bus.wdata;
            endcase
        end

        if (tmr.cr.trg)
            tmr.cr.trg <= 1'b0;

        if (tmr.cr.hlt)
            tmr.cr.hlt <= 1'b0;

        if (match_occurred)
            tmr.sr.mtch <= 1'b1;

        tmr.sr.act <= active;
    end
end


/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case(requested_reg)
            TMR_CR:     data_bus.rdata <= tmr.cr;
            TMR_SR:     data_bus.rdata <= tmr.sr;
            TMR_CNTR:   data_bus.rdata <= tmr.cntr;
            TMR_CMPR:   data_bus.rdata <= tmr.cmpr;
        endcase
    end
end

endmodule
