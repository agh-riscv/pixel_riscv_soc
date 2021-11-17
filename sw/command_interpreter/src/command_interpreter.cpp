#include "command_interpreter.h"
#include "core.h"
#include "debug.h"
#include "gpio.h"
#include "pixel_matrix.h"
#include "pmc.h"
#include "string_ops.h"
#include "timer.h"
#include "ui.h"

using cmd_type = Command::Type;
using arg_type = Command_argument::Type;

void Command_interpreter::run() const
{
    Ui::Buffer buf;

    while (true) {
        ui << "> ";
        ui >> buf;

        const auto command{command_parser.parse(buf.data())};
        int err{0};

        switch (command.type) {
        case cmd_type::help:
            help();
            break;
        case cmd_type::reset:
            reset();
            break;
        case cmd_type::ping:
            ping();
            break;
        case Command::Type::set_gpio_direction:
            err = set_gpio_direction(command);
            break;
        case Command::Type::get_gpio_direction:
            err = get_gpio_direction(command);
            break;
        case cmd_type::set_gpio:
            err = set_gpio(command);
            break;
        case cmd_type::get_gpio:
            err = get_gpio(command);
            break;
        case cmd_type::set_heartbeat:
            err = set_heartbeat(command);
            break;
        case cmd_type::calculate:
            calculate(command);
            break;
        case cmd_type::read_matrix:
            read_matrix();
            break;
        case cmd_type::calibrate_matrix:
            calibrate_matrix();
            break;
        case cmd_type::unrecognized:
            ui << "error: unrecognized command: \"" << buf
                << "\". execute \"help\" to get supported commands list\n";
            break;
        case cmd_type::empty:
            break;
        }

        if (err)
            ui << "error: command failed\n";
    }
}

void Command_interpreter::help() const
{
    static constexpr auto message{
        "help                              - print this message\n"
        "reset                             - reset soc\n"
        "ping                              - send \"ping\" to the host\n"
        "set_gpio_direction <pin> [in|out] - set gpio pin direction\n"
        "get_gpio_direction <pin>          - get gpio pin direction\n"
        "set_gpio <pin> <value>            - set gpio pin\n"
        "get_gpio <pin>                    - get gpio pin\n"
        "set_heartbeat <period [ms]>       - set heartbeat\n"
        "calculate <arg1> [+|-|*|/] <arg2> - perform calculation\n"
        "read_matrix                       - read matrix\n"
        "calibrate_matrix                  - calibrate pixels offsets\n"
    };
    ui << message;
}

void Command_interpreter::reset() const
{
#ifdef BASYS
    gpio.set_pin(31, true);
#else
    ui << "error: operation not supported\n";
#endif
}

void Command_interpreter::ping() const
{
    ui << "ping\n";
}

int Command_interpreter::set_gpio_direction(const Command &command) const
{
    Gpio::Direction direction;

    if (command.argc < 2) {
        ui << "error: missing argument(s)\n";
        return 1;
    } else if (command.args[0].type != arg_type::number || command.args[1].type != arg_type::string) {
        ui << "error: invalid argument(s) type(s)\n";
        return 1;
    }

    if (!strcmp(command.args[1].buf, "in")) {
        direction = Gpio::Direction::in;
    } else if (!strcmp(command.args[1].buf, "out")) {
        direction = Gpio::Direction::out;
    } else {
        ui << "error: invalid direction\n";
        return 1;
    }

    gpio.set_pin_direction(command.args[0].val, direction);
    return 0;
}

int Command_interpreter::get_gpio_direction(const Command &command) const
{
    if (command.argc < 1) {
        ui << "error: missing argument\n";
        return 1;
    } else if (command.args[0].type != arg_type::number) {
        ui << "error: invalid argument type\n";
        return 1;
    }

    const auto direction{gpio.get_pin_direction(command.args[0].val)};
    ui << ((direction == Gpio::Direction::out) ? "out" : "in") << "\n";
    return 0;
}

int Command_interpreter::set_gpio(const Command &command) const
{
    if (command.argc < 2) {
        ui << "error: missing argument(s)\n";
        return 1;
    } else if (command.args[0].type != arg_type::number || command.args[1].type != arg_type::number) {
        ui << "error: invalid argument(s) type(s)\n";
        return 1;
    }

    gpio.set_pin(command.args[0].val, command.args[1].val);
    return 0;
}

int Command_interpreter::get_gpio(const Command &command) const
{
    if (command.argc < 1) {
        ui << "error: missing argument\n";
        return 1;
    } else if (command.args[0].type != arg_type::number) {
        ui << "error: invalid argument type\n";
        return 1;
    }

    ui << gpio.get_pin(command.args[0].val) << "\n";
    return 0;
}

int Command_interpreter::set_heartbeat(const Command &command) const
{
    if (command.argc < 1) {
        ui << "error: missing argument\n";
        return 1;
    } else if (command.args[0].type != arg_type::number) {
        ui << "error: invalid argument type\n";
        return 1;
    }

    if (command.args[0].val > 0) {
        core.enable_timer_interrupts([](){
            ui << "heartbeat\n";
            timer.clear_matched();
        });
        timer.set_cmpr(command.args[0].val * 50'000 - 1);   /* f = 50 MHz */
        timer.enable();
        core.enable_interrupts();
    } else {
        timer.disable();
        core.disable_timer_interrupts();
    }
    return 0;
}

int Command_interpreter::calculate(const Command &command) const
{
    if (command.argc < 3) {
        ui << "error: missing argument(s)\n";
        return 1;
    } else if (command.args[0].type != arg_type::number ||
        command.args[1].type != arg_type::string ||
        command.args[2].type != arg_type::number) {
        ui << "error: invalid argument(s) type(s)\n";
        return 1;
    }

    int err{0};

    switch (command.args[1].buf[0]) {
    case '+':
        ui << command.args[0].val + command.args[2].val << "\n";
        break;
    case '-':
        ui << command.args[0].val - command.args[2].val << "\n";
        break;
    case '*':
        ui << command.args[0].val * command.args[2].val << "\n";
        break;
    case '/':
        if (command.args[2].val) {
            ui << command.args[0].val / command.args[2].val << "\n";
        } else {
            ui << "error: division by zero\n";
            err = 1;
        }
        break;
    default:
        ui << "error: unrecognized operation\n";
        err = 1;
    }
    return err;
}

void Command_interpreter::read_matrix() const
{
#if defined ARTY || defined ASIC
    pmc.set_dout({0});

    const auto start{core.get_performance_counter()};
    const auto matrix{pixel_matrix.read(Pixel_matrix::Counter::a)};
    const auto stop{core.get_performance_counter()};
    const auto readout_time{static_cast<uint32_t>(stop - start)};
    debug_dec_word(readout_time);

    for (int col = 0; col < Pixel_matrix::cols; ++col)
        Debugger::print_hex_word(matrix[Pixel_matrix::rows - 1][col]);
#else
    ui << "error: operation not supported\n";
#endif
}

void Command_interpreter::calibrate_matrix() const
{
#if defined ARTY || defined ASIC
    pmc.set_dc(64);
    pmc.set_dout({0});

    const auto start{core.get_performance_counter()};
    pixel_matrix.calibrate();
    const auto stop{core.get_performance_counter()};
    const auto calibration_time{static_cast<uint32_t>(stop - start)};

    ui << "offset calibration done\n";
    debug_dec_word(calibration_time);
#else
    ui << "error: operation not supported\n";
#endif
}
