#pragma once

#include <array>
#include "command_argument.h"

class Command final {
public:
    enum class Type {
        help,
        reset,
        ping,
        set_gpio_direction,
        get_gpio_direction,
        set_gpio,
        get_gpio,
        set_heartbeat,
        calculate,
        read_matrix,
        calibrate_matrix,
        unrecognized,
        empty
    };

    Command() = default;
    Command(const Command &) = delete;
    Command(Command &&) = default;
    Command &operator=(const Command &) = delete;
    Command &operator=(Command &&) = delete;

    Type type;
    int argc{0};
    std::array<Command_argument, 6> args;
};
