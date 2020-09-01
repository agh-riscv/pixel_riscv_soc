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

#pragma once

#include <stdint.h>

/* General-Purpose Input/Output */
#define GPIO_BASE_ADDRESS               0x01000000
#define GPIO                            ((volatile struct gpio *)GPIO_BASE_ADDRESS)

/* I/O pins assignments definitions */
#define GPIO_CODELOAD_SKIPPING_PIN_MASK     (1<<17)
#define GPIO_CODELOAD_SOURCE_PIN_MASK       (1<<16)
#define GPIO_BOOTLOADER_FINISHED_PIN_MASK   (1<<15)

/**
 * struct gpio - General-Purpose Input/Output
 * @CR: control register
 * @SR: status register
 * @ODR: output data register
 * @IDR: input data register
 * @IER: interrupt enable register
 * @ISR: interrupt status register
 * @RIER: rising-edge interrupt enable register
 * @FIER: falling-edge interrupt enable register
 */
struct gpio {
    uint32_t CR;
    uint32_t SR;
    uint32_t ODR;
    uint32_t IDR;
    uint32_t IER;
    uint32_t ISR;
    uint32_t RIER;
    uint32_t FIER;
};

void gpio_set_mask_bits(uint32_t mask, uint32_t bits);
