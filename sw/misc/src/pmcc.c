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

#include "pmcc.h"
#include "pmc.h"

const uint8_t pmcc_data_shifter[] = {
    0x00,               /* 0x000: waitt */
    0xc0, 0x03, 0x00,   /* 0x001: store 0x0003: set shA and clkSh */
    0xc0, 0x02, 0x00,   /* 0x004: store 0x0002: set shA, clear clkSh */
    0x20, 0x00          /* 0x007: jump 0x000 */
};

const uint8_t pmcc_pixel_config_latcher[] = {
    0xc0, 0x20, 0x00,   /* 0x000: store 0x0023: set write_cfg */
    0xc0, 0x00, 0x00,   /* 0x003: store 0x0000: clear write_cfg */
    0x00                /* 0x006: waitt */
};

const uint8_t pmcc_hits_generator[] = {
    0x00,               /* 0x000: waitt */
    0xc0, 0x08, 0x00,   /* 0x001: store 0x0008: set gate */
    0xc0, 0x00, 0x00    /* 0x004: store 0x0000: clear gate */
};

void pmcc_load_application(const uint8_t *code, int size)
{
    for (int i = 0; i < size; ++i)
        PMCC_CODE_RAM->bytes[i] = code[i];
}

void pmcc_load_data_shifter(void)
{
    pmcc_load_application(pmcc_data_shifter, (int)(sizeof(pmcc_data_shifter)));

    PMC->CR.rst = 1;
    PMC->CR.en = 1;
}

void pmcc_load_config_latcher(void)
{
    pmcc_load_application(pmcc_pixel_config_latcher, (int)(sizeof(pmcc_pixel_config_latcher)));

    PMC->CR.rst = 1;
    PMC->CR.en = 1;
}

void pmcc_load_hits_generator(void)
{
    pmcc_load_application(pmcc_hits_generator, (int)(sizeof(pmcc_hits_generator)));

    PMC->CR.rst = 1;
    PMC->CR.en = 1;
}
