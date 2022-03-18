#include <common.hpp>

uint32_t get_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask)
{
    return regs[offset>>2]>>shift & mask;
}

void set_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask, uint32_t val)
{
        uint32_t ret;

        ret = regs[offset>>2];
        ret &= ~(mask<<shift);
        ret |= (val & mask)<<shift;
        regs[offset>>2] = ret;
}

void toggle_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask)
{
        uint32_t ret;

        ret = regs[offset>>2];
        ret ^= mask<<shift;
        regs[offset>>2] = ret;
}
