#pragma once

#include <command_parser.hpp>

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

    void help() const;
    void reset() const;
    void ping() const;
    int set_gpio_direction(const Command &command) const;
    int get_gpio_direction(const Command &command) const;
    int set_gpio(const Command &command) const;
    int get_gpio(const Command &command) const;
    int set_heartbeat(const Command &command) const;
    int calculate(const Command &command) const;
    int set_pm_controller_mode(const Command &command) const;
    void read_matrix() const;
    void calibrate_matrix() const;
    void test_matrix_write_read() const;
};
