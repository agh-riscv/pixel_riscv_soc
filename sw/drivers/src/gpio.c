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

#include "gpio.h"

/**
 * gpio_set_mask_bits - update content of GPIO Output Data Register
 * @mask: bits to update
 * @bits: value to write
 *
 * It performs bit-masking and updates values of specified bits of GPIO Output Data Register.
 */
void gpio_set_mask_bits(uint32_t mask, uint32_t bits)
{
    uint32_t reg = GPIO->ODR;

    reg &= ~mask;
    reg |= bits & mask;
    GPIO->ODR = reg;
}
