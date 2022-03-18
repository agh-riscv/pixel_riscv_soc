#pragma once

class Command_argument final {
public:
    enum class Type {string, number};

    Command_argument() = default;
    Command_argument(const Command_argument &) = delete;
    Command_argument(Command_argument &&) = default;
    Command_argument &operator=(const Command_argument &) = delete;
    Command_argument &operator=(Command_argument &&) = delete;

    Type type{Type::string};
    union {
        char buf[25];
        int val;
    };
};
