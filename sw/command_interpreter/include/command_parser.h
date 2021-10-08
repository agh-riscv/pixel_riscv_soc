#pragma once

#include "command.h"

class Command_parser final {
public:
    Command_parser() = default;
    Command_parser(const Command_parser &) = delete;
    Command_parser(Command_parser &&) = delete;
    Command_parser &operator=(const Command_parser &) = delete;
    Command_parser &operator=(Command_parser &&) = delete;

    Command parse(const char *string) const;

private:
    void tokenize(const char *string, Command &command) const;
    const char *find_token(const char *string) const;
    void copy_token(char *dest, const char *src) const;
    const char *find_token_end(const char *token) const;
    void parse_command_type(Command &command) const;
    void parse_command_args(Command &command) const;
};
