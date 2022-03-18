#pragma once

#include <array>
#include <cstdint>

class Ui final {
public:
    typedef std::array<char, 100> Buffer;

    Ui() = default;
    Ui(const Ui &) = delete;
    Ui(Ui &&) = delete;
    Ui &operator=(const Ui &) = delete;
    Ui &operator=(Ui &&) = delete;

    const Ui &operator>>(Buffer &buf) const noexcept;
    const Ui &operator<<(const Buffer &buf) const noexcept;
    const Ui &operator<<(const char *buf) const noexcept;
    const Ui &operator<<(const int &val) const noexcept;

    void flush() const noexcept;
    int get_integer(const char *parameter_name) const noexcept;
};

extern Ui ui;
