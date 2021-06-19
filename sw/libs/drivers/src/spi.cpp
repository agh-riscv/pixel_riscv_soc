#include "spi.h"

static constexpr uint32_t spi_base_address{0x0100'1000};
static constexpr uint8_t cr_offset{0x00};
static constexpr uint8_t sr_offset{0x04};
static constexpr uint8_t tdr_offset{0x08};
static constexpr uint8_t rdr_offset{0x0C};
static constexpr uint8_t cdr_offset{0x10};

Spi spi{spi_base_address};

Spi::Spi(const uint32_t base_address)
    :   cr{reinterpret_cast<volatile Spi_cr *>(base_address + cr_offset)},
        sr{reinterpret_cast<volatile Spi_sr *>(base_address + sr_offset)},
        tdr{reinterpret_cast<volatile Spi_tdr *>(base_address + tdr_offset)},
        rdr{reinterpret_cast<volatile Spi_rdr *>(base_address + rdr_offset)},
        cdr{reinterpret_cast<volatile Spi_cdr *>(base_address + cdr_offset)}
{ }


void Spi::set_phase(const Phase phase) const volatile
{
    cr->cpha = static_cast<bool>(phase);
}

void Spi::set_polarity(const Polarity polarity) const volatile
{
    cr->cpol = static_cast<bool>(polarity);
}

void Spi::set_clock_divider(const uint8_t divider) const volatile
{
    cdr->div = divider;
}

uint8_t Spi::read() const volatile
{
    tdr->data = 0;
    while (!is_receiver_ready()) { }
    return rdr->data;
}

void Spi::write(const uint8_t byte) const volatile
{
    tdr->data = byte;
    while (is_transmitter_active()) { }
    (void)rdr->data;
}

bool Spi::is_receiver_ready() const volatile
{
    return sr->rxne;
}

bool Spi::is_transmitter_active() const volatile
{
    return sr->txact;
}
