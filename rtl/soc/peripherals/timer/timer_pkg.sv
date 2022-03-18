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

const logic [11:0] TIMER_CR_OFFSET = 12'h000,       /* Control Reg offset */
                   TIMER_SR_OFFSET = 12'h004,       /* Status Reg offset */
                   TIMER_CNTR_OFFSET = 12'h008,     /* Counter Value Reg offset */
                   TIMER_CMPR_OFFSET = 12'h00c,     /* Compare Value Reg offset */
                   TIMER_IER_OFFSET = 12'h010,      /* Interrupt Enable Reg offset */
                   TIMER_ISR_OFFSET = 12'h014;      /* Interrupt Status Reg offset */


/**
 * User defined types
 */

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
    logic [30:0] res;
    logic        mtchie;
} timer_ier_t;

typedef struct packed {
    logic [30:0] res;
    logic        mtchf;
} timer_isr_t;

typedef struct packed {
    timer_cr_t   cr;
    timer_sr_t   sr;
    timer_cntr_t cntr;
    timer_cmpr_t cmpr;
    timer_ier_t  ier;
    timer_isr_t  isr;
} timer_regs_t;

endpackage
