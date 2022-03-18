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

pmc_regs_t         regs, regs_nxt;
logic [31:0]       reg_rdata;
logic [15:0]       rdata_offset;
logic [31:0][15:0] pmc_transmitter_wdata, pmc_receiver_rdata;
logic [31:0]       pmc_transmitter_pm_data_din;
logic [31:0]       pm_direct_store, pm_direct_strobe, pm_direct_gate,
                   pm_direct_sh_b, pm_direct_sh_a, pm_direct_clk_sh;

ibex_data_bus      pmcc_code_ram_data_bus ();
ibex_data_bus      pmc_ac_data_bus ();
ibex_data_bus      pmc_dc_data_bus ();

soc_pm_ctrl        pmcc_pm_ctrl ();

logic [31:0]       instr;
logic [7:0]        pc_if;
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

/* 0x0000: pmc control reg */
assign pm_data.din = (regs.cr.direct_data) ? regs.dout[0] : pmc_transmitter_pm_data_din;

/* 0x0010 - 0x004f: dout control regs */
assign {pmc_transmitter_wdata[1], pmc_transmitter_wdata[0]} = regs.dout[0];
assign {pmc_transmitter_wdata[3], pmc_transmitter_wdata[2]} = regs.dout[1];
assign {pmc_transmitter_wdata[5], pmc_transmitter_wdata[4]} = regs.dout[2];
assign {pmc_transmitter_wdata[7], pmc_transmitter_wdata[6]} = regs.dout[3];
assign {pmc_transmitter_wdata[9], pmc_transmitter_wdata[8]} = regs.dout[4];
assign {pmc_transmitter_wdata[11], pmc_transmitter_wdata[10]} = regs.dout[5];
assign {pmc_transmitter_wdata[13], pmc_transmitter_wdata[12]} = regs.dout[6];
assign {pmc_transmitter_wdata[15], pmc_transmitter_wdata[14]} = regs.dout[7];
assign {pmc_transmitter_wdata[17], pmc_transmitter_wdata[16]} = regs.dout[8];
assign {pmc_transmitter_wdata[19], pmc_transmitter_wdata[18]} = regs.dout[9];
assign {pmc_transmitter_wdata[21], pmc_transmitter_wdata[20]} = regs.dout[10];
assign {pmc_transmitter_wdata[23], pmc_transmitter_wdata[22]} = regs.dout[11];
assign {pmc_transmitter_wdata[25], pmc_transmitter_wdata[24]} = regs.dout[12];
assign {pmc_transmitter_wdata[27], pmc_transmitter_wdata[26]} = regs.dout[13];
assign {pmc_transmitter_wdata[29], pmc_transmitter_wdata[28]} = regs.dout[14];
assign {pmc_transmitter_wdata[31], pmc_transmitter_wdata[30]} = regs.dout[15];

/* 0x0100: pmc ac 0 */
assign pm_analog_config.res[1:0] = regs.ac_0.res;
assign pm_analog_config.ref_csa_out = regs.ac_0.ref_csa_out;
assign pm_analog_config.ref_csa_mid = regs.ac_0.ref_csa_mid;
assign pm_analog_config.ref_csa_in = regs.ac_0.ref_csa_in;
assign pm_analog_config.idiscr = regs.ac_0.idiscr;
assign pm_analog_config.fed_csa = regs.ac_0.fed_csa;

/* 0x0104: pmc ac 1 */
assign pm_analog_config.res[3:2] = regs.ac_1.res;
assign pm_analog_config.shift_low = regs.ac_1.shift_low;
assign pm_analog_config.shift_high = regs.ac_1.shift_high;
assign pm_analog_config.ref_dac_krum = regs.ac_1.ref_dac_krum;
assign pm_analog_config.ref_dac_base = regs.ac_1.ref_dac_base;
assign pm_analog_config.ref_dac = regs.ac_1.ref_dac;

/* 0x0108: pmc ac 2 */
assign pm_analog_config.res[5:4] = regs.ac_2.res;
assign pm_analog_config.th_low = regs.ac_2.th_low;
assign pm_analog_config.th_high = regs.ac_2.th_high;
assign pm_analog_config.vblr = regs.ac_2.vblr;
assign pm_analog_config.ikrum = regs.ac_2.ikrum;

/* 0x010c: pmc ac 3 */
assign pm_analog_config.res[37:6] = regs.ac_3.res;

/* 0x0200: digital config control reg */
assign pm_digital_config.res = regs.dc.res;
assign pm_digital_config.num_bit_sel = regs.dc.num_bit_sel;
assign pm_digital_config.lc_mode = regs.dc.lc_mode;
assign pm_digital_config.limit_enable = regs.dc.limit_enable;
assign pm_digital_config.sample_mode = regs.dc.sample_mode;


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
    .pmcc_rst_n(regs.cr.pmcc_rst_n),
    .trigger(regs.cr.pmcc_trg),
    .instr,
    .pm_ctrl(pmcc_pm_ctrl)
);

pmc_transmitter u_pmc_transmitter (
    .pm_data_din(pmc_transmitter_pm_data_din),
    .clk,
    .rst_n,
    .sh(pm_ctrl.sh_a[0] | pm_ctrl.sh_b[0]),
    .pclk(pm_ctrl.clk_sh[0]),
    .wdata(pmc_transmitter_wdata)
);

pmc_receiver u_pmc_receiver (
    .rdata(pmc_receiver_rdata),
    .clk,
    .rst_n,
    .sh(pm_ctrl.sh_a[0] | pm_ctrl.sh_b[0]),
    .pclk(pm_ctrl.clk_sh[0]),
    .pm_data_dout(pm_ctrl.sh_a[0] ? pm_data.dout_a : pm_data.dout_b)
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_reg_offset_valid(logic [15:0] offset);
    return
        (offset >= PMC_CR_OFFSET && offset <= PMC_DIN_15_OFFSET) ||
        (offset >= PMC_AC_0_OFFSET && offset <= PMC_AC_3_OFFSET) ||
        (offset == PMC_DC_REG_OFFSET);
endfunction

function automatic logic is_pmcc_code_ram_accessed(logic [15:0] offset);
    return (offset >= PMC_CODE_RAM_BASE_OFFSET) && (offset <= PMC_CODE_RAM_END_OFFSET);
endfunction

function automatic logic is_offset_valid(logic [15:0] offset);
    return is_reg_offset_valid(offset) || is_pmcc_code_ram_accessed(offset);
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) data_bus.req |-> is_offset_valid(data_bus.addr[15:0])) else
    $warning("incorrect offset requested: 0x%x", data_bus.addr[15:0]);


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
        data_bus.err <= data_bus.gnt && !is_offset_valid(data_bus.addr[15:0]);
    end
end

/* Registers update */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        regs <= 0;
    else
        regs <= regs_nxt;
end

always_comb begin
    regs_nxt = regs;

    if (data_bus.req && data_bus.we) begin
        case (data_bus.addr[15:0])
        PMC_CR_OFFSET:          regs_nxt.cr = data_bus.wdata;
        PMC_SR_OFFSET:          regs_nxt.sr = data_bus.wdata;
        PMC_CTRLS_OFFSET:       regs_nxt.ctrls = data_bus.wdata;
        PMC_CTRLR_OFFSET:       regs_nxt.ctrlr = data_bus.wdata;
        PMC_DOUT_0_OFFSET:      regs_nxt.dout[0] = data_bus.wdata;
        PMC_DOUT_1_OFFSET:      regs_nxt.dout[1] = data_bus.wdata;
        PMC_DOUT_2_OFFSET:      regs_nxt.dout[2] = data_bus.wdata;
        PMC_DOUT_3_OFFSET:      regs_nxt.dout[3] = data_bus.wdata;
        PMC_DOUT_4_OFFSET:      regs_nxt.dout[4] = data_bus.wdata;
        PMC_DOUT_5_OFFSET:      regs_nxt.dout[5] = data_bus.wdata;
        PMC_DOUT_6_OFFSET:      regs_nxt.dout[6] = data_bus.wdata;
        PMC_DOUT_7_OFFSET:      regs_nxt.dout[7] = data_bus.wdata;
        PMC_DOUT_8_OFFSET:      regs_nxt.dout[8] = data_bus.wdata;
        PMC_DOUT_9_OFFSET:      regs_nxt.dout[9] = data_bus.wdata;
        PMC_DOUT_10_OFFSET:     regs_nxt.dout[10] = data_bus.wdata;
        PMC_DOUT_11_OFFSET:     regs_nxt.dout[11] = data_bus.wdata;
        PMC_DOUT_12_OFFSET:     regs_nxt.dout[12] = data_bus.wdata;
        PMC_DOUT_13_OFFSET:     regs_nxt.dout[13] = data_bus.wdata;
        PMC_DOUT_14_OFFSET:     regs_nxt.dout[14] = data_bus.wdata;
        PMC_DOUT_15_OFFSET:     regs_nxt.dout[15] = data_bus.wdata;
        PMC_DIN_0_OFFSET:       regs_nxt.din[0] = data_bus.wdata;
        PMC_DIN_1_OFFSET:       regs_nxt.din[1] = data_bus.wdata;
        PMC_DIN_2_OFFSET:       regs_nxt.din[2] = data_bus.wdata;
        PMC_DIN_3_OFFSET:       regs_nxt.din[3] = data_bus.wdata;
        PMC_DIN_4_OFFSET:       regs_nxt.din[4] = data_bus.wdata;
        PMC_DIN_5_OFFSET:       regs_nxt.din[5] = data_bus.wdata;
        PMC_DIN_6_OFFSET:       regs_nxt.din[6] = data_bus.wdata;
        PMC_DIN_7_OFFSET:       regs_nxt.din[7] = data_bus.wdata;
        PMC_DIN_8_OFFSET:       regs_nxt.din[8] = data_bus.wdata;
        PMC_DIN_9_OFFSET:       regs_nxt.din[9] = data_bus.wdata;
        PMC_DIN_10_OFFSET:      regs_nxt.din[10] = data_bus.wdata;
        PMC_DIN_11_OFFSET:      regs_nxt.din[11] = data_bus.wdata;
        PMC_DIN_12_OFFSET:      regs_nxt.din[12] = data_bus.wdata;
        PMC_DIN_13_OFFSET:      regs_nxt.din[13] = data_bus.wdata;
        PMC_DIN_14_OFFSET:      regs_nxt.din[14] = data_bus.wdata;
        PMC_DIN_15_OFFSET:      regs_nxt.din[15] = data_bus.wdata;
        PMC_AC_0_OFFSET:        regs_nxt.ac_0 = data_bus.wdata;
        PMC_AC_1_OFFSET:        regs_nxt.ac_1 = data_bus.wdata;
        PMC_AC_2_OFFSET:        regs_nxt.ac_2 = data_bus.wdata;
        PMC_AC_3_OFFSET:        regs_nxt.ac_3 = data_bus.wdata;
        PMC_DC_REG_OFFSET:      regs_nxt.dc = data_bus.wdata;
        endcase
    end

    /* 0x0000: control reg */
    if (regs.cr.pmcc_trg)
        regs_nxt.cr.pmcc_trg = 1'b0;

    if (regs.cr.direct_data) begin
        regs_nxt.din[0] = pm_ctrl.sh_a ? pm_data.dout_a : pm_data.dout_b;
        regs_nxt.din[1] = 32'b0;
        regs_nxt.din[2] = 32'b0;
        regs_nxt.din[3] = 32'b0;
        regs_nxt.din[4] = 32'b0;
        regs_nxt.din[5] = 32'b0;
        regs_nxt.din[6] = 32'b0;
        regs_nxt.din[7] = 32'b0;
        regs_nxt.din[8] = 32'b0;
        regs_nxt.din[9] = 32'b0;
        regs_nxt.din[10] = 32'b0;
        regs_nxt.din[11] = 32'b0;
        regs_nxt.din[12] = 32'b0;
        regs_nxt.din[13] = 32'b0;
        regs_nxt.din[14] = 32'b0;
        regs_nxt.din[15] = 32'b0;
    end else begin
        regs_nxt.din[0] = {pmc_receiver_rdata[1], pmc_receiver_rdata[0]};
        regs_nxt.din[1] = {pmc_receiver_rdata[3], pmc_receiver_rdata[2]};
        regs_nxt.din[2] = {pmc_receiver_rdata[5], pmc_receiver_rdata[4]};
        regs_nxt.din[3] = {pmc_receiver_rdata[7], pmc_receiver_rdata[6]};
        regs_nxt.din[4] = {pmc_receiver_rdata[9], pmc_receiver_rdata[8]};
        regs_nxt.din[5] = {pmc_receiver_rdata[11], pmc_receiver_rdata[10]};
        regs_nxt.din[6] = {pmc_receiver_rdata[13], pmc_receiver_rdata[12]};
        regs_nxt.din[7] = {pmc_receiver_rdata[15], pmc_receiver_rdata[14]};
        regs_nxt.din[8] = {pmc_receiver_rdata[17], pmc_receiver_rdata[16]};
        regs_nxt.din[9] = {pmc_receiver_rdata[19], pmc_receiver_rdata[18]};
        regs_nxt.din[10] = {pmc_receiver_rdata[21], pmc_receiver_rdata[20]};
        regs_nxt.din[11] = {pmc_receiver_rdata[23], pmc_receiver_rdata[22]};
        regs_nxt.din[12] = {pmc_receiver_rdata[25], pmc_receiver_rdata[24]};
        regs_nxt.din[13] = {pmc_receiver_rdata[27], pmc_receiver_rdata[26]};
        regs_nxt.din[14] = {pmc_receiver_rdata[29], pmc_receiver_rdata[28]};
        regs_nxt.din[15] = {pmc_receiver_rdata[31], pmc_receiver_rdata[30]};
    end

    /* 0x0004: status reg */
    regs_nxt.sr.pmcc_pc_if = pc_if;
    regs_nxt.sr.pmcc_wtt = waitt;

    /* 0x000c: matrix ctrl readout reg */
    regs_nxt.ctrlr.res = 26'b0;
    regs_nxt.ctrlr.store = pm_ctrl.store[0];
    regs_nxt.ctrlr.strobe = pm_ctrl.strobe[0];
    regs_nxt.ctrlr.gate = pm_ctrl.gate[0];
    regs_nxt.ctrlr.sh_b = pm_ctrl.sh_b[0];
    regs_nxt.ctrlr.sh_a = pm_ctrl.sh_a[0];
    regs_nxt.ctrlr.clk_sh = pm_ctrl.clk_sh[0];
end

/* Registers readout */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_rdata <= 32'b0;
    end else begin
        if (data_bus.req) begin
            case (data_bus.addr[15:0])
            PMC_CR_OFFSET:          reg_rdata <= regs.cr;
            PMC_SR_OFFSET:          reg_rdata <= regs.sr;
            PMC_CTRLS_OFFSET:       reg_rdata <= regs.ctrls;
            PMC_CTRLR_OFFSET:       reg_rdata <= regs.ctrlr;
            PMC_DOUT_0_OFFSET:      reg_rdata <= regs.dout[0];
            PMC_DOUT_1_OFFSET:      reg_rdata <= regs.dout[1];
            PMC_DOUT_2_OFFSET:      reg_rdata <= regs.dout[2];
            PMC_DOUT_3_OFFSET:      reg_rdata <= regs.dout[3];
            PMC_DOUT_4_OFFSET:      reg_rdata <= regs.dout[4];
            PMC_DOUT_5_OFFSET:      reg_rdata <= regs.dout[5];
            PMC_DOUT_6_OFFSET:      reg_rdata <= regs.dout[6];
            PMC_DOUT_7_OFFSET:      reg_rdata <= regs.dout[7];
            PMC_DOUT_8_OFFSET:      reg_rdata <= regs.dout[8];
            PMC_DOUT_9_OFFSET:      reg_rdata <= regs.dout[9];
            PMC_DOUT_10_OFFSET:     reg_rdata <= regs.dout[10];
            PMC_DOUT_11_OFFSET:     reg_rdata <= regs.dout[11];
            PMC_DOUT_12_OFFSET:     reg_rdata <= regs.dout[12];
            PMC_DOUT_13_OFFSET:     reg_rdata <= regs.dout[13];
            PMC_DOUT_14_OFFSET:     reg_rdata <= regs.dout[14];
            PMC_DOUT_15_OFFSET:     reg_rdata <= regs.dout[15];
            PMC_DIN_0_OFFSET:       reg_rdata <= regs.din[0];
            PMC_DIN_1_OFFSET:       reg_rdata <= regs.din[1];
            PMC_DIN_2_OFFSET:       reg_rdata <= regs.din[2];
            PMC_DIN_3_OFFSET:       reg_rdata <= regs.din[3];
            PMC_DIN_4_OFFSET:       reg_rdata <= regs.din[4];
            PMC_DIN_5_OFFSET:       reg_rdata <= regs.din[5];
            PMC_DIN_6_OFFSET:       reg_rdata <= regs.din[6];
            PMC_DIN_7_OFFSET:       reg_rdata <= regs.din[7];
            PMC_DIN_8_OFFSET:       reg_rdata <= regs.din[8];
            PMC_DIN_9_OFFSET:       reg_rdata <= regs.din[9];
            PMC_DIN_10_OFFSET:      reg_rdata <= regs.din[10];
            PMC_DIN_11_OFFSET:      reg_rdata <= regs.din[11];
            PMC_DIN_12_OFFSET:      reg_rdata <= regs.din[12];
            PMC_DIN_13_OFFSET:      reg_rdata <= regs.din[13];
            PMC_DIN_14_OFFSET:      reg_rdata <= regs.din[14];
            PMC_DIN_15_OFFSET:      reg_rdata <= regs.din[15];
            PMC_AC_0_OFFSET:        reg_rdata <= regs.ac_0;
            PMC_AC_1_OFFSET:        reg_rdata <= regs.ac_1;
            PMC_AC_2_OFFSET:        reg_rdata <= regs.ac_2;
            PMC_AC_3_OFFSET:        reg_rdata <= regs.ac_3;
            PMC_DC_REG_OFFSET:      reg_rdata <= regs.dc;
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

/* matrix direct ctrl flip flops multiplication */
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pm_direct_store <= 32'b0;
        pm_direct_strobe <= 32'b0;
        pm_direct_gate <= 32'b0;
        pm_direct_sh_b <= 32'b0;
        pm_direct_sh_a <= 32'b0;
        pm_direct_clk_sh <= 32'b0;
    end else begin
        pm_direct_store <= {32{regs_nxt.ctrls.store}};
        pm_direct_strobe <= {32{regs_nxt.ctrls.strobe}};
        pm_direct_gate <= {32{regs_nxt.ctrls.gate}};
        pm_direct_sh_b <= {32{regs_nxt.ctrls.sh_b}};
        pm_direct_sh_a <= {32{regs_nxt.ctrls.sh_a}};
        pm_direct_clk_sh <= {32{regs_nxt.ctrls.clk_sh}};
    end
end

/* matrix ctrl multiplexing */
always_comb begin
    if (regs.cr.direct_ctrl) begin
        pm_ctrl.store = pm_direct_store;
        pm_ctrl.strobe = pm_direct_strobe;
        pm_ctrl.gate = pm_direct_gate;
        pm_ctrl.sh_b = pm_direct_sh_b;
        pm_ctrl.sh_a = pm_direct_sh_a;
        pm_ctrl.clk_sh = pm_direct_clk_sh;
    end else begin
        pm_ctrl.store = pmcc_pm_ctrl.store;
        pm_ctrl.strobe = pmcc_pm_ctrl.strobe;
        pm_ctrl.gate = pmcc_pm_ctrl.gate;
        pm_ctrl.sh_b = pmcc_pm_ctrl.sh_b;
        pm_ctrl.sh_a = pmcc_pm_ctrl.sh_a;
        pm_ctrl.clk_sh = pmcc_pm_ctrl.clk_sh;
    end

    if (regs.cr.ext_strobe)
        pm_ctrl.strobe = {32{pmc_bus.strobe}};

    if (regs.cr.ext_gate)
        pm_ctrl.gate = {32{pmc_bus.gate}};
end

endmodule
