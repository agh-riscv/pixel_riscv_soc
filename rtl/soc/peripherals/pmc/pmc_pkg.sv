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

package pmc_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

const logic [15:0] PMC_CR_OFFSET = 16'h0000,        /* Control Reg offset */
                   PMC_SR_OFFSET = 16'h0004,        /* Status Reg offset */
                   PMC_CTRLS_OFFSET = 16'h0008,     /* Matrix ctrl Control Reg offset */
                   PMC_CTRLR_OFFSET = 16'h000c,     /* Matrix ctrl Readout Reg offset */
                   PMC_DOUT_0_OFFSET = 16'h0010,    /* dout Control Reg offset */
                   PMC_DOUT_1_OFFSET = 16'h0014,
                   PMC_DOUT_2_OFFSET = 16'h0018,
                   PMC_DOUT_3_OFFSET = 16'h001c,
                   PMC_DOUT_4_OFFSET = 16'h0020,
                   PMC_DOUT_5_OFFSET = 16'h0024,
                   PMC_DOUT_6_OFFSET = 16'h0028,
                   PMC_DOUT_7_OFFSET = 16'h002c,
                   PMC_DOUT_8_OFFSET = 16'h0030,
                   PMC_DOUT_9_OFFSET = 16'h0034,
                   PMC_DOUT_10_OFFSET = 16'h0038,
                   PMC_DOUT_11_OFFSET = 16'h003c,
                   PMC_DOUT_12_OFFSET = 16'h0040,
                   PMC_DOUT_13_OFFSET = 16'h0044,
                   PMC_DOUT_14_OFFSET = 16'h0048,
                   PMC_DOUT_15_OFFSET = 16'h004c,
                   PMC_DIN_0_OFFSET = 16'h0050,     /* din Readout Reg offset */
                   PMC_DIN_1_OFFSET = 16'h0054,
                   PMC_DIN_2_OFFSET = 16'h0058,
                   PMC_DIN_3_OFFSET = 16'h005c,
                   PMC_DIN_4_OFFSET = 16'h0060,
                   PMC_DIN_5_OFFSET = 16'h0064,
                   PMC_DIN_6_OFFSET = 16'h0068,
                   PMC_DIN_7_OFFSET = 16'h006c,
                   PMC_DIN_8_OFFSET = 16'h0070,
                   PMC_DIN_9_OFFSET = 16'h0074,
                   PMC_DIN_10_OFFSET = 16'h0078,
                   PMC_DIN_11_OFFSET = 16'h007c,
                   PMC_DIN_12_OFFSET = 16'h0080,
                   PMC_DIN_13_OFFSET = 16'h0084,
                   PMC_DIN_14_OFFSET = 16'h0088,
                   PMC_DIN_15_OFFSET = 16'h008c,

                   PMC_AC_0_OFFSET = 16'h0100,
                   PMC_AC_1_OFFSET = 16'h0104,
                   PMC_AC_2_OFFSET = 16'h0108,
                   PMC_AC_3_OFFSET = 16'h010c,

                   PMC_DC_REG_OFFSET = 16'h0200,

                   PMC_CODE_RAM_BASE_OFFSET = 16'h1000,
                   PMC_CODE_RAM_END_OFFSET = 16'h13ff;


/**
 * User defined types
 */

typedef struct packed {
    logic [25:0] res;
    logic        ext_strobe;
    logic        ext_gate;
    logic        direct_data;
    logic        direct_ctrl;
    logic        pmcc_trg;
    logic        pmcc_rst_n;
} pmc_cr_t;

typedef struct packed {
    logic [22:0] res;
    logic [7:0]  pmcc_pc_if;
    logic        pmcc_wtt;
} pmc_sr_t;

typedef struct packed {
    logic [25:0] res;
    logic        store;
    logic        strobe;
    logic        gate;
    logic        sh_b;
    logic        sh_a;
    logic        clk_sh;
} pmc_ctrl_t;

typedef struct packed {
    logic [1:0] res;
    logic [5:0] ref_csa_out;
    logic [5:0] ref_csa_mid;
    logic [5:0] ref_csa_in;
    logic [5:0] idiscr;
    logic [5:0] fed_csa;
} pmc_ac_0_t;

typedef struct packed {
    logic [1:0] res;
    logic [5:0] shift_low;
    logic [5:0] shift_high;
    logic [5:0] ref_dac_krum;
    logic [5:0] ref_dac_base;
    logic [5:0] ref_dac;
} pmc_ac_1_t;

typedef struct packed {
    logic [1:0] res;
    logic [7:0] th_low;
    logic [7:0] th_high;
    logic [6:0] vblr;
    logic [6:0] ikrum;
} pmc_ac_2_t;

typedef struct packed {
    logic [31:0] res;
} pmc_ac_3_t;

typedef logic [15:0][31:0] pmc_data_t;

typedef struct packed {
    logic [25:0] res;
    logic [2:0]  num_bit_sel;
    logic        lc_mode;
    logic        limit_enable;
    logic        sample_mode;
} pmc_dc_t;

typedef struct packed {
    pmc_cr_t   cr;
    pmc_sr_t   sr;
    pmc_ctrl_t ctrls;
    pmc_ctrl_t ctrlr;
    pmc_data_t dout;
    pmc_data_t din;
    pmc_ac_0_t ac_0;
    pmc_ac_1_t ac_1;
    pmc_ac_2_t ac_2;
    pmc_ac_3_t ac_3;
    pmc_dc_t   dc;
} pmc_regs_t;

endpackage
