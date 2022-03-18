#include <spi.hpp>
#include <common.hpp>
#include <iomux.hpp>
#include <memory_map.hpp>

static constexpr uint32_t cr_offset{0x000};
static constexpr uint32_t sr_offset{0x004};
static constexpr uint32_t tdr_offset{0x008};
static constexpr uint32_t rdr_offset{0x00c};
static constexpr uint32_t cdr_offset{0x010};
static constexpr uint32_t ier_offset{0x014};
static constexpr uint32_t isr_offset{0x018};

static constexpr uint8_t cr_active_ss_shift{0};
static constexpr uint32_t cr_active_ss_mask{0x01};
static constexpr uint8_t cr_cpha_shift{1};
static constexpr uint32_t cr_cpha_mask{0x01};
static constexpr uint8_t cr_cpol_shift{2};
static constexpr uint32_t cr_cpol_mask{0x01};

static constexpr uint8_t sr_rx_fifo_full_shift{0};
static constexpr uint32_t sr_rx_fifo_full_mask{0x01};
static constexpr uint8_t sr_rx_fifo_empty_shift{1};
static constexpr uint32_t sr_rx_fifo_empty_mask{0x01};
static constexpr uint8_t sr_tx_fifo_full_shift{2};
static constexpr uint32_t sr_tx_fifo_full_mask{0x01};
static constexpr uint8_t sr_tx_fifo_empty_shift{3};
static constexpr uint32_t sr_tx_fifo_empty_mask{0x01};

static constexpr uint8_t tdr_data_shift{0};
static constexpr uint32_t tdr_data_mask{0xff};

static constexpr uint8_t rdr_data_shift{0};
static constexpr uint32_t rdr_data_mask{0xff};

static constexpr uint8_t cdr_div_shift{0};
static constexpr uint32_t cdr_div_mask{0xff};

static constexpr uint8_t ier_txfeie_shift{0};
static constexpr uint32_t ier_txfeie_mask{0x01};

static constexpr uint8_t isr_txfef_shift{0};
static constexpr uint32_t isr_txfef_mask{0x01};

Spi spi{spi_base_address};

Spi::Spi(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{ }

void Spi::init() const
{
    iomux.set_pin_mode(gpio25_spi_ss0_pin, Iomux::Mode::alternative);
    iomux.set_pin_mode(gpio27_spi_sck_pin, Iomux::Mode::alternative);
    iomux.set_pin_mode(gpio28_spi_mosi_pin, Iomux::Mode::alternative);
    iomux.set_pin_mode(gpio29_spi_miso_pin, Iomux::Mode::alternative);
}

void Spi::set_active_slave(uint8_t active_slave) const
{
    set_reg_bits(regs, cr_offset, cr_active_ss_shift, cr_active_ss_mask, active_slave);
}

void Spi::set_phase(Phase phase) const
{
    set_reg_bits(regs, cr_offset, cr_cpha_shift, cr_cpha_mask, static_cast<bool>(phase));
}

void Spi::set_polarity(Polarity polarity) const
{
    set_reg_bits(regs, cr_offset, cr_cpol_shift, cr_cpol_mask, static_cast<bool>(polarity));
}

void Spi::set_clock_divider(uint8_t val) const
{
    set_reg_bits(regs, cdr_offset, cdr_div_shift, cdr_div_mask, val);
}

uint8_t Spi::read() const
{
    set_wdata(0);
    while (is_receiver_fifo_empty()) { }
    return get_rdata();
}

void Spi::write(uint8_t val) const
{
    set_wdata(val);
    while (is_transmitter_fifo_full()) { }
    (void)get_rdata();
}

void Spi::write(const uint8_t *buf, int len) const
{
    for (int i = 0; i < len; ++i) {
        while (is_transmitter_fifo_full()) { }
        set_wdata(buf[i]);
    }
}

void Spi::write_sync(const uint8_t *buf, int len) const
{
    write(buf, len);
    flush();
}

void Spi::enable_transmitter_interrupts() const
{
    clear_transmitter_interrupt();
    set_reg_bits(regs, ier_offset, ier_txfeie_shift, ier_txfeie_mask, true);
}

void Spi::disable_transmitter_interrupts() const
{
    set_reg_bits(regs, ier_offset, ier_txfeie_shift, ier_txfeie_mask, false);
}

bool Spi::is_transmitter_interrupt_pending() const
{
    return get_reg_bits(regs, isr_offset, isr_txfef_shift, isr_txfef_mask);
}

void Spi::clear_transmitter_interrupt() const
{
    set_reg_bits(regs, isr_offset, isr_txfef_shift, isr_txfef_mask, false);
}

void Spi::set_wdata(uint8_t val) const
{
    set_reg_bits(regs, tdr_offset, tdr_data_shift, tdr_data_mask, val);
}

uint8_t Spi::get_rdata() const
{
    return get_reg_bits(regs, rdr_offset, rdr_data_shift, rdr_data_mask);
}

bool Spi::is_receiver_fifo_empty() const
{
    return get_reg_bits(regs, sr_offset, sr_rx_fifo_empty_shift, sr_rx_fifo_empty_mask);
}

bool Spi::is_transmitter_fifo_full() const
{
    return get_reg_bits(regs, sr_offset, sr_tx_fifo_full_shift, sr_tx_fifo_full_mask);
}

bool Spi::is_transmitter_fifo_empty() const
{
    return get_reg_bits(regs, sr_offset, sr_tx_fifo_empty_shift, sr_tx_fifo_empty_mask);
}

void Spi::flush() const
{
    while(!is_transmitter_fifo_empty()) { }
    while (!is_receiver_fifo_empty())
        (void)get_rdata();
}
