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

#include "delay.h"

/**
 * delay_loop_ibex - execute the loop wasting 10 CPU cycles
 * @loop_iterations: number of loop iterations
 */
static void delay_loop_ibex(uint32_t loop_iterations)
{
    int out;  /* only to notify compiler of modifications to |loops| */

    asm volatile (
        "1: nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   addi %1, %1, -1 \n"
        "   bnez %1, 1b     \n"
        : "=&r" (out)
        : "0" (loop_iterations)
    );
}

/**
 * mdelay - delay code execution for the specified time
 * @msec: the delay time in milliseconds
 */
void mdelay(uint32_t msec)
{
    uint32_t loop_iterations;

#ifdef SIM
    (void)msec;
    loop_iterations = 100;
#else
    loop_iterations = msec * 5000;
#endif

    delay_loop_ibex(loop_iterations);
}

/**
 * udelay - delay code execution for the specified time
 * @usec: the delay time in microseconds
 */
void udelay(uint32_t usec)
{
    uint32_t loop_iterations;

#ifdef SIM
    (void)usec;
    loop_iterations = 10;
#else
    loop_iterations = usec * 5;
#endif

    delay_loop_ibex(loop_iterations);
}
