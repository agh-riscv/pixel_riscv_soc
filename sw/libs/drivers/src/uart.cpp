#include "uart.h"

static constexpr uint32_t uart_base_address{0x0100'2000};
static constexpr uint8_t cr_offset{0x00};
static constexpr uint8_t sr_offset{0x04};
static constexpr uint8_t tdr_offset{0x08};
static constexpr uint8_t rdr_offset{0x0C};
static constexpr uint8_t cdr_offset{0x10};

Uart uart{uart_base_address};

Uart::Uart(const uint32_t base_address)
    :   cr{reinterpret_cast<volatile Uart_cr *>(base_address + cr_offset)},
        sr{reinterpret_cast<volatile Uart_sr *>(base_address + sr_offset)},
        tdr{reinterpret_cast<volatile Uart_tdr *>(base_address + tdr_offset)},
        rdr{reinterpret_cast<volatile Uart_rdr *>(base_address + rdr_offset)},
        cdr{reinterpret_cast<volatile Uart_cdr *>(base_address + cdr_offset)}
{
#ifdef SIM
    cdr->div = 2;
#else
    cdr->div = 12;  /* 115200, when frequency is equal to 50 MHz */
#endif
    cr->en = 1;
}

uint8_t Uart::read() const volatile
{
    while (!is_receiver_ready()) { }
    return rdr->data;
}

int Uart::read(char *dest, const uint8_t len) const volatile
{
    for (int i = 0; i < len; ++i) {
        dest[i] = read();
        if (dest[i] == '\n') {
            dest[i] = '\0';
            return 0;
        } else if (dest[i] == '\b') {
            if (i)
                i -= 2;
            else
                i -= 1;
        }
    }
    return 1;
}

void Uart::write(const uint8_t byte) const volatile
{
    tdr->data = byte;
    while (sr->txact) { }
}

void Uart::write(const char *src) const volatile
{
    while (*src)
        write(*src++);
}

bool Uart::is_receiver_ready() const volatile
{
    return sr->rxne;
}

uint8_t Uart::get_rdata() const volatile
{
    return rdr->data;
}
