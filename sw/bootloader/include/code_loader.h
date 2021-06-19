#pragma once

class Code_loader final {
public:
    enum class Source : bool {spi, uart};

    Code_loader() = delete;
    Code_loader(const Code_loader &) = delete;
    Code_loader(Code_loader &&) = delete;
    Code_loader &operator=(const Code_loader &) = delete;
    Code_loader &operator=(Code_loader &&) = delete;

    static void load_code(const Source source);

private:
    static void load_code_through_spi();
    static void load_code_through_uart();
};
