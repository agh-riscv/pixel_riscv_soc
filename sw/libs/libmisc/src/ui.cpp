#include <ui.hpp>
#include <string_ops.hpp>
#include <libdrivers/uart.hpp>

Ui ui;

const Ui &Ui::operator>>(Buffer &buf) const noexcept
{
    uart.read(buf.data(), buf.size());
    return *this;
}

const Ui &Ui::operator<<(const Buffer &buf) const noexcept
{
    uart.write(buf.data());
    return *this;
}

const Ui &Ui::operator<<(const char *buf) const noexcept
{
    uart.write(buf);
    return *this;
}

const Ui &Ui::operator<<(const int &val) const noexcept
{
    char buf[11];
    to_string(buf, val);
    ui << buf;
    return *this;
}

void Ui::flush() const noexcept
{
    while (uart.is_transmitter_busy()) { }
}

int Ui::get_integer(const char *parameter_name) const noexcept
{
    while (true) {
        *this << parameter_name << ": ";

        Buffer buf;
        *this >> buf;
        if (is_number(buf.data()))
            return to_int(buf.data());
        else
            *this << "incorrect value. try again\n";
    }
    return 0;
}
