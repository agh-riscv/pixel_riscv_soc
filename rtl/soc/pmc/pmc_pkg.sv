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

`define PMC_CR_OFFSET        16'h0000
`define PMC_SR_OFFSET        16'h0004
`define PMC_CTRL_OFFSET      16'h0008
`define PMC_DOUT_0_OFFSET    16'h0010
`define PMC_DOUT_1_OFFSET    16'h0014
`define PMC_DOUT_2_OFFSET    16'h0018
`define PMC_DOUT_3_OFFSET    16'h001C
`define PMC_DOUT_4_OFFSET    16'h0020
`define PMC_DOUT_5_OFFSET    16'h0024
`define PMC_DOUT_6_OFFSET    16'h0028
`define PMC_DOUT_7_OFFSET    16'h002C
`define PMC_DOUT_8_OFFSET    16'h0030
`define PMC_DOUT_9_OFFSET    16'h0034
`define PMC_DOUT_10_OFFSET   16'h0038
`define PMC_DOUT_11_OFFSET   16'h003C
`define PMC_DOUT_12_OFFSET   16'h0040
`define PMC_DOUT_13_OFFSET   16'h0044
`define PMC_DOUT_14_OFFSET   16'h0048
`define PMC_DOUT_15_OFFSET   16'h004C
`define PMC_DIN_0_OFFSET     16'h0050
`define PMC_DIN_1_OFFSET     16'h0054
`define PMC_DIN_2_OFFSET     16'h0058
`define PMC_DIN_3_OFFSET     16'h005C
`define PMC_DIN_4_OFFSET     16'h0060
`define PMC_DIN_5_OFFSET     16'h0064
`define PMC_DIN_6_OFFSET     16'h0068
`define PMC_DIN_7_OFFSET     16'h006C
`define PMC_DIN_8_OFFSET     16'h0070
`define PMC_DIN_9_OFFSET     16'h0074
`define PMC_DIN_10_OFFSET    16'h0078
`define PMC_DIN_11_OFFSET    16'h007C
`define PMC_DIN_12_OFFSET    16'h0080
`define PMC_DIN_13_OFFSET    16'h0084
`define PMC_DIN_14_OFFSET    16'h0088
`define PMC_DIN_15_OFFSET    16'h008C
`define PMC_AC_OFFSET        16'h01??               /* 0x0100 - 0x01FF (256 B) */
`define PMC_DC_OFFSET        16'h02??               /* 0x0200 - 0x02FF (256 B) */
`define PMCC_CODE_RAM_OFFSET {4'h1, 4'b00??, 8'h?}  /* 0x1000 - 0x13FF (1 kB) */


/**
 * User defined types
 */

typedef enum logic [5:0] {
    PMC_CR,         /* Control Register */
    PMC_SR,         /* Status Register */
    PMC_CTRL,       /* Matrix ctrl[15:0] Readout Register */
    PMC_DOUT_0,     /* dout Control Registers */
    PMC_DOUT_1,
    PMC_DOUT_2,
    PMC_DOUT_3,
    PMC_DOUT_4,
    PMC_DOUT_5,
    PMC_DOUT_6,
    PMC_DOUT_7,
    PMC_DOUT_8,
    PMC_DOUT_9,
    PMC_DOUT_10,
    PMC_DOUT_11,
    PMC_DOUT_12,
    PMC_DOUT_13,
    PMC_DOUT_14,
    PMC_DOUT_15,
    PMC_DIN_0,      /* din Readout Registers */
    PMC_DIN_1,
    PMC_DIN_2,
    PMC_DIN_3,
    PMC_DIN_4,
    PMC_DIN_5,
    PMC_DIN_6,
    PMC_DIN_7,
    PMC_DIN_8,
    PMC_DIN_9,
    PMC_DIN_10,
    PMC_DIN_11,
    PMC_DIN_12,
    PMC_DIN_13,
    PMC_DIN_14,
    PMC_DIN_15,
    PMC_AC,         /* Matrix Analog Configuration Registers */
    PMC_DC,         /* Matrix Digital Configuration Registers */
    PMCC_CODE_RAM,  /* Matrix Coprocessor Code RAM */
    PMC_NONE
} pmc_reg_t;

typedef struct packed {
    logic [29:0] res;
    logic        pmcc_trg;
    logic        pmcc_rst_n;
} pmc_cr_t;

typedef struct packed {
    logic [30:0] res;
    logic        pmcc_wtt;
} pmc_sr_t;

typedef struct packed {
    logic [25:0] res;
    logic        write_cfg;
    logic        strobe;
    logic        gate;
    logic        shB;
    logic        shA;
    logic        clkSh;
} pmc_ctrl_t;

typedef struct packed {
    pmc_cr_t     cr;
    pmc_sr_t     sr;
    pmc_ctrl_t   ctrl;
    logic [31:0] dout_0;
    logic [31:0] dout_1;
    logic [31:0] dout_2;
    logic [31:0] dout_3;
    logic [31:0] dout_4;
    logic [31:0] dout_5;
    logic [31:0] dout_6;
    logic [31:0] dout_7;
    logic [31:0] dout_8;
    logic [31:0] dout_9;
    logic [31:0] dout_10;
    logic [31:0] dout_11;
    logic [31:0] dout_12;
    logic [31:0] dout_13;
    logic [31:0] dout_14;
    logic [31:0] dout_15;
    logic [31:0] din_0;
    logic [31:0] din_1;
    logic [31:0] din_2;
    logic [31:0] din_3;
    logic [31:0] din_4;
    logic [31:0] din_5;
    logic [31:0] din_6;
    logic [31:0] din_7;
    logic [31:0] din_8;
    logic [31:0] din_9;
    logic [31:0] din_10;
    logic [31:0] din_11;
    logic [31:0] din_12;
    logic [31:0] din_13;
    logic [31:0] din_14;
    logic [31:0] din_15;
} pmc_t;

endpackage
