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

#include "codeload.h"
#include "gpio.h"
#include "uart.h"

static inline void update_trap_vector_base_address(void)
{
    asm volatile (
        "li    t0, 0x10000    \n"
        "csrrw t0, mtvec,  t0 \n"
    );
}

static inline void jump_to_loaded_software(void)
{
    asm ("j 0x10080");
}

int main(void)
{
    uart_init();
    uart_write("bootloader started");

    if (GPIO->IDR & GPIO_CODELOAD_SKIPPING_PIN_MASK) {
        uart_write("codeload skipped");
    }
    else {
        if (GPIO->IDR & GPIO_CODELOAD_SOURCE_PIN_MASK) {
            uart_write("codeload source: uart");
            codeload_uart();
        }
        else {
            uart_write("codeload source: spi");
            codeload_spi();
        }
        uart_write("codeload finished");
    }

    update_trap_vector_base_address();

    uart_write("bootloader finished");
    gpio_set_mask_bits(GPIO_BOOTLOADER_FINISHED_PIN_MASK, GPIO_BOOTLOADER_FINISHED_PIN_MASK);

    jump_to_loaded_software();
}
