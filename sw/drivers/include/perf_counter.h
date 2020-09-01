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

/**
 * struct perf_counter - RISC-V performance counter
 * @value: 64 bit wide counter value
 * @lower_half: 32 bit lower half of counter value
 * @upper_half: 32 bit upper half of counter value
 */
struct perf_counter {
    union {
        uint64_t value;
        struct {
            uint32_t lower_half;
            uint32_t upper_half;
        };
    };
};

/**
 * perf_counter_get_mcycle - get value of the RISC-V clock cycles counter
 *
 * The RISC-V clock cycles counter is 64 bit wide and it is read in two separate CSR readouts.
 *
 * Return: Number of clock cycles executed by the CPU
 */
static inline struct perf_counter perf_counter_get_mcycle(void)
{
    struct perf_counter perf_counter;

    asm volatile ("csrr %[data], mcycle" : [data] "=r" (perf_counter.lower_half));
    asm volatile ("csrr %[data], mcycleh" : [data] "=r" (perf_counter.upper_half));

    return perf_counter;
}
