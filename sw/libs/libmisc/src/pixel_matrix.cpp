#include <pixel_matrix.hpp>
#include <cstring>
#include <libdrivers/pmc.hpp>

Pixel_matrix pixel_matrix;

void Pixel_matrix::init(Pm::Controller_mode mode)
{
    pm_controller.init(mode);
}

void Pixel_matrix::calibrate() const
{
    pm_controller.calibrate();
}

Pm::Counters Pixel_matrix::read(Pm::Counter counter, bool gate_opening) const
{
    if (gate_opening)
        pm_controller.open_gate();
    return pm_controller.read(counter);
}

void Pixel_matrix::write(Pm::Counter counter, const Pm::Counters &wdata) const
{
    pm_controller.write(counter, wdata);
}

void Pixel_matrix::load_configs(Pm::Counter counter, uint16_t config) const
{
    pm_controller.write(counter, config);
    pm_controller.latch_configs();
}

void Pixel_matrix::load_configs(Pm::Counter counter, const Pm::Counters &configs) const
{
    pm_controller.write(counter, configs);
    pm_controller.latch_configs();
}
