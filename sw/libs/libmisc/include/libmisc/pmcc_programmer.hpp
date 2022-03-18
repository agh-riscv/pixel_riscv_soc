#pragma once

#include <pm.hpp>

class Pmcc_programmer final {
public:
    Pmcc_programmer() = default;
    Pmcc_programmer(const Pmcc_programmer &) = delete;
    Pmcc_programmer(Pmcc_programmer &&) = delete;
    Pmcc_programmer &operator=(const Pmcc_programmer &) = delete;
    Pmcc_programmer &operator=(Pmcc_programmer &&) = delete;

    void load_data_shifter(Pm::Controller_mode mode, Pm::Counter counter) const;
    void load_config_latcher() const;
    void load_hits_generator() const;
};

extern Pmcc_programmer pmcc_programmer;
