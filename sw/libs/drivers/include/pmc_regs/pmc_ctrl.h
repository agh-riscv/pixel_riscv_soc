#pragma once

#include <cstdint>

/**
 * union Pmc_ctrl - Pixel Matrix Controller control signals register
 * @clk_sh: shift clock
 * @sh_a: shift A
 * @sh_b: shift B
 * @gate: open gate
 * @strobe: strobe
 * @write_cfg: write configuration
 * @res: the reserved bits
 * @val: the register value
 */
union Pmc_ctrl {
    struct {
        uint32_t clk_sh : 1;
        uint32_t sh_a : 1;
        uint32_t sh_b : 1;
        uint32_t gate : 1;
        uint32_t strobe : 1;
        uint32_t write_cfg : 1;
        uint32_t res : 26;
    };
    uint32_t val;
};
