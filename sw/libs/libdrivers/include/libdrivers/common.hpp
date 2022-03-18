#pragma once

#include <cstdint>

static constexpr uint8_t gpio31_uart_sin_pin{31};
static constexpr uint8_t gpio30_uart_sout_pin{30};
static constexpr uint8_t gpio29_spi_miso_pin{29};
static constexpr uint8_t gpio28_spi_mosi_pin{28};
static constexpr uint8_t gpio27_spi_sck_pin{27};
static constexpr uint8_t gpio26_spi_ss1_pin{26};
static constexpr uint8_t gpio25_spi_ss0_pin{25};
static constexpr uint8_t gpio24_pmc_strobe_pin{24};
static constexpr uint8_t gpio23_pmc_gate_pin{23};

uint32_t get_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask);
void set_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask, uint32_t val);
void toggle_reg_bits(volatile uint32_t *regs, uint32_t offset,
    uint8_t shift, uint32_t mask);
