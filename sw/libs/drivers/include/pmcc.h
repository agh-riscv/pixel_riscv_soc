#pragma once

#include "code_ram.h"
#include "pmc_cr.h"
#include "pmc_sr.h"

class Pmcc final {
public:
    Pmcc(const uint32_t pmc_cr_address, const uint32_t pmc_sr_address);
    Pmcc(const Pmcc &) = delete;
    Pmcc(Pmcc &&) = delete;
    Pmcc &operator=(const Pmcc &) = delete;
    Pmcc &operator=(Pmcc &&) = delete;

    void set_reset(const bool reset) const volatile;
    void trigger() const volatile;
    bool is_waiting_for_trigger() const volatile;

    void load_application(const uint8_t *code, int size) const volatile;
    void load_data_shifter() const volatile;
    void load_config_latcher() const volatile;
    void load_hits_generator() const volatile;

private:
    volatile Pmc_cr * const cr;
    volatile Pmc_sr * const sr;

    Code_ram code_ram;
};
