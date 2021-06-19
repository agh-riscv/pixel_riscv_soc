#pragma once

#include "uart_cdr.h"
#include "uart_cr.h"
#include "uart_rdr.h"
#include "uart_sr.h"
#include "uart_tdr.h"

class Uart final {
public:
    Uart(const uint32_t base_address);
    Uart(const Uart &) = delete;
    Uart(Uart &&) = delete;
    Uart &operator=(const Uart &) = delete;
    Uart &operator=(Uart &&) = delete;

    uint8_t read() const volatile;
    int read(char *dest, const uint8_t len) const volatile;
    void write(const uint8_t byte) const volatile;
    void write(const char *src) const volatile;

private:
    volatile Uart_cr * const cr;
    volatile Uart_sr * const sr;
    volatile Uart_tdr * const tdr;
    volatile Uart_rdr * const rdr;
    volatile Uart_cdr * const cdr;

    bool is_receiver_ready() const volatile;
};

extern Uart uart;
