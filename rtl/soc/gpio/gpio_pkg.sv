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

package gpio_pkg;


/**
 * Patterns used for address decoding (memory map)
 */

`define GPIO_CR_OFFSET   12'h000
`define GPIO_SR_OFFSET   12'h004
`define GPIO_ODR_OFFSET  12'h008
`define GPIO_IDR_OFFSET  12'h00C
`define GPIO_IER_OFFSET  12'h010
`define GPIO_ISR_OFFSET  12'h014
`define GPIO_RIER_OFFSET 12'h018
`define GPIO_FIER_OFFSET 12'h01C


/**
 * User defined types
 */

typedef enum logic [3:0] {
    GPIO_CR,        /* Control Register */
    GPIO_SR,        /* Status Register */
    GPIO_ODR,       /* Output Data Register */
    GPIO_IDR,       /* Input Data Register */
    GPIO_IER,       /* Interrupt Enable Register */
    GPIO_ISR,       /* Interrupt Status Register */
    GPIO_RIER,      /* Rising-edge Interrupt Enable Register */
    GPIO_FIER,      /* Falling-edge Interrupt Enable Register */
    GPIO_NONE
} gpio_reg_t;

typedef struct packed {
    logic [31:0] res;
} gpio_cr_t;

typedef struct packed {
    logic [31:0] res;
} gpio_sr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_odr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_idr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_ier_t;

typedef struct packed {
    logic [31:0] data;
} gpio_isr_t;

typedef struct packed {
    logic [31:0] data;
} gpio_rier_t;

typedef struct packed {
    logic [31:0] data;
} gpio_fier_t;

typedef struct packed {
    gpio_cr_t cr;
    gpio_sr_t sr;
    gpio_odr_t odr;
    gpio_idr_t idr;
    gpio_ier_t ier;
    gpio_isr_t isr;
    gpio_rier_t rier;
    gpio_fier_t fier;
} gpio_t;

endpackage
