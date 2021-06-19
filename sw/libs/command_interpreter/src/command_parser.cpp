#include "command_parser.h"
#include "string.h"

Command Command_parser::parse(const char *command) const
{
    if (!strcmp(command, "help"))
        return Command::help;
    else if (!strcmp(command, "set_led"))
        return Command::set_led;
    else if (!strcmp(command, "read_matrix"))
        return Command::read_matrix;
    else if (!strcmp(command, "calibrate_matrix"))
        return Command::calibrate_matrix;
    else
        return Command::unrecognized;
}
