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

#include "interrupt.h"

/**
 * interrupt_enable - enable global interrupts
 */
void interrupt_enable(void)
{
    asm volatile ("csrrsi t0, mstatus, 1<<3");
}

/**
 * interrupt_gpio_irq_enable - enable GPIO interrupts
 */
void interrupt_gpio_irq_enable(void)
{
    asm volatile (
        "li    t0, 1<<16    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

/**
 * interrupt_tmr_irq_enable - enable timer interrupts
 */
void interrupt_tmr_irq_enable(void)
{
    asm volatile (
        "li    t0, 1<<17    \n"
        "csrrs t0, mie,  t0 \n"
    );
}

void gpio_irq_handler(void) { };
void tmr_irq_handler(void) { };
