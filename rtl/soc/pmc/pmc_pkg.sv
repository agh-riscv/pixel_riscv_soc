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
`define PMC_DIN_0_OFFSET     16'h0010
`define PMC_DIN_1_OFFSET     16'h0014
`define PMC_DOUT_0_OFFSET    16'h0018
`define PMC_DOUT_1_OFFSET    16'h001C
`define PMC_AC_OFFSET        16'h01??               /* 0x0100 - 0x01FF (256 B) */
`define PMC_DC_OFFSET        16'h02??               /* 0x0200 - 0x02FF (256 B) */
`define PMCC_CODE_RAM_OFFSET {4'h1, 4'b00??, 8'h?}  /* 0x1000 - 0x13FF (1 kB) */


/**
 * User defined types
 */

typedef enum logic [3:0] {
    PMC_CR,         /* Control Register */
    PMC_SR,         /* Status Register */
    PMC_CTRL,       /* Matrix ctrl[15:0] Readout Register */
    PMC_DIN_0,      /* Matrix din [31:0] Control Register */
    PMC_DIN_1,      /* Matrix din [63:32] Control Register */
    PMC_DOUT_0,     /* Matrix dout [31:0] Readout Register */
    PMC_DOUT_1,     /* Matrix dout [63:32] Readout Register */
    PMC_AC,         /* Matrix Analog Configuration Registers */
    PMC_DC,         /* Matrix Digital Configuration Registers */
    PMCC_CODE_RAM,  /* Matrix Coprocessor Code RAM */
    PMC_NONE
} pmc_reg_t;

typedef struct packed {
    logic [28:0] res;
    logic        trg;
    logic        rst;
    logic        en;
} pmc_cr_t;

typedef struct packed {
    logic [30:0] res;
    logic        wtt;
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
    logic [31:0] data;
} pmc_din_t;

typedef struct packed {
    logic [31:0] data;
} pmc_dout_t;

typedef struct packed {
    pmc_cr_t   cr;
    pmc_sr_t   sr;
    pmc_ctrl_t ctrl;
    pmc_din_t  din_0;
    pmc_din_t  din_1;
    pmc_dout_t dout_0;
    pmc_dout_t dout_1;
} pmc_t;

endpackage
