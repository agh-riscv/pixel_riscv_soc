#pragma once

#include "command.h"

class Command_parser final {
public:
    Command_parser() = default;
    Command_parser(const Command_parser &) = delete;
    Command_parser(Command_parser &&) = delete;
    Command_parser &operator=(const Command_parser &) = delete;
    Command_parser &operator=(Command_parser &&) = delete;

    Command parse(const char *command) const;
};
