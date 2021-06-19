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

import pmc_dc_pkg::*;

module pmc_dc (
    input logic                  clk,
    input logic                  rst_n,
    ibex_data_bus.slave          data_bus,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Local variables and signals
 */

pmc_dc_t     pmc_dc;
pmc_dc_reg_t requested_reg;


/**
 * Signals assignments
 */

assign pm_digital_config.res = pmc_dc.reg_0.res;
assign pm_digital_config.th = pmc_dc.reg_0.th;


/**
 * Submodules placement
 */

pmc_dc_offset_decoder u_pmc_dc_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pmc_dc.reg_0 <= 32'b0;
    end
    else begin
        if (data_bus.we) begin
            case (requested_reg)
            PMC_DC_REG_0:   pmc_dc.reg_0 <= data_bus.wdata;
            endcase
        end
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_bus.rdata <= 32'b0;
    end
    else begin
        case (requested_reg)
        PMC_DC_REG_0:   data_bus.rdata <= pmc_dc.reg_0;
        endcase
    end
end

endmodule
