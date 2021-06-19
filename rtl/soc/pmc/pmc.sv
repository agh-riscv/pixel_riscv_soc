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
    input logic                  clk,
    input logic                  rst_n,
    ibex_data_bus.slave          data_bus,
    soc_pm_ctrl.master           pm_ctrl,
    soc_pm_data.master           pm_data,
    soc_pm_analog_config.master  pm_analog_config,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Local variables and signals
 */

pmc_t              pmc;
pmc_reg_t          requested_reg, read_reg;
logic [31:0]       reg_rdata;
logic [31:0][15:0] dout, din;

ibex_data_bus pmcc_code_ram_data_bus ();
ibex_data_bus pmc_ac_data_bus ();
ibex_data_bus pmc_dc_data_bus ();

logic [31:0] instr;
logic [9:0]  pc_if;
logic        pmcc_rst_n, trigger, waitt;


/**
 * Signals assignments
 */

`data_bus_assign_inputs(pmcc_code_ram_data_bus)
`data_bus_assign_inputs(pmc_ac_data_bus)
`data_bus_assign_inputs(pmc_dc_data_bus)

assign data_bus.err = 1'b0;

assign {dout[1], dout[0]} = pmc.dout_0;
assign {dout[3], dout[2]} = pmc.dout_1;
assign {dout[5], dout[4]} = pmc.dout_2;
assign {dout[7], dout[6]} = pmc.dout_3;
assign {dout[9], dout[8]} = pmc.dout_4;
assign {dout[11], dout[10]} = pmc.dout_5;
assign {dout[13], dout[12]} = pmc.dout_6;
assign {dout[15], dout[14]} = pmc.dout_7;
assign {dout[17], dout[16]} = pmc.dout_8;
assign {dout[19], dout[18]} = pmc.dout_9;
assign {dout[21], dout[20]} = pmc.dout_10;
assign {dout[23], dout[22]} = pmc.dout_11;
assign {dout[25], dout[24]} = pmc.dout_12;
assign {dout[27], dout[26]} = pmc.dout_13;
assign {dout[29], dout[28]} = pmc.dout_14;
assign {dout[31], dout[30]} = pmc.dout_15;


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
    .pmcc_rst_n(pmc.cr.pmcc_rst_n),
    .trigger(pmc.cr.pmcc_trg),
    .instr,
    .pm_ctrl
);

pmc_transmitter u_pmc_transmitter (
    .pm_din(pm_data.din),
    .clk,
    .rst_n,
    .sh(pm_ctrl.shA),
    .pclk(pm_ctrl.clkSh),
    .dout
);

pmc_receiver u_pmc_receiver (
    .din,
    .clk,
    .rst_n,
    .sh(pm_ctrl.shA),
    .pclk(pm_ctrl.clkSh),
    .pm_dout(pm_data.dout)
);

pmc_ac u_pmc_ac (
    .clk,
    .rst_n,
    .data_bus(pmc_ac_data_bus),
    .pm_analog_config
);

pmc_dc u_pmc_dc (
    .clk,
    .rst_n,
    .data_bus(pmc_dc_data_bus),
    .pm_digital_config
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
        pmc.dout_0 <= 32'b0;
        pmc.dout_1 <= 32'b0;
        pmc.dout_2 <= 32'b0;
        pmc.dout_3 <= 32'b0;
        pmc.dout_4 <= 32'b0;
        pmc.dout_5 <= 32'b0;
        pmc.dout_6 <= 32'b0;
        pmc.dout_7 <= 32'b0;
        pmc.dout_8 <= 32'b0;
        pmc.dout_9 <= 32'b0;
        pmc.dout_10 <= 32'b0;
        pmc.dout_11 <= 32'b0;
        pmc.dout_12 <= 32'b0;
        pmc.dout_13 <= 32'b0;
        pmc.dout_14 <= 32'b0;
        pmc.dout_15 <= 32'b0;
        pmc.din_0 <= 32'b0;
        pmc.din_1 <= 32'b0;
        pmc.din_2 <= 32'b0;
        pmc.din_3 <= 32'b0;
        pmc.din_4 <= 32'b0;
        pmc.din_5 <= 32'b0;
        pmc.din_6 <= 32'b0;
        pmc.din_7 <= 32'b0;
        pmc.din_8 <= 32'b0;
        pmc.din_9 <= 32'b0;
        pmc.din_10 <= 32'b0;
        pmc.din_11 <= 32'b0;
        pmc.din_12 <= 32'b0;
        pmc.din_13 <= 32'b0;
        pmc.din_14 <= 32'b0;
        pmc.din_15 <= 32'b0;
    end
    else begin
        if (data_bus.we) begin
            case (requested_reg)
            PMC_CR:         pmc.cr <= data_bus.wdata;
            PMC_DOUT_0:     pmc.dout_0 <= data_bus.wdata;
            PMC_DOUT_1:     pmc.dout_1 <= data_bus.wdata;
            PMC_DOUT_2:     pmc.dout_2 <= data_bus.wdata;
            PMC_DOUT_3:     pmc.dout_3 <= data_bus.wdata;
            PMC_DOUT_4:     pmc.dout_4 <= data_bus.wdata;
            PMC_DOUT_5:     pmc.dout_5 <= data_bus.wdata;
            PMC_DOUT_6:     pmc.dout_6 <= data_bus.wdata;
            PMC_DOUT_7:     pmc.dout_7 <= data_bus.wdata;
            PMC_DOUT_8:     pmc.dout_8 <= data_bus.wdata;
            PMC_DOUT_9:     pmc.dout_9 <= data_bus.wdata;
            PMC_DOUT_10:    pmc.dout_10 <= data_bus.wdata;
            PMC_DOUT_11:    pmc.dout_11 <= data_bus.wdata;
            PMC_DOUT_12:    pmc.dout_12 <= data_bus.wdata;
            PMC_DOUT_13:    pmc.dout_13 <= data_bus.wdata;
            PMC_DOUT_14:    pmc.dout_14 <= data_bus.wdata;
            PMC_DOUT_15:    pmc.dout_15 <= data_bus.wdata;
            endcase
        end

        if (pmc.cr.pmcc_trg)
            pmc.cr.pmcc_trg <= 1'b0;

        pmc.sr.pmcc_wtt <= waitt;

        pmc.ctrl.res[25:10] <= 16'b0;
        pmc.ctrl.res[9:0] <= pm_ctrl.res;
        pmc.ctrl.write_cfg <= pm_ctrl.write_cfg;
        pmc.ctrl.strobe <= pm_ctrl.strobe;
        pmc.ctrl.gate <= pm_ctrl.gate;
        pmc.ctrl.shB <= pm_ctrl.shB;
        pmc.ctrl.shA <= pm_ctrl.shA;
        pmc.ctrl.clkSh <= pm_ctrl.clkSh;

        pmc.din_0 <= {din[1], din[0]};
        pmc.din_1 <= {din[3], din[2]};
        pmc.din_2 <= {din[5], din[4]};
        pmc.din_3 <= {din[7], din[6]};
        pmc.din_4 <= {din[9], din[8]};
        pmc.din_5 <= {din[11], din[10]};
        pmc.din_6 <= {din[13], din[12]};
        pmc.din_7 <= {din[15], din[14]};
        pmc.din_8 <= {din[17], din[16]};
        pmc.din_9 <= {din[19], din[18]};
        pmc.din_10 <= {din[21], din[20]};
        pmc.din_11 <= {din[23], din[22]};
        pmc.din_12 <= {din[25], din[24]};
        pmc.din_13 <= {din[27], din[26]};
        pmc.din_14 <= {din[29], din[28]};
        pmc.din_15 <= {din[31], din[30]};
    end
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_rdata <= 32'b0;
    end
    else begin
        case (requested_reg)
        PMC_CR:         reg_rdata <= pmc.cr;
        PMC_SR:         reg_rdata <= pmc.sr;
        PMC_CTRL:       reg_rdata <= pmc.ctrl;
        PMC_DOUT_0:     reg_rdata <= pmc.dout_0;
        PMC_DOUT_1:     reg_rdata <= pmc.dout_1;
        PMC_DOUT_2:     reg_rdata <= pmc.dout_2;
        PMC_DOUT_3:     reg_rdata <= pmc.dout_3;
        PMC_DOUT_4:     reg_rdata <= pmc.dout_4;
        PMC_DOUT_5:     reg_rdata <= pmc.dout_5;
        PMC_DOUT_6:     reg_rdata <= pmc.dout_6;
        PMC_DOUT_7:     reg_rdata <= pmc.dout_7;
        PMC_DOUT_8:     reg_rdata <= pmc.dout_8;
        PMC_DOUT_9:     reg_rdata <= pmc.dout_9;
        PMC_DOUT_10:    reg_rdata <= pmc.dout_10;
        PMC_DOUT_11:    reg_rdata <= pmc.dout_11;
        PMC_DOUT_12:    reg_rdata <= pmc.dout_12;
        PMC_DOUT_13:    reg_rdata <= pmc.dout_13;
        PMC_DOUT_14:    reg_rdata <= pmc.dout_14;
        PMC_DOUT_15:    reg_rdata <= pmc.dout_15;
        PMC_DIN_0:      reg_rdata <= pmc.din_0;
        PMC_DIN_1:      reg_rdata <= pmc.din_1;
        PMC_DIN_2:      reg_rdata <= pmc.din_2;
        PMC_DIN_3:      reg_rdata <= pmc.din_3;
        PMC_DIN_4:      reg_rdata <= pmc.din_4;
        PMC_DIN_5:      reg_rdata <= pmc.din_5;
        PMC_DIN_6:      reg_rdata <= pmc.din_6;
        PMC_DIN_7:      reg_rdata <= pmc.din_7;
        PMC_DIN_8:      reg_rdata <= pmc.din_8;
        PMC_DIN_9:      reg_rdata <= pmc.din_9;
        PMC_DIN_10:     reg_rdata <= pmc.din_10;
        PMC_DIN_11:     reg_rdata <= pmc.din_11;
        PMC_DIN_12:     reg_rdata <= pmc.din_12;
        PMC_DIN_13:     reg_rdata <= pmc.din_13;
        PMC_DIN_14:     reg_rdata <= pmc.din_14;
        PMC_DIN_15:     reg_rdata <= pmc.din_15;
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
