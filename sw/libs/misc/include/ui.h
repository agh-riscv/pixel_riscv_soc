#pragma once

class Ui final {
public:
    Ui() = delete;
    Ui(const Ui &) = delete;
    Ui(Ui &&) = delete;
    Ui &operator=(const Ui &) = delete;
    Ui &operator=(Ui &&) = delete;

    static int get_integer(const char *parameter_name);
};
