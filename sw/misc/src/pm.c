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

#include "pm.h"
#include <rvintrin.h>
#include "pmc.h"
#include "pmcc.h"

#define is_bit_set(number, bit) \
({ \
    _rv32_sbext(number, bit); \
})

#define set_bit(number, bit) \
({ \
    number = _rv32_sbset(number, bit); \
})

#define clear_bit(number, bit) \
({ \
    number = _rv32_sbclr(number, bit); \
})

/**
 * struct pixel_offset_counts - the number of hits registered by pixel
 * @offset: the offset loaded to the pixel
 * @hits: the number of registered hits
 *
 * This structure is internally used in the offsets calibration procedure.
 *
 * The number of hits counted by the pixel is stored in the 16-bit register, so a 16-bit variable
 * must be used for its storing. Due to the fact, that compiler alligns struct instances to the word,
 * the workaround has been applied to reduce the data RAM usage - the pixel index is not represented
 * as a single 16-bit variable but as the array of the two 8-bits ones.
 *
 * The structure hits member should be accessed with the proper casting, such as the following one:
 * *((uint16_t *)pixels_offset_counts[i].hits) = 0;.
 */
struct pixel_offset_counts {
    uint8_t offset;
    uint8_t hits[2];
};

/**
 * pm_load_pixels_configuration - load the same pixel configuration to each pixel
 * @configuration: the pixel configuration to write
 */
void pm_load_pixels_configuration(const uint16_t configuration)
{
    pmcc_load_data_shifter();

    for (int i = 0; i < PM_ROWS; ++i) {
        for (int j = PM_BITS - 1; j >= 0; --j) {
            uint32_t din = 0;

            for (int k = 0; k < PM_COLS; ++k) {
                if (is_bit_set(configuration, j))
                    set_bit(din, k);
                else
                    clear_bit(din, k);
            }

            PMC->DIN[0] = din;

            while (!(PMC->SR.wtt)) { }
            PMC->CR.trg = 1;
        }
    }

    pmcc_load_config_latcher();
}

/**
 * pm_load_pixels_configurations - load different pixels configurations
 * @configurations: the buffer to read the pixels configurations from
 */
void pm_load_pixels_configurations(const uint16_t *configurations)
{
    pmcc_load_data_shifter();

    for (int i = 0; i < PM_ROWS; ++i) {
        for (int j = PM_BITS - 1; j >= 0; --j) {
            uint32_t din = 0;

            for (int k = 0; k < PM_COLS; ++k) {
                if (is_bit_set(configurations[i * PM_COLS + k], j))
                    set_bit(din, k);
                else
                    clear_bit(din, k);
            }

            PMC->DIN[0] = din;

            while (!(PMC->SR.wtt)) { }
            PMC->CR.trg = 1;
        }
    }

    pmcc_load_config_latcher();
}

/**
 * pm_read_counters - read the contents of the pixel matrix counters
 * @buf: the buffer to write the read values to
 */
void pm_read_counters(uint16_t *buf)
{
    pmcc_load_data_shifter();

    for (int i = 0; i < PM_ROWS; ++i) {
        for (int j = PM_BITS - 1; j >= 0; --j) {
            uint32_t dout = PMC->DOUT[0];

            for (int k = 0; k < PM_COLS; ++k) {
                if (is_bit_set(dout, k))
                    set_bit(buf[i * PM_COLS + k], j);
                else
                    clear_bit(buf[i * PM_COLS + k], j);
            }

            while (!(PMC->SR.wtt)) { }
            PMC->CR.trg = 1;
        }
    }
}

/**
 * pm_load_offset_read_counters - load specifed offset and read the counters
 * @buf: the buffer to update
 * @offset: the offset to load
 *
 * This function loads the specified offset to the each pixel configuration register and performs
 * a readout of the whole matrix. If for the specified offset pixels registered more hits, the buffer
 * is updated - the offset and the hits number are written to the buffer.
 */
static void pm_load_offset_read_counters(struct pixel_offset_counts *buf, uint16_t *counts_buffer, uint8_t offset)
{
    pm_load_pixels_configuration(offset);

    /* generate hits */
    pmcc_load_hits_generator();

    while (!(PMC->SR.wtt)) { }
    PMC->CR.trg = 1;

    pm_read_counters(counts_buffer);

    for (int i = 0; i < PM_PIXELS; ++i) {
        if (counts_buffer[i] > *((uint16_t *)buf[i].hits)) {
            buf[i].offset = offset;
            *((uint16_t *)buf[i].hits) = counts_buffer[i];
        }
    }
}

/**
 * pm_load_found_offsets - load offsets found in the calibration process
 * @buf: the buffer to read the pixels offsets from
 */
static void pm_load_found_offsets(struct pixel_offset_counts *buf)
{
    pmcc_load_data_shifter();

    for (int i = 0; i < PM_ROWS; ++i) {
        for (int j = PM_BITS - 1; j >= 0; --j) {
            uint32_t din = 0;

            for (int k = 0; k < PM_COLS; ++k) {
                if (is_bit_set(buf[i * PM_COLS + k].offset, j))
                    set_bit(din, k);
                else
                    clear_bit(din, k);
            }

            PMC->DIN[0] = din;

            while (!(PMC->SR.wtt)) { }
            PMC->CR.trg = 1;
        }
    }

    pmcc_load_config_latcher();
}

/**
 * pm_calibrate_offsets - calibrate offsets of the pixel matrix pixels
 */
void pm_calibrate_offsets(void)
{
    struct pixel_offset_counts pixels_offset_counts[PM_PIXELS];
    uint16_t counts_buffer[PM_PIXELS];

    for (int i = 0; i < PM_PIXELS; ++i) {
        pixels_offset_counts[i].offset = 0;
        *((uint16_t *)pixels_offset_counts[i].hits) = 0;
        counts_buffer[i] = 0;
    }

    for (int i = 0; i < 128; ++i)
        pm_load_offset_read_counters(pixels_offset_counts, counts_buffer, i);

    pm_load_found_offsets(pixels_offset_counts);
}
