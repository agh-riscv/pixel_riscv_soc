#pragma once

#include <array>
#include <cstdint>

class Pixel_matrix final {
public:
    enum class Counter {a, b};

    static constexpr int rows{32};
    static constexpr int cols{32};

    Pixel_matrix() = default;
    Pixel_matrix(const Pixel_matrix &) = delete;
    Pixel_matrix(Pixel_matrix &&) = delete;
    Pixel_matrix &operator=(const Pixel_matrix &) = delete;
    Pixel_matrix &operator=(Pixel_matrix &&) = delete;

    void calibrate() const;
    std::array<std::array<uint16_t, cols>, rows> read(const Counter counter) const;
    std::array<std::array<uint16_t, cols>, rows> read_counters(const Counter counter) const;
    void load_configs(const Counter counter, const uint16_t config) const;
    void load_configs(const Counter counter,
        const std::array<std::array<uint16_t, cols>, rows> &configs) const;

private:
    static constexpr int bits{16};

    void write_counters(const Counter counter, const uint16_t value) const;
    void write_counters(const Counter counter,
        const std::array<std::array<uint16_t, cols>, rows> &data) const;
    void latch_configs() const;
};

extern Pixel_matrix pixel_matrix;
