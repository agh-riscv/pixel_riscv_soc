#include <command_interpreter.hpp>
#include <libdrivers/core.hpp>
#include <libdrivers/gpio.hpp>
#include <libdrivers/pmc.hpp>
#include <libdrivers/timer.hpp>
#include <libmisc/debug.hpp>
#include <libmisc/pixel_matrix.hpp>
#include <libmisc/string_ops.hpp>
#include <libmisc/ui.hpp>

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
        case cmd_type::set_pm_controller_mode:
            set_pm_controller_mode(command);
            break;
        case cmd_type::read_matrix:
            read_matrix();
            break;
        case cmd_type::calibrate_matrix:
            calibrate_matrix();
            break;
        case cmd_type::test_matrix_write_read:
            test_matrix_write_read();
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
        "set_pm_controller_mode <mode>     - set pm controller mode\n"
        " - accelerated\n"
        " - coprocessed\n"
        " - direct\n"
        "read_matrix                       - read matrix\n"
        "calibrate_matrix                  - calibrate pixels offsets\n"
        "test_matrix_write_read            - execute matrix write_read test\n"
    };
    ui << message;
}

void Command_interpreter::reset() const
{
#ifdef BASYS
    gpio.set_pin_direction(20, Gpio::Direction::out);
    gpio.set_pin(20, true);
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
            timer.clear_interrupt();
        });
        timer.set_cmpr(command.args[0].val * 50'000 - 1);   /* f = 50 MHz */
        timer.enable_interrupts();
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

int Command_interpreter::set_pm_controller_mode(const Command &command) const
{
    if (command.argc < 1) {
        ui << "error: missing argument\n";
        return 1;
    } else if (command.args[0].type != arg_type::string) {
        ui << "error: invalid argument type\n";
        return 1;
    }

    if (!strcmp(command.args[0].buf, "accelerated")) {
        pixel_matrix.init(Pm::Controller_mode::accelerated);
    } else if (!strcmp(command.args[0].buf, "coprocessed")) {
        pixel_matrix.init(Pm::Controller_mode::coprocessed);
    } else if (!strcmp(command.args[0].buf, "direct")) {
        pixel_matrix.init(Pm::Controller_mode::direct);
    } else {
        ui << "error: invalid controller mode\n";
        return 1;
    }

    ui << "controller mode updated\n";
    return 0;
}

void Command_interpreter::read_matrix() const
{
    pmc.set_dout({0});

    const auto start{core.get_performance_counter()};
    const auto matrix{pixel_matrix.read(Pm::Counter::a, true)};
    const auto stop{core.get_performance_counter()};
    const auto readout_time{static_cast<uint32_t>(stop - start)};
    debug_dec_word(readout_time);

    for (int col = 0; col < Pm::cols; ++col)
        Debugger::print_hex_word(matrix[Pm::rows - 1][col]);
}

void Command_interpreter::calibrate_matrix() const
{
    pmc.set_dout({0});

    const auto start{core.get_performance_counter()};
    pixel_matrix.calibrate();
    const auto stop{core.get_performance_counter()};
    const auto calibration_time{static_cast<uint32_t>(stop - start)};

    ui << "offset calibration done\n";
    debug_dec_word(calibration_time);
}

void Command_interpreter::test_matrix_write_read() const
{
    static constexpr Pm::Counters wdata_a{{
        {
            0x000, 0x001, 0x002, 0x003, 0x004, 0x005, 0x006, 0x007, 0x008, 0x009, 0x00a, 0x00b,
            0x00c, 0x00d, 0x00e, 0x00f, 0x010, 0x011, 0x012, 0x013, 0x014, 0x015, 0x016, 0x017,
            0x018, 0x019, 0x01a, 0x01b, 0x01c, 0x01d, 0x01e, 0x01f
        }, {
            0x020, 0x021, 0x022, 0x023, 0x024, 0x025, 0x026, 0x027, 0x028, 0x029, 0x02a, 0x02b,
            0x02c, 0x02d, 0x02e, 0x02f, 0x030, 0x031, 0x032, 0x033, 0x034, 0x035, 0x036, 0x037,
            0x038, 0x039, 0x03a, 0x03b, 0x03c, 0x03d, 0x03e, 0x03f
        }, {
            0x040, 0x041, 0x042, 0x043, 0x044, 0x045, 0x046, 0x047, 0x048, 0x049, 0x04a, 0x04b,
            0x04c, 0x04d, 0x04e, 0x04f, 0x050, 0x051, 0x052, 0x053, 0x054, 0x055, 0x056, 0x057,
            0x058, 0x059, 0x05a, 0x05b, 0x05c, 0x05d, 0x05e, 0x05f
        }, {
            0x060, 0x061, 0x062, 0x063, 0x064, 0x065, 0x066, 0x067, 0x068, 0x069, 0x06a, 0x06b,
            0x06c, 0x06d, 0x06e, 0x06f, 0x070, 0x071, 0x072, 0x073, 0x074, 0x075, 0x076, 0x077,
            0x078, 0x079, 0x07a, 0x07b, 0x07c, 0x07d, 0x07e, 0x07f
        }, {
            0x080, 0x081, 0x082, 0x083, 0x084, 0x085, 0x086, 0x087, 0x088, 0x089, 0x08a, 0x08b,
            0x08c, 0x08d, 0x08e, 0x08f, 0x090, 0x091, 0x092, 0x093, 0x094, 0x095, 0x096, 0x097,
            0x098, 0x099, 0x09a, 0x09b, 0x09c, 0x09d, 0x09e, 0x09f
        }, {
            0x0a0, 0x0a1, 0x0a2, 0x0a3, 0x0a4, 0x0a5, 0x0a6, 0x0a7, 0x0a8, 0x0a9, 0x0aa, 0x0ab,
            0x0ac, 0x0ad, 0x0ae, 0x0af, 0x0b0, 0x0b1, 0x0b2, 0x0b3, 0x0b4, 0x0b5, 0x0b6, 0x0b7,
            0x0b8, 0x0b9, 0x0ba, 0x0bb, 0x0bc, 0x0bd, 0x0be, 0x0bf
        }, {
            0x0c0, 0x0c1, 0x0c2, 0x0c3, 0x0c4, 0x0c5, 0x0c6, 0x0c7, 0x0c8, 0x0c9, 0x0ca, 0x0cb,
            0x0cc, 0x0cd, 0x0ce, 0x0cf, 0x0d0, 0x0d1, 0x0d2, 0x0d3, 0x0d4, 0x0d5, 0x0d6, 0x0d7,
            0x0d8, 0x0d9, 0x0da, 0x0db, 0x0dc, 0x0dd, 0x0de, 0x0df
        }, {
            0x0e0, 0x0e1, 0x0e2, 0x0e3, 0x0e4, 0x0e5, 0x0e6, 0x0e7, 0x0e8, 0x0e9, 0x0ea, 0x0eb,
            0x0ec, 0x0ed, 0x0ee, 0x0ef, 0x0f0, 0x0f1, 0x0f2, 0x0f3, 0x0f4, 0x0f5, 0x0f6, 0x0f7,
            0x0f8, 0x0f9, 0x0fa, 0x0fb, 0x0fc, 0x0fd, 0x0fe, 0x0ff
        }
    }};

    static constexpr Pm::Counters wdata_b{{
        {
            0x400, 0x401, 0x402, 0x403, 0x404, 0x405, 0x406, 0x407, 0x408, 0x409, 0x40a, 0x40b,
            0x40c, 0x40d, 0x40e, 0x40f, 0x410, 0x411, 0x412, 0x413, 0x414, 0x415, 0x416, 0x417,
            0x418, 0x419, 0x41a, 0x41b, 0x41c, 0x41d, 0x41e, 0x41f
        }, {
            0x420, 0x421, 0x422, 0x423, 0x424, 0x425, 0x426, 0x427, 0x428, 0x429, 0x42a, 0x42b,
            0x42c, 0x42d, 0x42e, 0x42f, 0x430, 0x431, 0x432, 0x433, 0x434, 0x435, 0x436, 0x437,
            0x438, 0x439, 0x43a, 0x43b, 0x43c, 0x43d, 0x43e, 0x43f
        }, {
            0x440, 0x441, 0x442, 0x443, 0x444, 0x445, 0x446, 0x447, 0x448, 0x449, 0x44a, 0x44b,
            0x44c, 0x44d, 0x44e, 0x44f, 0x450, 0x451, 0x452, 0x453, 0x454, 0x455, 0x456, 0x457,
            0x458, 0x459, 0x45a, 0x45b, 0x45c, 0x45d, 0x45e, 0x45f
        }, {
            0x460, 0x461, 0x462, 0x463, 0x464, 0x465, 0x466, 0x467, 0x468, 0x469, 0x46a, 0x46b,
            0x46c, 0x46d, 0x46e, 0x46f, 0x470, 0x471, 0x472, 0x473, 0x474, 0x475, 0x476, 0x477,
            0x478, 0x479, 0x47a, 0x47b, 0x47c, 0x47d, 0x47e, 0x47f
        }, {
            0x480, 0x481, 0x482, 0x483, 0x484, 0x485, 0x486, 0x487, 0x488, 0x489, 0x48a, 0x48b,
            0x48c, 0x48d, 0x48e, 0x48f, 0x490, 0x491, 0x492, 0x493, 0x494, 0x495, 0x496, 0x497,
            0x498, 0x499, 0x49a, 0x49b, 0x49c, 0x49d, 0x49e, 0x49f
        }, {
            0x4a0, 0x4a1, 0x4a2, 0x4a3, 0x4a4, 0x4a5, 0x4a6, 0x4a7, 0x4a8, 0x4a9, 0x4aa, 0x4ab,
            0x4ac, 0x4ad, 0x4ae, 0x4af, 0x4b0, 0x4b1, 0x4b2, 0x4b3, 0x4b4, 0x4b5, 0x4b6, 0x4b7,
            0x4b8, 0x4b9, 0x4ba, 0x4bb, 0x4bc, 0x4bd, 0x4be, 0x4bf
        }, {
            0x4c0, 0x4c1, 0x4c2, 0x4c3, 0x4c4, 0x4c5, 0x4c6, 0x4c7, 0x4c8, 0x4c9, 0x4ca, 0x4cb,
            0x4cc, 0x4cd, 0x4ce, 0x4cf, 0x4d0, 0x4d1, 0x4d2, 0x4d3, 0x4d4, 0x4d5, 0x4d6, 0x4d7,
            0x4d8, 0x4d9, 0x4da, 0x4db, 0x4dc, 0x4dd, 0x4de, 0x4df
        }, {
            0x4e0, 0x4e1, 0x4e2, 0x4e3, 0x4e4, 0x4e5, 0x4e6, 0x4e7, 0x4e8, 0x4e9, 0x4ea, 0x4eb,
            0x4ec, 0x4ed, 0x4ee, 0x4ef, 0x4f0, 0x4f1, 0x4f2, 0x4f3, 0x4f4, 0x4f5, 0x4f6, 0x4f7,
            0x4f8, 0x4f9, 0x4fa, 0x4fb, 0x4fc, 0x4fd, 0x4fe, 0x4ff
        }
    }};

    pixel_matrix.init(Pm::Controller_mode::accelerated);

    pixel_matrix.write(Pm::Counter::a, wdata_a);
    pixel_matrix.write(Pm::Counter::b, wdata_b);

    const auto rdata_a = pixel_matrix.read(Pm::Counter::a, false);
    const auto rdata_b = pixel_matrix.read(Pm::Counter::b, false);
    const auto test_passed = (rdata_a == wdata_a) && (rdata_b == wdata_b);
    ui << "test " << (test_passed ? "passed" : "failed") << "\n";
}
