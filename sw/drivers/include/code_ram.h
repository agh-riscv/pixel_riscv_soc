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

/* code RAM */
#define CODE_RAM_BASE_ADDRESS           0x00010000
#define CODE_RAM                        ((volatile struct code_ram *)CODE_RAM_BASE_ADDRESS)
#define CODE_RAM_DEPTH                  4096
#define CODE_RAM_WORD_BYTES             4
#define CODE_RAM_SIZE                   (CODE_RAM_DEPTH * CODE_RAM_WORD_BYTES)

/**
 * struct code_ram - code RAM
 * @bytes: bytes of code memory
 * @words: words of code memory
 */
struct code_ram {
    union {
        uint8_t bytes[CODE_RAM_SIZE];
        uint32_t words[CODE_RAM_DEPTH];
    };
};
