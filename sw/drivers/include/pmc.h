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

/* Pixel Matrix Controller */
#define PMC_BASE_ADDRESS                0x01010000
#define PMC                             ((volatile struct pmc *)PMC_BASE_ADDRESS)

/* Bits definitions for PMC control register */
#define PMC_CR_EN_POS                   0
#define PMC_CR_EN_MASK                  (1<<PMC_CR_EN_POS)
#define PMC_CR_RST_POS                  1
#define PMC_CR_RST_MASK                 (1<<PMC_CR_RST_POS)
#define PMC_CR_TRG_POS                  2
#define PMC_CR_TRG_MASK                 (1<<PMC_CR_TRG_POS)

/* Bits definitions for PMC status register */
#define PMC_SR_WTT_POS                  0
#define PMC_SR_WTT_MASK                 (1<<PMC_SR_WTT_POS)

/* Bits definitions for PMC matrix control signals register */
#define PMC_CTRL_DATA_POS               0
#define PMC_CTRL_DATA_MASK              (0xFFFF<<PMC_CTRL_DATA_POS)

/* Pixel Matrix Controller Coprocessor code RAM */
#define PMCC_CODE_RAM_BASE_ADDRESS      0x01011000
#define PMCC_CODE_RAM                   ((volatile struct pmcc_code_ram *)PMCC_CODE_RAM_BASE_ADDRESS)
#define PMCC_CODE_RAM_DEPTH             256
#define PMCC_CODE_RAM_WORD_BYTES        4
#define PMCC_CODE_RAM_SIZE              (PMCC_CODE_RAM_DEPTH * PMCC_CODE_RAM_WORD_BYTES)

/* Pixel Matrix Controller analog configuration */
#define PMC_AC_BASE_ADDRESS             0x01010100
#define PMC_AC                          ((volatile struct pmc_ac *)PMC_AC_BASE_ADDRESS)

/* Pixel Matrix Controller digital configuration */
#define PMC_DC_BASE_ADDRESS             0x01010200
#define PMC_DC                          ((volatile struct pmc_dc *)PMC_DC_BASE_ADDRESS)

/* Bits definitions for PMC digital configuration register 0 */
#define PMC_DC_REG_0_TH_POS             0
#define PMC_DC_REG_0_TH_MASK            (0xFF<<PMC_DC_REG_0_TH_POS)

/**
 * union pmc_cr - Pixel Matrix Controller control register
 * @en: the PMCC enable
 * @rst: the PMCC reset
 * @trg: the PMCC trigger
 * @res: the reserved bits
 * @val: the register value
 */
union pmc_cr {
    struct {
        uint32_t en : 1;
        uint32_t rst : 1;
        uint32_t trg : 1;
        uint32_t res : 29;
    };
    uint32_t val;
};

/**
 * union pmc_sr - Pixel Matrix Controller status register
 * @wtt: waiting for a trigger
 * @res: the reserved bits
 * @val: the register value
 */
union pmc_sr {
    struct {
        uint32_t wtt : 1;
        uint32_t res : 31;
    };
    uint32_t val;
};

/**
 * union pmc_ctrl - Pixel Matrix Controller control signals register
 * @data: the control signals set by PMCC
 * @res: the reserved bits
 * @val: the register value
 */
union pmc_ctrl {
    struct {
        uint32_t data : 16;
        uint32_t res : 16;
    };
    uint32_t val;
};

/**
 * struct pmc - Pixel Matrix Controller
 * @CR: control register
 * @SR: status register
 * @CTRL: matrix ctrl[15:0] readout register
 * @res: the reserved word
 * @DIN: matrix din[63:0] control registers
 * @DOUT: matrix dout[63:0] readout registers
 */
struct pmc {
    union pmc_cr CR;
    union pmc_sr SR;
    union pmc_ctrl CTRL;
    uint32_t res;
    uint32_t DIN[2];
    uint32_t DOUT[2];
};

/**
 * struct pmcc_code_ram - Pixel Matrix Controller Coprocessor code RAM
 * @bytes: bytes of code memory
 * @words: words of code memory
 */
struct pmcc_code_ram {
    union {
        uint8_t bytes[PMCC_CODE_RAM_SIZE];
        uint32_t words[PMCC_CODE_RAM_DEPTH];
    };
};

/**
 * struct pmc_ac - Pixel Matrix Controller analog configuration
 * @regs: analog configuration registers
 */
struct pmc_ac {
    uint32_t regs[4];
};

/**
 * union pmc_dc_reg_0 - Pixel Matrix Controller digital configuration register 0
 * @th: the threshold
 * @res: the reserved bits
 * @val: the register value
 */
union pmc_dc_reg_0 {
    struct {
        uint32_t th : 8;
        uint32_t res : 24;
    };
    uint32_t val;
};

/**
 * struct pmc_dc - Pixel Matrix Controller digital configuration
 * @REG_0: digital configuration register 0
 */
struct pmc_dc {
    union pmc_dc_reg_0 REG_0;
};
