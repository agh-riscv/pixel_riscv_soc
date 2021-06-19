#pragma once

#include "command_parser.h"

class Command_interpreter final {
public:
    Command_interpreter() = default;
    Command_interpreter(const Command_interpreter &) = delete;
    Command_interpreter(Command_interpreter &&) = delete;
    Command_interpreter &operator=(const Command_interpreter &) = delete;
    Command_interpreter &operator=(Command_interpreter &&) = delete;

    void run() const;

private:
    Command_parser command_parser;

    Command read_command() const;
    void help() const;
    void set_led() const;
    void read_matrix() const;
    void calibrate_matrix() const;
};
