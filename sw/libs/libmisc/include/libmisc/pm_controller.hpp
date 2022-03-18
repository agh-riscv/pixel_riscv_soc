#pragma once

#include <libmisc/pm.hpp>

class Pm_controller {
public:
    Pm_controller() = default;
    Pm_controller(const Pm_controller &) = delete;
    Pm_controller(Pm_controller &&) = delete;
    Pm_controller &operator=(const Pm_controller &) = delete;
    Pm_controller &operator=(Pm_controller &&) = delete;

    void init(Pm::Controller_mode mode);
    void calibrate() const;
    Pm::Counters read(Pm::Counter counter) const;
    void write(Pm::Counter counter, uint16_t val) const;
    void write(Pm::Counter counter, const Pm::Counters &data) const;
    void open_gate() const;
    void latch_configs() const;

private:
    Pm::Controller_mode mode{Pm::Controller_mode::accelerated};

    Pm::Counters read_counters(Pm::Counter counter) const;
    void write_counters(Pm::Counter counter, uint16_t val) const;
    void write_counters(Pm::Counter counter, const Pm::Counters &data) const;
};
