#include "command_parser.h"
#include "string_ops.h"

Command Command_parser::parse(const char *string) const
{
    Command command;

    tokenize(string, command);
    if (!command.argc) {
        command.type = Command::Type::empty;
        return command;
    }

    parse_command_type(command);
    parse_command_args(command);
    return command;
}

void Command_parser::tokenize(const char *string, Command &command) const
{
    const char *token;

    while (command.argc < static_cast<int>(command.args.size())) {
        token = find_token(string);
        if (!token)
            break;

        copy_token(command.args[command.argc].buf, token);
        string = find_token_end(token) + 1;
        ++command.argc;
    }
}

const char *Command_parser::find_token(const char *string) const
{
    while (*string) {
        if (*string != ' ')
            return string;
        ++string;
    }
    return nullptr;
}

void Command_parser::copy_token(char *dest, const char *token) const
{
    while (*token && *token != ' ')
        *dest++ = *token++;
    *dest = '\0';
}

const char *Command_parser::find_token_end(const char *token) const
{
    while (*token && *token != ' ')
        ++token;
    return token - 1;
}

void Command_parser::parse_command_type(Command &command) const
{
    const char *buf{command.args[0].buf};

    if (!strcmp(buf, "help"))
        command.type = Command::Type::help;
    else if (!strcmp(buf, "reset"))
        command.type = Command::Type::reset;
    else if (!strcmp(buf, "ping"))
        command.type = Command::Type::ping;
    else if (!strcmp(buf, "set_gpio_direction"))
        command.type = Command::Type::set_gpio_direction;
    else if (!strcmp(buf, "get_gpio_direction"))
        command.type = Command::Type::get_gpio_direction;
    else if (!strcmp(buf, "set_gpio"))
        command.type = Command::Type::set_gpio;
    else if (!strcmp(buf, "get_gpio"))
        command.type = Command::Type::get_gpio;
    else if (!strcmp(buf, "set_heartbeat"))
        command.type = Command::Type::set_heartbeat;
    else if (!strcmp(buf, "calculate"))
        command.type = Command::Type::calculate;
    else if (!strcmp(buf, "read_matrix"))
        command.type = Command::Type::read_matrix;
    else if (!strcmp(buf, "calibrate_matrix"))
        command.type = Command::Type::calibrate_matrix;
    else
        command.type = Command::Type::unrecognized;

    --command.argc;
}

void Command_parser::parse_command_args(Command &command) const
{
    for (int i = 0; i < command.argc; ++i) {
        if (is_number(command.args[i + 1].buf)) {
            command.args[i].type = Command_argument::Type::number;
            command.args[i].val = to_int(command.args[i + 1].buf);
        } else {
            command.args[i].type = Command_argument::Type::string;
            strcpy(command.args[i].buf, command.args[i + 1].buf);
        }
    }
}
