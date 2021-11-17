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
    soc_pmc_bus.master           pmc_bus,
    soc_pm_ctrl.master           pm_ctrl,
    soc_pm_data.master           pm_data,
    soc_pm_analog_config.master  pm_analog_config,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Local variables and signals
 */

pmc_regs_t         pmc_regs, pmc_regs_nxt;
logic [31:0]       reg_rdata;
logic [15:0]       rdata_offset;
logic [31:0][15:0] dout, din;

ibex_data_bus      pmcc_code_ram_data_bus ();
ibex_data_bus      pmc_ac_data_bus ();
ibex_data_bus      pmc_dc_data_bus ();

soc_pmc_pm_ctrl    pmc_pm_ctrl ();
soc_pmc_pm_ctrl    direct_pmc_pm_ctrl ();
soc_pmc_pm_ctrl    pmcc_pmc_pm_ctrl ();

logic [31:0]       instr;
logic [9:0]        pc_if;
logic              pmcc_rst_n, trigger, waitt;


/**
 * Signals assignments
 */

assign data_bus.rdata_intg = 7'b0;

assign pmcc_code_ram_data_bus.we = data_bus.we;
assign pmcc_code_ram_data_bus.be = data_bus.be;
assign pmcc_code_ram_data_bus.addr = data_bus.addr;
assign pmcc_code_ram_data_bus.wdata = data_bus.wdata;
assign pmcc_code_ram_data_bus.wdata_intg = data_bus.wdata_intg;

assign pmc_ac_data_bus.we = data_bus.we;
assign pmc_ac_data_bus.be = data_bus.be;
assign pmc_ac_data_bus.addr = data_bus.addr;
assign pmc_ac_data_bus.wdata = data_bus.wdata;
assign pmc_ac_data_bus.wdata_intg = data_bus.wdata_intg;

assign pmc_dc_data_bus.we = data_bus.we;
assign pmc_dc_data_bus.be = data_bus.be;
assign pmc_dc_data_bus.addr = data_bus.addr;
assign pmc_dc_data_bus.wdata = data_bus.wdata;
assign pmc_dc_data_bus.wdata_intg = data_bus.wdata_intg;

assign pm_ctrl.store = {32{pmc_pm_ctrl.store}};
assign pm_ctrl.strobe = {32{pmc_pm_ctrl.strobe}};
assign pm_ctrl.gate = {32{pmc_pm_ctrl.gate}};
assign pm_ctrl.sh_b = {32{pmc_pm_ctrl.sh_b}};
assign pm_ctrl.sh_a = {32{pmc_pm_ctrl.sh_a}};
assign pm_ctrl.clk_sh = {32{pmc_pm_ctrl.clk_sh}};

/* 0x0008: matrix ctrl[15:0] control reg */
assign direct_pmc_pm_ctrl.res = pmc_regs.ctrls.res[9:0];
assign direct_pmc_pm_ctrl.store = pmc_regs.ctrls.store;
assign direct_pmc_pm_ctrl.strobe = pmc_regs.ctrls.strobe;
assign direct_pmc_pm_ctrl.gate = pmc_regs.ctrls.gate;
assign direct_pmc_pm_ctrl.sh_b = pmc_regs.ctrls.sh_b;
assign direct_pmc_pm_ctrl.sh_a = pmc_regs.ctrls.sh_a;
assign direct_pmc_pm_ctrl.clk_sh = pmc_regs.ctrls.clk_sh;

/* 0x0010 - 0x004f: dout control regs */
assign {dout[1], dout[0]} = pmc_regs.dout[0];
assign {dout[3], dout[2]} = pmc_regs.dout[1];
assign {dout[5], dout[4]} = pmc_regs.dout[2];
assign {dout[7], dout[6]} = pmc_regs.dout[3];
assign {dout[9], dout[8]} = pmc_regs.dout[4];
assign {dout[11], dout[10]} = pmc_regs.dout[5];
assign {dout[13], dout[12]} = pmc_regs.dout[6];
assign {dout[15], dout[14]} = pmc_regs.dout[7];
assign {dout[17], dout[16]} = pmc_regs.dout[8];
assign {dout[19], dout[18]} = pmc_regs.dout[9];
assign {dout[21], dout[20]} = pmc_regs.dout[10];
assign {dout[23], dout[22]} = pmc_regs.dout[11];
assign {dout[25], dout[24]} = pmc_regs.dout[12];
assign {dout[27], dout[26]} = pmc_regs.dout[13];
assign {dout[29], dout[28]} = pmc_regs.dout[14];
assign {dout[31], dout[30]} = pmc_regs.dout[15];

/* 0x0100 - 0x010f: analog config control regs */
assign pm_analog_config.res[127:96] = pmc_regs.ac[3];
assign pm_analog_config.res[95:64] = pmc_regs.ac[2];
assign pm_analog_config.res[63:32] = pmc_regs.ac[1];
assign pm_analog_config.res[31:0] = pmc_regs.ac[0];

/* 0x0200: digital config control reg */
assign pm_digital_config.res = pmc_regs.dc.res;
assign pm_digital_config.th = pmc_regs.dc.th;


/**
 * Submodules placement
 */

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
    .pmcc_rst_n(pmc_regs.cr.pmcc_rst_n),
    .trigger(pmc_regs.cr.pmcc_trg),
    .instr,
    .pmc_pm_ctrl(pmcc_pmc_pm_ctrl)
);

pmc_transmitter u_pmc_transmitter (
    .pm_din(pm_data.din),
    .clk,
    .rst_n,
    .sh(pmc_pm_ctrl.sh_a | pmc_pm_ctrl.sh_b),
    .pclk(pmc_pm_ctrl.clk_sh),
    .dout
);

pmc_receiver u_pmc_receiver (
    .din,
    .clk,
    .rst_n,
    .sh(pmc_pm_ctrl.sh_a | pmc_pm_ctrl.sh_b),
    .pclk(pmc_pm_ctrl.clk_sh),
    .pm_dout(pmc_pm_ctrl.sh_a ? pm_data.dout_a : pm_data.dout_b)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_reg_offset_valid(logic [15:0] offset);
    return
        (offset >= `PMC_CR_OFFSET && offset <= `PMC_DIN_15_OFFSET) ||
        (offset >= `PMC_AC_REG_0_OFFSET && offset <= `PMC_AC_REG_3_OFFSET) ||
        (offset == `PMC_DC_REG_OFFSET);
endfunction

function automatic logic is_pmcc_code_ram_accessed(logic [15:0] offset);
    return offset inside {`PMCC_CODE_RAM_OFFSET};
endfunction

function automatic logic is_offset_valid(logic [15:0] offset);
    return is_reg_offset_valid(offset) || is_pmcc_code_ram_accessed(offset);
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
        data_bus.err <= data_bus.gnt && !is_offset_valid(data_bus.addr[15:0]);
    end
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pmc_regs <= 0;
    end
    else begin
        pmc_regs <= pmc_regs_nxt;
    end
end

always_comb begin
    pmc_regs_nxt = pmc_regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[15:0])
        `PMC_CR_OFFSET:         pmc_regs_nxt.cr = data_bus.wdata;
        `PMC_SR_OFFSET:         pmc_regs_nxt.sr = data_bus.wdata;
        `PMC_CTRLS_OFFSET:      pmc_regs_nxt.ctrls = data_bus.wdata;
        `PMC_CTRLR_OFFSET:      pmc_regs_nxt.ctrlr = data_bus.wdata;
        `PMC_DOUT_0_OFFSET:     pmc_regs_nxt.dout[0] = data_bus.wdata;
        `PMC_DOUT_1_OFFSET:     pmc_regs_nxt.dout[1] = data_bus.wdata;
        `PMC_DOUT_2_OFFSET:     pmc_regs_nxt.dout[2] = data_bus.wdata;
        `PMC_DOUT_3_OFFSET:     pmc_regs_nxt.dout[3] = data_bus.wdata;
        `PMC_DOUT_4_OFFSET:     pmc_regs_nxt.dout[4] = data_bus.wdata;
        `PMC_DOUT_5_OFFSET:     pmc_regs_nxt.dout[5] = data_bus.wdata;
        `PMC_DOUT_6_OFFSET:     pmc_regs_nxt.dout[6] = data_bus.wdata;
        `PMC_DOUT_7_OFFSET:     pmc_regs_nxt.dout[7] = data_bus.wdata;
        `PMC_DOUT_8_OFFSET:     pmc_regs_nxt.dout[8] = data_bus.wdata;
        `PMC_DOUT_9_OFFSET:     pmc_regs_nxt.dout[9] = data_bus.wdata;
        `PMC_DOUT_10_OFFSET:    pmc_regs_nxt.dout[10] = data_bus.wdata;
        `PMC_DOUT_11_OFFSET:    pmc_regs_nxt.dout[11] = data_bus.wdata;
        `PMC_DOUT_12_OFFSET:    pmc_regs_nxt.dout[12] = data_bus.wdata;
        `PMC_DOUT_13_OFFSET:    pmc_regs_nxt.dout[13] = data_bus.wdata;
        `PMC_DOUT_14_OFFSET:    pmc_regs_nxt.dout[14] = data_bus.wdata;
        `PMC_DOUT_15_OFFSET:    pmc_regs_nxt.dout[15] = data_bus.wdata;
        `PMC_DIN_0_OFFSET:      pmc_regs_nxt.din[0] = data_bus.wdata;
        `PMC_DIN_1_OFFSET:      pmc_regs_nxt.din[1] = data_bus.wdata;
        `PMC_DIN_2_OFFSET:      pmc_regs_nxt.din[2] = data_bus.wdata;
        `PMC_DIN_3_OFFSET:      pmc_regs_nxt.din[3] = data_bus.wdata;
        `PMC_DIN_4_OFFSET:      pmc_regs_nxt.din[4] = data_bus.wdata;
        `PMC_DIN_5_OFFSET:      pmc_regs_nxt.din[5] = data_bus.wdata;
        `PMC_DIN_6_OFFSET:      pmc_regs_nxt.din[6] = data_bus.wdata;
        `PMC_DIN_7_OFFSET:      pmc_regs_nxt.din[7] = data_bus.wdata;
        `PMC_DIN_8_OFFSET:      pmc_regs_nxt.din[8] = data_bus.wdata;
        `PMC_DIN_9_OFFSET:      pmc_regs_nxt.din[9] = data_bus.wdata;
        `PMC_DIN_10_OFFSET:     pmc_regs_nxt.din[10] = data_bus.wdata;
        `PMC_DIN_11_OFFSET:     pmc_regs_nxt.din[11] = data_bus.wdata;
        `PMC_DIN_12_OFFSET:     pmc_regs_nxt.din[12] = data_bus.wdata;
        `PMC_DIN_13_OFFSET:     pmc_regs_nxt.din[13] = data_bus.wdata;
        `PMC_DIN_14_OFFSET:     pmc_regs_nxt.din[14] = data_bus.wdata;
        `PMC_DIN_15_OFFSET:     pmc_regs_nxt.din[15] = data_bus.wdata;
        `PMC_AC_REG_0_OFFSET:   pmc_regs_nxt.ac[0] = data_bus.wdata;
        `PMC_AC_REG_1_OFFSET:   pmc_regs_nxt.ac[1] = data_bus.wdata;
        `PMC_AC_REG_2_OFFSET:   pmc_regs_nxt.ac[2] = data_bus.wdata;
        `PMC_AC_REG_3_OFFSET:   pmc_regs_nxt.ac[3] = data_bus.wdata;
        `PMC_DC_REG_OFFSET:     pmc_regs_nxt.dc = data_bus.wdata;
        endcase
    end

    /* 0x0000: control reg */
    if (pmc_regs.cr.pmcc_trg)
        pmc_regs_nxt.cr.pmcc_trg = 1'b0;

    /* 0x0004: status reg */
    pmc_regs_nxt.sr.pmcc_wtt = waitt;

    /* 0x000c: matrix ctrl readout reg */
    pmc_regs_nxt.ctrlr.res[25:10] = 16'b0;
    pmc_regs_nxt.ctrlr.res[9:0] = pmc_pm_ctrl.res;
    pmc_regs_nxt.ctrlr.store = pmc_pm_ctrl.store;
    pmc_regs_nxt.ctrlr.strobe = pmc_pm_ctrl.strobe;
    pmc_regs_nxt.ctrlr.gate = pmc_pm_ctrl.gate;
    pmc_regs_nxt.ctrlr.sh_b = pmc_pm_ctrl.sh_b;
    pmc_regs_nxt.ctrlr.sh_a = pmc_pm_ctrl.sh_a;
    pmc_regs_nxt.ctrlr.clk_sh = pmc_pm_ctrl.clk_sh;

    pmc_regs_nxt.din[0] = {din[1], din[0]};
    pmc_regs_nxt.din[1] = {din[3], din[2]};
    pmc_regs_nxt.din[2] = {din[5], din[4]};
    pmc_regs_nxt.din[3] = {din[7], din[6]};
    pmc_regs_nxt.din[4] = {din[9], din[8]};
    pmc_regs_nxt.din[5] = {din[11], din[10]};
    pmc_regs_nxt.din[6] = {din[13], din[12]};
    pmc_regs_nxt.din[7] = {din[15], din[14]};
    pmc_regs_nxt.din[8] = {din[17], din[16]};
    pmc_regs_nxt.din[9] = {din[19], din[18]};
    pmc_regs_nxt.din[10] = {din[21], din[20]};
    pmc_regs_nxt.din[11] = {din[23], din[22]};
    pmc_regs_nxt.din[12] = {din[25], din[24]};
    pmc_regs_nxt.din[13] = {din[27], din[26]};
    pmc_regs_nxt.din[14] = {din[29], din[28]};
    pmc_regs_nxt.din[15] = {din[31], din[30]};
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_rdata <= 32'b0;
    end
    else begin
        if (data_bus.req) begin
            case (data_bus.addr[15:0])
            `PMC_CR_OFFSET:         reg_rdata <= pmc_regs.cr;
            `PMC_SR_OFFSET:         reg_rdata <= pmc_regs.sr;
            `PMC_CTRLS_OFFSET:      reg_rdata <= pmc_regs.ctrls;
            `PMC_CTRLR_OFFSET:      reg_rdata <= pmc_regs.ctrlr;
            `PMC_DOUT_0_OFFSET:     reg_rdata <= pmc_regs.dout[0];
            `PMC_DOUT_1_OFFSET:     reg_rdata <= pmc_regs.dout[1];
            `PMC_DOUT_2_OFFSET:     reg_rdata <= pmc_regs.dout[2];
            `PMC_DOUT_3_OFFSET:     reg_rdata <= pmc_regs.dout[3];
            `PMC_DOUT_4_OFFSET:     reg_rdata <= pmc_regs.dout[4];
            `PMC_DOUT_5_OFFSET:     reg_rdata <= pmc_regs.dout[5];
            `PMC_DOUT_6_OFFSET:     reg_rdata <= pmc_regs.dout[6];
            `PMC_DOUT_7_OFFSET:     reg_rdata <= pmc_regs.dout[7];
            `PMC_DOUT_8_OFFSET:     reg_rdata <= pmc_regs.dout[8];
            `PMC_DOUT_9_OFFSET:     reg_rdata <= pmc_regs.dout[9];
            `PMC_DOUT_10_OFFSET:    reg_rdata <= pmc_regs.dout[10];
            `PMC_DOUT_11_OFFSET:    reg_rdata <= pmc_regs.dout[11];
            `PMC_DOUT_12_OFFSET:    reg_rdata <= pmc_regs.dout[12];
            `PMC_DOUT_13_OFFSET:    reg_rdata <= pmc_regs.dout[13];
            `PMC_DOUT_14_OFFSET:    reg_rdata <= pmc_regs.dout[14];
            `PMC_DOUT_15_OFFSET:    reg_rdata <= pmc_regs.dout[15];
            `PMC_DIN_0_OFFSET:      reg_rdata <= pmc_regs.din[0];
            `PMC_DIN_1_OFFSET:      reg_rdata <= pmc_regs.din[1];
            `PMC_DIN_2_OFFSET:      reg_rdata <= pmc_regs.din[2];
            `PMC_DIN_3_OFFSET:      reg_rdata <= pmc_regs.din[3];
            `PMC_DIN_4_OFFSET:      reg_rdata <= pmc_regs.din[4];
            `PMC_DIN_5_OFFSET:      reg_rdata <= pmc_regs.din[5];
            `PMC_DIN_6_OFFSET:      reg_rdata <= pmc_regs.din[6];
            `PMC_DIN_7_OFFSET:      reg_rdata <= pmc_regs.din[7];
            `PMC_DIN_8_OFFSET:      reg_rdata <= pmc_regs.din[8];
            `PMC_DIN_9_OFFSET:      reg_rdata <= pmc_regs.din[9];
            `PMC_DIN_10_OFFSET:     reg_rdata <= pmc_regs.din[10];
            `PMC_DIN_11_OFFSET:     reg_rdata <= pmc_regs.din[11];
            `PMC_DIN_12_OFFSET:     reg_rdata <= pmc_regs.din[12];
            `PMC_DIN_13_OFFSET:     reg_rdata <= pmc_regs.din[13];
            `PMC_DIN_14_OFFSET:     reg_rdata <= pmc_regs.din[14];
            `PMC_DIN_15_OFFSET:     reg_rdata <= pmc_regs.din[15];
            `PMC_AC_REG_0_OFFSET:   reg_rdata <= pmc_regs.ac[0];
            `PMC_AC_REG_1_OFFSET:   reg_rdata <= pmc_regs.ac[1];
            `PMC_AC_REG_2_OFFSET:   reg_rdata <= pmc_regs.ac[2];
            `PMC_AC_REG_3_OFFSET:   reg_rdata <= pmc_regs.ac[3];
            `PMC_DC_REG_OFFSET:     reg_rdata <= pmc_regs.dc;
            endcase
        end
    end
end

/* Input signals demultiplexing and output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rdata_offset <= 16'b0;
    else
        rdata_offset <= data_bus.addr[15:0];
end

always_comb begin
    pmcc_code_ram_data_bus.req = is_pmcc_code_ram_accessed(data_bus.addr[15:0]);
end

always_comb begin
    data_bus.rdata = reg_rdata;

    if (is_pmcc_code_ram_accessed(rdata_offset))
        data_bus.rdata = pmcc_code_ram_data_bus.rdata;
end

/* matrix ctrl multiplexing */
always_comb begin
    if (pmc_regs.cr.direct_ctrl) begin
        pmc_pm_ctrl.res = direct_pmc_pm_ctrl.res;
        pmc_pm_ctrl.store = direct_pmc_pm_ctrl.store;
        pmc_pm_ctrl.strobe = direct_pmc_pm_ctrl.strobe;
        pmc_pm_ctrl.gate = direct_pmc_pm_ctrl.gate;
        pmc_pm_ctrl.sh_b = direct_pmc_pm_ctrl.sh_b;
        pmc_pm_ctrl.sh_a = direct_pmc_pm_ctrl.sh_a;
        pmc_pm_ctrl.clk_sh = direct_pmc_pm_ctrl.clk_sh;
    end
    else begin
        pmc_pm_ctrl.res = pmcc_pmc_pm_ctrl.res;
        pmc_pm_ctrl.store = pmcc_pmc_pm_ctrl.store;
        pmc_pm_ctrl.strobe = pmcc_pmc_pm_ctrl.strobe;
        pmc_pm_ctrl.gate = pmcc_pmc_pm_ctrl.gate;
        pmc_pm_ctrl.sh_b = pmcc_pmc_pm_ctrl.sh_b;
        pmc_pm_ctrl.sh_a = pmcc_pmc_pm_ctrl.sh_a;
        pmc_pm_ctrl.clk_sh = pmcc_pmc_pm_ctrl.clk_sh;
    end

    if (pmc_regs.cr.ext_strobe)
        pmc_pm_ctrl.strobe = pmc_bus.strobe;

    if (pmc_regs.cr.ext_gate)
        pmc_pm_ctrl.gate = pmc_bus.gate;
end

endmodule
