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

import pmc_pkg::*;

module pmc (
    output logic [63:0] pm_din,
    input logic         clk,
    input logic         rst_n,
    input logic [63:0]  pm_dout,

    ibex_data_bus.slave     data_bus,
    pmc_ctrl.master         ctrl,
    pmc_analog_conf.master  analog_conf,
    pmc_digital_conf.master digital_conf
);


/**
 * Local variables and signals
 */

pmc_t        pmc;
pmc_reg_t    requested_reg, read_reg;
logic [31:0] reg_rdata;

ibex_data_bus pmcc_code_ram_data_bus();
ibex_data_bus pmc_ac_data_bus();
ibex_data_bus pmc_dc_data_bus();

logic [31:0] instr;
logic [9:0]  pc_if;
logic        pmcc_rst_n, trigger, waitt;


/**
 * Signals assignments
 */

`ibex_data_bus_assign_inputs(pmcc_code_ram_data_bus, data_bus)
`ibex_data_bus_assign_inputs(pmc_ac_data_bus, data_bus)
`ibex_data_bus_assign_inputs(pmc_dc_data_bus, data_bus)

assign data_bus.err = 1'b0;

assign pm_din[63:32] = pmc.din_1;
assign pm_din[31:0] = pmc.din_0;


/**
 * Submodules placement
 */

pmc_offset_decoder u_pmc_offset_decoder (
    .gnt(data_bus.gnt),
    .rvalid(data_bus.rvalid),
    .requested_reg,
    .clk,
    .rst_n,
    .req(data_bus.req),
    .addr(data_bus.addr)
);

pmcc_code_ram u_pmcc_code_ram (
    .instr,
    .clk,
    .rst_n,
    .pc_if,
    .data_bus(pmcc_code_ram_data_bus)
);

pmcc u_pmcc (
    .pc_if,
    .waitt,
    .clk,
    .rst_n,
    .pmcc_rst_n(pmc.cr.en & ~pmc.cr.rst),
    .trigger(pmc.cr.trg),
    .instr,
    .ctrl
);

pmc_ac u_pmc_ac (
    .clk,
    .rst_n,
    .data_bus(pmc_ac_data_bus),
    .analog_conf
);

pmc_dc u_pmc_dc (
    .clk,
    .rst_n,
    .data_bus(pmc_dc_data_bus),
    .digital_conf
);


/**
 * Module internal logic
 */

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pmc.cr <= 32'b0;
        pmc.sr <= 32'b0;
        pmc.ctrl <= 32'b0;
        pmc.din_0 <= 32'b0;
        pmc.din_1 <= 32'b0;
        pmc.dout_0 <= 32'b0;
        pmc.dout_1 <= 32'b0;
    end
    else begin
        if (data_bus.we) begin
            case (requested_reg)
                PMC_CR:     pmc.cr <= data_bus.wdata;
                PMC_DIN_0:  pmc.din_0 <= data_bus.wdata;
                PMC_DIN_1:  pmc.din_1 <= data_bus.wdata;
            endcase
        end

        if (pmc.cr.trg)
            pmc.cr.trg <= 1'b0;

        if (pmc.cr.rst)
            pmc.cr.rst <= 1'b0;

        pmc.sr.wtt <= waitt;

        pmc.ctrl.res[25:10] <= 16'b0;
        pmc.ctrl.res[9:0] <= ctrl.res;
        pmc.ctrl.write_cfg <= ctrl.write_cfg;
        pmc.ctrl.strobe <= ctrl.strobe;
        pmc.ctrl.gate <= ctrl.gate;
        pmc.ctrl.shB <= ctrl.shB;
        pmc.ctrl.shA <= ctrl.shA;
        pmc.ctrl.clkSh <= ctrl.clkSh;

        pmc.dout_1 <= pm_dout[63:32];
        pmc.dout_0 <= pm_dout[31:0];
    end
end


/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_rdata <= 32'b0;
    end
    else begin
        case(requested_reg)
            PMC_CR:     reg_rdata <= pmc.cr;
            PMC_SR:     reg_rdata <= pmc.sr;
            PMC_CTRL:   reg_rdata <= pmc.ctrl;
            PMC_DIN_0:  reg_rdata <= pmc.din_0;
            PMC_DIN_1:  reg_rdata <= pmc.din_1;
            PMC_DOUT_0: reg_rdata <= pmc.dout_0;
            PMC_DOUT_1: reg_rdata <= pmc.dout_1;
        endcase
    end
end


/* Input signals demultiplexing and output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        read_reg <= PMC_NONE;
    else
        read_reg <= requested_reg;
end

always_comb begin
    pmcc_code_ram_data_bus.req = 1'b0;
    pmc_ac_data_bus.req = 1'b0;
    pmc_dc_data_bus.req = 1'b0;

    case (requested_reg)
        PMCC_CODE_RAM:  pmcc_code_ram_data_bus.req = 1'b1;
        PMC_AC:         pmc_ac_data_bus.req = 1'b1;
        PMC_DC:         pmc_dc_data_bus.req = 1'b1;
    endcase
end

always_comb begin
    data_bus.rdata = reg_rdata;

    case (read_reg)
        PMCC_CODE_RAM:  data_bus.rdata = pmcc_code_ram_data_bus.rdata;
        PMC_AC:         data_bus.rdata = pmc_ac_data_bus.rdata;
        PMC_DC:         data_bus.rdata = pmc_dc_data_bus.rdata;
    endcase
end

endmodule
