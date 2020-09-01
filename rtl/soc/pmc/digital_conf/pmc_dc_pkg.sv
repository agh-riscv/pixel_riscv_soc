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

package pmc_dc_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define PMC_DC_REG_0_OFFSET 8'h00


/**
 * User defined types
 */

typedef enum logic {
    PMC_DC_REG_0,
    PMC_DC_NONE
} pmc_dc_reg_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  th;
} pmc_dc_reg_0_t;

typedef struct packed {
    pmc_dc_reg_0_t reg_0;
} pmc_dc_t;

endpackage
