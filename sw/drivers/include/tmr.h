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

/* timer */
#define TMR_BASE_ADDRESS                0x01003000
#define TMR                             ((volatile struct tmr *)TMR_BASE_ADDRESS)

/* Bits definitions for timer control register */
#define TMR_CR_TRG_POS                  0
#define TMR_CR_TRG_MASK                 (1<<TMR_CR_TRG_POS)
#define TMR_CR_HLT_POS                  1
#define TMR_CR_HLT_MASK                 (1<<TMR_CR_HLT_POS)
#define TMR_CR_SNGL_POS                 2
#define TMR_CR_SNGL_MASK                (1<<TMR_CR_SNGL_POS)

/* Bits definitions for timer status register */
#define TMR_SR_MTCH_POS                 0
#define TMR_SR_MTCH_MASK                (1<<TMR_SR_MTCH_POS)
#define TMR_SR_ACT_POS                  1
#define TMR_SR_ACT_MASK                 (1<<TMR_SR_ACT_POS)

/**
 * union tmr_cr - timer control register
 * @trg: the trigger
 * @halt: the halt
 * @sngl: the single-shot mode
 * @val: the register value
 */
union tmr_cr {
    struct {
        uint32_t trg : 1;
        uint32_t hlt : 1;
        uint32_t sngl : 1;
        uint32_t res : 29;
    };
    uint32_t val;
};

/**
 * union tmr_sr - timer status register
 * @mtch: the compare value matched
 * @act: the timer is active
 * @val: the register value
 */
union tmr_sr {
    struct {
        uint32_t mtch : 1;
        uint32_t hlt : 1;
        uint32_t res : 30;
    };
    uint32_t val;
};

/**
 * struct tmr - timer
 * @CR: control register
 * @SR: status register
 * @CNTR: counter register
 * @CMPR: compare value register
 */
struct tmr {
    union tmr_cr CR;
    union tmr_sr SR;
    uint32_t CNTR;
    uint32_t CMPR;
};
