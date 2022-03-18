#pragma once

#include <libmisc/pm.hpp>
#include <libmisc/pm_controller.hpp>

class Pixel_matrix final {
public:
    Pixel_matrix() = default;
    Pixel_matrix(const Pixel_matrix &) = delete;
    Pixel_matrix(Pixel_matrix &&) = delete;
    Pixel_matrix &operator=(const Pixel_matrix &) = delete;
    Pixel_matrix &operator=(Pixel_matrix &&) = delete;

    void init(Pm::Controller_mode mode);
    void calibrate() const;

    Pm::Counters read(Pm::Counter counter, bool gate_opening) const;
    void write(Pm::Counter counter, const Pm::Counters &wdata) const;

    void load_configs(Pm::Counter counter, uint16_t config) const;
    void load_configs(Pm::Counter counter, const Pm::Counters &configs) const;

private:
    Pm_controller pm_controller;
};

extern Pixel_matrix pixel_matrix;
