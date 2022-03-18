#pragma once

#include <array>
#include <cstdint>
#include <libdrivers/code_ram.hpp>

class Pmc final {
public:
    enum class Ctrl_mode : bool {coprocessed, direct};
    enum class Data_mode : bool {accelerated, direct};
    enum class Gate_control_mode : bool {internal, external};
    enum class Strobe_control_mode : bool {internal, external};

    Pmc(uint32_t base_address);
    Pmc(const Pmc &) = delete;
    Pmc(Pmc &&) = delete;
    Pmc &operator=(const Pmc &) = delete;
    Pmc &operator=(Pmc &&) = delete;

    void set_ctrl_mode(Ctrl_mode mode) const;
    void set_data_mode(Data_mode mode) const;
    void set_gate_ctrl_mode(Gate_control_mode mode) const;
    void set_strobe_ctrl_mode(Strobe_control_mode mode) const;
    void set_ctrl(uint32_t val) const;
    uint32_t get_ctrl() const;
    uint8_t get_pmcc_pc_if() const;

    void set_dout(uint32_t val) const;
    void set_dout(const std::array<uint16_t, 32> &data) const;
    uint32_t get_din() const;
    void get_din(std::array<uint16_t, 32> &dest) const;

    void set_fed_csa(uint8_t val) const;
    void set_idiscr(uint8_t val) const;
    void set_ikrum(uint8_t val) const;
    void set_ref_csa_in(uint8_t val) const;
    void set_ref_csa_mid(uint8_t val) const;
    void set_ref_csa_out(uint8_t val) const;
    void set_ref_dac(uint8_t val) const;
    void set_ref_dac_base(uint8_t val) const;
    void set_ref_dac_krum(uint8_t val) const;
    void set_shift_high(uint8_t val) const;
    void set_shift_low(uint8_t val) const;
    void set_th_high(uint8_t val) const;
    void set_th_low(uint8_t val) const;
    void set_vblr(uint8_t val) const;

    void set_lc_mode(uint8_t val) const;
    void set_limit_enable(uint8_t val) const;
    void set_num_bit_sel(uint8_t val) const;
    void set_sample_mode(uint8_t val) const;

    void set_pmcc_reset(bool reset) const;
    void load_pmcc_application(const uint8_t *buf, int len) const;
    void trigger_pmcc() const;
    bool is_pmcc_waiting_for_trigger() const;

private:
    volatile uint32_t * const regs;

    Code_ram pmcc_code_ram;
};

extern Pmc pmc;
