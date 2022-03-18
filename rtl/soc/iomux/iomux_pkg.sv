/**
 * Copyright (C) 2022  AGH University of Science and Technology
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

package iomux_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

const logic [11:0] IOMUX_MR0_OFFSET = 12'h000,  /* Mode Reg 0 offset */
                   IOMUX_MR1_OFFSET = 12'h004;  /* Mode Reg 1 offset */


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IO_IN,
    IO_OUT,
    IO_ALT
} mode_t;

typedef struct packed {
    mode_t pin15;
    mode_t pin14;
    mode_t pin13;
    mode_t pin12;
    mode_t pin11;
    mode_t pin10;
    mode_t pin9;
    mode_t pin8;
    mode_t pin7;
    mode_t pin6;
    mode_t pin5;
    mode_t pin4;
    mode_t pin3;
    mode_t pin2;
    mode_t pin1;
    mode_t pin0;
} iomux_mr0_t;

typedef struct packed {
    mode_t pin31;
    mode_t pin30;
    mode_t pin29;
    mode_t pin28;
    mode_t pin27;
    mode_t pin26;
    mode_t pin25;
    mode_t pin24;
    mode_t pin23;
    mode_t pin22;
    mode_t pin21;
    mode_t pin20;
    mode_t pin19;
    mode_t pin18;
    mode_t pin17;
    mode_t pin16;
} iomux_mr1_t;

typedef struct packed {
    iomux_mr0_t mr0;
    iomux_mr1_t mr1;
} iomux_regs_t;

endpackage
