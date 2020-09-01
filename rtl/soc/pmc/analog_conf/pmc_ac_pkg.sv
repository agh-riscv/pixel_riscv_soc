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

package pmc_ac_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define PMC_AC_REG_0_OFFSET 8'h00
`define PMC_AC_REG_1_OFFSET 8'h04
`define PMC_AC_REG_2_OFFSET 8'h08
`define PMC_AC_REG_3_OFFSET 8'h0C


/**
 * User defined types
 */

typedef enum logic [2:0] {
    PMC_AC_REG_0,
    PMC_AC_REG_1,
    PMC_AC_REG_2,
    PMC_AC_REG_3,
    PMC_AC_NONE
} pmc_ac_reg_t;

typedef struct packed {
    logic [31:0] res;
} pmc_ac_reg_0_t;

typedef struct packed {
    logic [31:0] res;
} pmc_ac_reg_1_t;

typedef struct packed {
    logic [31:0] res;
} pmc_ac_reg_2_t;

typedef struct packed {
    logic [31:0] res;
} pmc_ac_reg_3_t;

typedef struct packed {
    pmc_ac_reg_0_t reg_0;
    pmc_ac_reg_1_t reg_1;
    pmc_ac_reg_2_t reg_2;
    pmc_ac_reg_3_t reg_3;
} pmc_ac_t;

endpackage
