#include "pmc.h"
#include <cstring>

static constexpr uint32_t pmc_base_address{0x0101'0000};
static constexpr uint8_t cr_offset{0x00};
static constexpr uint8_t sr_offset{0x04};
static constexpr uint8_t ctrl_offset{0x08};
static constexpr uint8_t dout_offset{0x10};
static constexpr uint8_t din_offset{0x50};

static constexpr uint32_t pmc_ac_base_address{0x0101'0100};
static constexpr uint32_t pmc_dc_base_address{0x0101'0200};

Pmc pmc{pmc_base_address};

Pmc::Pmc(const uint32_t base_address)
    :   cr{reinterpret_cast<volatile Pmc_cr *>(base_address + cr_offset)},
        sr{reinterpret_cast<volatile Pmc_sr *>(base_address + sr_offset)},
        ctrl{reinterpret_cast<volatile Pmc_ctrl *>(base_address + ctrl_offset)},
        dout{reinterpret_cast<volatile std::array<uint32_t, 16> *>(base_address + dout_offset)},
        din{reinterpret_cast<volatile std::array<uint32_t, 16> *>(base_address + din_offset)},
        ac{reinterpret_cast<volatile Pmc_ac *>(pmc_ac_base_address)},
        dc{reinterpret_cast<volatile Pmc_dc *>(pmc_dc_base_address)},
        pmcc{base_address + cr_offset, base_address + sr_offset}
{ }

void Pmc::set_dout(const std::array<uint16_t, 32> &data) const volatile
{
    std::memcpy((void *)dout, data.data(), 64);
}

void Pmc::get_din(std::array<uint16_t, 32> &dest) const volatile
{
    std::memcpy(dest.data(), (void *)din, 64);
}

void Pmc::set_ac(const std::array<uint32_t,4> &ac) const volatile
{
    this->ac->regs[0] = ac[0];
    this->ac->regs[1] = ac[1];
    this->ac->regs[2] = ac[2];
    this->ac->regs[3] = ac[3];
}

void Pmc::set_dc(const uint32_t dc) const volatile
{
    this->dc->reg0.val = dc;
}
