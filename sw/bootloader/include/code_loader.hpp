#pragma once

#include <libdrivers/code_ram.hpp>

class Code_loader final {
public:
    Code_loader();
    Code_loader(const Code_loader &) = delete;
    Code_loader(Code_loader &&) = delete;
    Code_loader &operator=(const Code_loader &) = delete;
    Code_loader &operator=(Code_loader &&) = delete;

    void load_code_through_spi();
    int load_code_through_uart();

private:
    Code_ram code_ram;
};
