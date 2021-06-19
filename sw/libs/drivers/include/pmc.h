#pragma once

#include <array>
#include "pmc_ac.h"
#include "pmc_cr.h"
#include "pmc_ctrl.h"
#include "pmc_dc.h"
#include "pmc_sr.h"
#include "pmcc.h"

class Pmc final {
public:
    Pmc(const uint32_t base_address);
    Pmc(const Pmc &) = delete;
    Pmc(Pmc &&) = delete;
    Pmc &operator=(const Pmc &) = delete;
    Pmc &operator=(Pmc &&) = delete;

    Pmcc &get_pmcc() { return pmcc; };

    void set_dout(const std::array<uint16_t, 32> &data) const volatile;
    void get_din(std::array<uint16_t, 32> &dest) const volatile;
    void set_ac(const std::array<uint32_t,4> &ac) const volatile;
    void set_dc(const uint32_t dc) const volatile;

private:
    volatile Pmc_cr * const cr;
    volatile Pmc_sr * const sr;
    volatile Pmc_ctrl * const ctrl;
    volatile std::array<uint32_t, 16> * const dout;
    volatile std::array<uint32_t, 16> * const din;
    volatile Pmc_ac * const ac;
    volatile Pmc_dc * const dc;

    Pmcc pmcc;
};

extern Pmc pmc;
