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

`define PMC_CR_OFFSET           16'h0000                /* Control Reg offset */
`define PMC_SR_OFFSET           16'h0004                /* Status Reg offset */
`define PMC_CTRLS_OFFSET        16'h0008                /* Matrix ctrl Control Reg offset */
`define PMC_CTRLR_OFFSET        16'h000c                /* Matrix ctrl Readout Reg offset */
`define PMC_DOUT_0_OFFSET       16'h0010                /* dout Control Reg offset */
`define PMC_DOUT_1_OFFSET       16'h0014
`define PMC_DOUT_2_OFFSET       16'h0018
`define PMC_DOUT_3_OFFSET       16'h001c
`define PMC_DOUT_4_OFFSET       16'h0020
`define PMC_DOUT_5_OFFSET       16'h0024
`define PMC_DOUT_6_OFFSET       16'h0028
`define PMC_DOUT_7_OFFSET       16'h002c
`define PMC_DOUT_8_OFFSET       16'h0030
`define PMC_DOUT_9_OFFSET       16'h0034
`define PMC_DOUT_10_OFFSET      16'h0038
`define PMC_DOUT_11_OFFSET      16'h003c
`define PMC_DOUT_12_OFFSET      16'h0040
`define PMC_DOUT_13_OFFSET      16'h0044
`define PMC_DOUT_14_OFFSET      16'h0048
`define PMC_DOUT_15_OFFSET      16'h004c
`define PMC_DIN_0_OFFSET        16'h0050                /* din Readout Reg offset */
`define PMC_DIN_1_OFFSET        16'h0054
`define PMC_DIN_2_OFFSET        16'h0058
`define PMC_DIN_3_OFFSET        16'h005c
`define PMC_DIN_4_OFFSET        16'h0060
`define PMC_DIN_5_OFFSET        16'h0064
`define PMC_DIN_6_OFFSET        16'h0068
`define PMC_DIN_7_OFFSET        16'h006c
`define PMC_DIN_8_OFFSET        16'h0070
`define PMC_DIN_9_OFFSET        16'h0074
`define PMC_DIN_10_OFFSET       16'h0078
`define PMC_DIN_11_OFFSET       16'h007c
`define PMC_DIN_12_OFFSET       16'h0080
`define PMC_DIN_13_OFFSET       16'h0084
`define PMC_DIN_14_OFFSET       16'h0088
`define PMC_DIN_15_OFFSET       16'h008c

`define PMC_AC_REG_0_OFFSET     16'h0100
`define PMC_AC_REG_1_OFFSET     16'h0104
`define PMC_AC_REG_2_OFFSET     16'h0108
`define PMC_AC_REG_3_OFFSET     16'h010c

`define PMC_DC_REG_OFFSET       16'h0200

`define PMCC_CODE_RAM_OFFSET    {4'h1, 4'b00??, 8'h?}   /*  Coprocessor Code RAM (0x1000 - 0x13FF) (1 kB) */


/**
 * User defined types
 */

typedef struct packed {
    logic [26:0] res;
    logic        ext_strobe;
    logic        ext_gate;
    logic        direct_ctrl;
    logic        pmcc_trg;
    logic        pmcc_rst_n;
} pmc_cr_t;

typedef struct packed {
    logic [30:0] res;
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

typedef logic [15:0][31:0] pmc_data_t;
typedef logic [3:0][31:0]  pmc_ac_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  th;
} pmc_dc_t;

typedef struct packed {
    pmc_cr_t   cr;
    pmc_sr_t   sr;
    pmc_ctrl_t ctrls;
    pmc_ctrl_t ctrlr;
    pmc_data_t dout;
    pmc_data_t din;
    pmc_ac_t   ac;
    pmc_dc_t   dc;
} pmc_regs_t;

endpackage
