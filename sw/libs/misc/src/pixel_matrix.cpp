#include "pixel_matrix.h"
#include <cstring>
#include "pmc.h"

#define configs_update(row, col) \
    if (readout[row][col] > configs[row][col].counts) { \
        configs[row][col].offset = i; \
        configs[row][col].counts = readout[row][col]; \
    } \

Pixel_matrix pixel_matrix;

void Pixel_matrix::calibrate() const
{
    struct Config {
        uint16_t offset;
        uint16_t counts;
    };

    std::array<std::array<Config, Pixel_matrix::cols>, Pixel_matrix::rows> configs;
    std::memset((void *)configs[0].data(), 0, sizeof(configs));

    for (int i = 0; i < 128; ++i) {
        load_configs(i);
        const auto readout{read()};
        for (int row = 0; row < rows; row += 4) {
            for (int col = 0; col < cols; col += 4) {
                configs_update(row, col)
                configs_update(row, col + 1)
                configs_update(row, col + 2)
                configs_update(row, col + 3)
                configs_update(row + 1, col)
                configs_update(row + 1, col + 1)
                configs_update(row + 1, col + 2)
                configs_update(row + 1, col + 3)
                configs_update(row + 2, col)
                configs_update(row + 2, col + 1)
                configs_update(row + 2, col + 2)
                configs_update(row + 2, col + 3)
                configs_update(row + 3, col)
                configs_update(row + 3, col + 1)
                configs_update(row + 3, col + 2)
                configs_update(row + 3, col + 3)
            }
        }
    }

    std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows> found_configs;
    for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; ++col)
            found_configs[row][col] = configs[row][col].offset;
    }
    load_configs(found_configs);
}

std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows> Pixel_matrix::read() const
{
    pmc.get_pmcc().load_hits_generator();
    pmc.get_pmcc().trigger();
    return read_counters();
}

std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows> Pixel_matrix::read_counters() const
{
    pmc.get_pmcc().load_data_shifter();
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    std::array<std::array<uint16_t, cols>, rows> data;
    for (int row = rows - 1; row >= 0; --row) {
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
        pmc.get_din(data[row]);
    }
    return data;
}

void Pixel_matrix::load_configs(const uint16_t config) const
{
    write_counters(config);
    pmc.get_pmcc().load_config_latcher();
    pmc.get_pmcc().trigger();
}

void Pixel_matrix::load_configs(
    const std::array<std::array<uint16_t, Pixel_matrix::cols>, Pixel_matrix::rows> &configs) const
{
    write_counters(configs);
    pmc.get_pmcc().load_config_latcher();
    pmc.get_pmcc().trigger();
}

void Pixel_matrix::write_counters(const uint16_t value) const
{
    std::array<uint16_t, 32> wdata;
    std::fill(begin(wdata), end(wdata), value);
    pmc.set_dout(wdata);

    pmc.get_pmcc().load_data_shifter();
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    for (int row = rows - 1; row >= 0; --row) {
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
    }
}

void Pixel_matrix::write_counters(const std::array<std::array<uint16_t, cols>, rows> &data) const
{
    pmc.get_pmcc().load_data_shifter();
    pmc.get_pmcc().trigger();
    while (!pmc.get_pmcc().is_waiting_for_trigger()) { }

    for (int row = rows - 1; row >= 0; --row) {
        pmc.set_dout(data[row]);
        pmc.get_pmcc().trigger();
        while (!pmc.get_pmcc().is_waiting_for_trigger()) { }
    }
}
