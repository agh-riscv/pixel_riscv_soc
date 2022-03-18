#pragma once

#include <array>
#include <cstdint>

namespace Pm {
    enum class Controller_mode{accelerated, coprocessed, direct};
    enum class Counter {a, b};

    static constexpr int rows{8};
    static constexpr int cols{32};
    static constexpr int bits{16};

    using Counters = std::array<std::array<uint16_t, cols>, rows>;
};
