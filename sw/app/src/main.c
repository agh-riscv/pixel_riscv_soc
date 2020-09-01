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

#include "debug_lib.h"
#include "gpio.h"
#include "interrupt.h"
#include "tmr.h"
#include "uart.h"

 __attribute__ ((interrupt)) void gpio_irq_handler(void)
{
    debug_parameter_hex(GPIO->ISR);
    GPIO->ISR = 0;
}

 __attribute__ ((interrupt)) void tmr_irq_handler(void)
{
    static uint8_t led;

    gpio_set_mask_bits(1<<0, led);
    led ^= 1<<0;

    TMR->SR.mtch = 0;
}

int main(void)
{
    uart_init();
    uart_write("application started");

    GPIO->IER = 0xF;
    GPIO->RIER = 0xF;

    interrupt_gpio_irq_enable();
    interrupt_tmr_irq_enable();
    interrupt_enable();

    TMR->CMPR = 49999999;
    TMR->CR.trg = 1;

    while (1) {
        char buffer[100];

        uart_read(buffer, 100);
        uart_write(buffer);
    }
}
