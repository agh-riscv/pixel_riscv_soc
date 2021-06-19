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

import pmc_ac_pkg::*;

module pmc_ac (
    input logic                 clk,
    input logic                 rst_n,
    ibex_data_bus.slave         data_bus,
    soc_pm_analog_config.master pm_analog_config
);


/**
 * Local variables and signals
 */

pmc_ac_t     pmc_ac;
pmc_ac_reg_t requested_reg;


/**
 * Signals assignments
 */

assign pm_analog_config.res[127:96] = pmc_ac.reg_3.res;
assign pm_analog_config.res[95:64] = pmc_ac.reg_2.res;
assign pm_analog_config.res[63:32] = pmc_ac.reg_1.res;
assign pm_analog_config.res[31:0] = pmc_ac.reg_0.res;


/**
 * Submodules placement
 */

pmc_ac_offset_decoder u_pmc_ac_offset_decoder (
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
        pmc_ac.reg_0 <= 32'b0;
        pmc_ac.reg_1 <= 32'b0;
        pmc_ac.reg_2 <= 32'b0;
        pmc_ac.reg_3 <= 32'b0;
    end
    else begin
        if (data_bus.we) begin
            case (requested_reg)
            PMC_AC_REG_0:   pmc_ac.reg_0 <= data_bus.wdata;
            PMC_AC_REG_1:   pmc_ac.reg_1 <= data_bus.wdata;
            PMC_AC_REG_2:   pmc_ac.reg_2 <= data_bus.wdata;
            PMC_AC_REG_3:   pmc_ac.reg_3 <= data_bus.wdata;
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
        PMC_AC_REG_0:   data_bus.rdata <= pmc_ac.reg_0;
        PMC_AC_REG_1:   data_bus.rdata <= pmc_ac.reg_1;
        PMC_AC_REG_2:   data_bus.rdata <= pmc_ac.reg_2;
        PMC_AC_REG_3:   data_bus.rdata <= pmc_ac.reg_3;
        endcase
    end
end

endmodule
