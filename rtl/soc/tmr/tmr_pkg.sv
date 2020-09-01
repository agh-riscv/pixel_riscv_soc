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

package tmr_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define TMR_CR_OFFSET   12'h000
`define TMR_SR_OFFSET   12'h004
`define TMR_CNTR_OFFSET 12'h008
`define TMR_CMPR_OFFSET 12'h00C


/**
 * User defined types
 */

typedef enum logic [2:0] {
    TMR_CR,         /* Control Register */
    TMR_SR,         /* Status Register */
    TMR_CNTR,       /* Counter Value Register */
    TMR_CMPR,       /* Compare Value Register */
    TMR_NONE
} tmr_reg_t;

typedef struct packed {
    logic [28:0] res;
    logic        sngl;
    logic        hlt;
    logic        trg;
} tmr_cr_t;

typedef struct packed {
    logic [29:0] res;
    logic        act;
    logic        mtch;
} tmr_sr_t;

typedef struct packed {
    logic [31:0] data;
} tmr_cntr_t;

typedef struct packed {
    logic [31:0] data;
} tmr_cmpr_t;

typedef struct packed {
    tmr_cr_t cr;
    tmr_sr_t sr;
    tmr_cntr_t cntr;
    tmr_cmpr_t cmpr;
} tmr_t;

endpackage
