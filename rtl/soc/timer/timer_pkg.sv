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

package timer_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define TIMER_CR_OFFSET   12'h000
`define TIMER_SR_OFFSET   12'h004
`define TIMER_CNTR_OFFSET 12'h008
`define TIMER_CMPR_OFFSET 12'h00C


/**
 * User defined types
 */

typedef enum logic [2:0] {
    TIMER_CR,         /* Control Register */
    TIMER_SR,         /* Status Register */
    TIMER_CNTR,       /* Counter Value Register */
    TIMER_CMPR,       /* Compare Value Register */
    TIMER_NONE
} timer_reg_t;

typedef struct packed {
    logic [28:0] res;
    logic        sngl;
    logic        hlt;
    logic        trg;
} timer_cr_t;

typedef struct packed {
    logic [29:0] res;
    logic        act;
    logic        mtch;
} timer_sr_t;

typedef struct packed {
    logic [31:0] data;
} timer_cntr_t;

typedef struct packed {
    logic [31:0] data;
} timer_cmpr_t;

typedef struct packed {
    timer_cr_t   cr;
    timer_sr_t   sr;
    timer_cntr_t cntr;
    timer_cmpr_t cmpr;
} timer_t;

endpackage
