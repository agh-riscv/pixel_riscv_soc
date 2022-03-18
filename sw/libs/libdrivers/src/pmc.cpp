#include <pmc.hpp>
#include <cstring>
#include <common.hpp>
#include <memory_map.hpp>

static constexpr uint8_t cr_offset{0x0000};
static constexpr uint8_t sr_offset{0x0004};
static constexpr uint8_t ctrls_offset{0x0008};
static constexpr uint8_t ctrlr_offset{0x000c};
static constexpr uint8_t dout_offset{0x0010};
static constexpr uint8_t din_offset{0x0050};

static constexpr uint32_t ac_0_offset{0x0100};
static constexpr uint32_t ac_1_offset{0x0104};
static constexpr uint32_t ac_2_offset{0x0108};
static constexpr uint32_t ac_3_offset{0x010c};

static constexpr uint32_t dc_offset{0x0200};

static constexpr uint32_t code_ram_offset{0x1000};
static constexpr uint32_t code_ram_depth{256};
static constexpr uint32_t code_ram_word_length{4};
static constexpr uint32_t code_ram_size{code_ram_depth * code_ram_word_length};

static constexpr uint8_t cr_pmcc_rst_n_shift{0};
static constexpr uint32_t cr_pmcc_rst_n_mask{0x01};
static constexpr uint8_t cr_pmcc_trg_shift{1};
static constexpr uint32_t cr_pmcc_trg_mask{0x01};
static constexpr uint8_t cr_direct_ctrl_shift{2};
static constexpr uint32_t cr_direct_ctrl_mask{0x01};
static constexpr uint8_t cr_direct_data_shift{3};
static constexpr uint32_t cr_direct_data_mask{0x01};
static constexpr uint8_t cr_ext_gate_shift{4};
static constexpr uint32_t cr_ext_gate_mask{0x01};
static constexpr uint8_t cr_ext_strobe_shift{5};
static constexpr uint32_t cr_ext_strobe_mask{0x01};

static constexpr uint8_t sr_pmcc_wtt_shift{0};
static constexpr uint32_t sr_pmcc_wtt_mask{0x01};
static constexpr uint8_t sr_pmcc_pc_if_shift{1};
static constexpr uint32_t sr_pmcc_pc_if_mask{0xff};

static constexpr uint8_t ctrlx_clk_sh_shift{0};
static constexpr uint32_t ctrlx_clk_sh_mask{0x01};
static constexpr uint8_t ctrlx_sh_a_shift{1};
static constexpr uint32_t ctrlx_sh_a_mask{0x01};
static constexpr uint8_t ctrlx_sh_b_shift{2};
static constexpr uint32_t ctrlx_sh_b_mask{0x01};
static constexpr uint8_t ctrlx_gate_shift{3};
static constexpr uint32_t ctrlx_gate_mask{0x01};
static constexpr uint8_t ctrlx_strobe_shift{4};
static constexpr uint32_t ctrlx_strobe_mask{0x01};
static constexpr uint8_t ctrlx_write_cfg_shift{5};
static constexpr uint32_t ctrlx_write_cfg_mask{0x01};

static constexpr uint8_t ac_0_fed_csa_shift{0};
static constexpr uint32_t ac_0_fed_csa_mask{0x3f};
static constexpr uint8_t ac_0_idiscr_shift{6};
static constexpr uint32_t ac_0_idiscr_mask{0x3f};
static constexpr uint8_t ac_0_ref_csa_in_shift{12};
static constexpr uint32_t ac_0_ref_csa_in_mask{0x3f};
static constexpr uint8_t ac_0_ref_csa_mid_shift{18};
static constexpr uint32_t ac_0_ref_csa_mid_mask{0x3f};
static constexpr uint8_t ac_0_ref_csa_out_shift{24};
static constexpr uint32_t ac_0_ref_csa_out_mask{0x3f};

static constexpr uint8_t ac_1_ref_dac_shift{0};
static constexpr uint32_t ac_1_ref_dac_mask{0x3f};
static constexpr uint8_t ac_1_ref_dac_base_shift{6};
static constexpr uint32_t ac_1_ref_dac_base_mask{0x3f};
static constexpr uint8_t ac_1_ref_dac_krum_shift{12};
static constexpr uint32_t ac_1_ref_dac_krum_mask{0x3f};
static constexpr uint8_t ac_1_shift_high_shift{18};
static constexpr uint32_t ac_1_shift_high_mask{0x3f};
static constexpr uint8_t ac_1_shift_low_shift{24};
static constexpr uint32_t ac_1_shift_low_mask{0x3f};

static constexpr uint8_t ac_2_ikrum_shift{0};
static constexpr uint32_t ac_2_ikrum_mask{0x7f};
static constexpr uint8_t ac_2_vblr_shift{7};
static constexpr uint32_t ac_2_vblr_mask{0x7f};
static constexpr uint8_t ac_2_th_high_shift{14};
static constexpr uint32_t ac_2_th_high_mask{0xff};
static constexpr uint8_t ac_2_th_low_shift{22};
static constexpr uint32_t ac_2_th_low_mask{0xff};

static constexpr uint8_t dc_sample_mode_shift{0};
static constexpr uint32_t dc_sample_mode_mask{0x01};
static constexpr uint8_t dc_limit_enable_shift{1};
static constexpr uint32_t dc_limit_enable_mask{0x01};
static constexpr uint8_t dc_lc_mode_shift{2};
static constexpr uint32_t dc_lc_mode_mask{0x01};
static constexpr uint8_t dc_num_bit_sel_shift{3};
static constexpr uint32_t dc_num_bit_sel_mask{0x07};

Pmc pmc{pmc_base_address};

Pmc::Pmc(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)},
        pmcc_code_ram{base_address + code_ram_offset, code_ram_size}
{ }

void Pmc::set_ctrl_mode(Ctrl_mode mode) const
{
    set_reg_bits(regs, cr_offset,
        cr_direct_ctrl_shift, cr_direct_ctrl_mask, static_cast<bool>(mode));
}

void Pmc::set_data_mode(Data_mode mode) const
{
    set_reg_bits(regs, cr_offset,
        cr_direct_data_shift, cr_direct_data_mask, static_cast<bool>(mode));
}

void Pmc::set_gate_ctrl_mode(Gate_control_mode mode) const
{
    set_reg_bits(regs, cr_offset,
        cr_ext_gate_shift, cr_ext_gate_mask, static_cast<bool>(mode));
}

void Pmc::set_strobe_ctrl_mode(Strobe_control_mode mode) const
{
    set_reg_bits(regs, cr_offset,
        cr_ext_strobe_shift, cr_ext_strobe_mask, static_cast<bool>(mode));
}

void Pmc::set_ctrl(uint32_t val) const
{
    regs[ctrls_offset>>2] = val;
}

uint32_t Pmc::get_ctrl() const
{
    return regs[ctrlr_offset>>2];
}

uint8_t Pmc::get_pmcc_pc_if() const
{
    return get_reg_bits(regs, sr_offset, sr_pmcc_pc_if_shift, sr_pmcc_pc_if_mask);
}

void Pmc::set_dout(uint32_t val) const
{
    regs[dout_offset>>2] = val;
}

void Pmc::set_dout(const std::array<uint16_t, 32> &data) const
{
    std::memcpy((void *)&regs[dout_offset>>2], data.data(), 64);
}

uint32_t Pmc::get_din() const
{
    return regs[din_offset>>2];
}

void Pmc::get_din(std::array<uint16_t, 32> &dest) const
{
    std::memcpy(dest.data(), (void *)&regs[din_offset>>2], 64);
}

void Pmc::set_fed_csa(uint8_t val) const
{
    set_reg_bits(regs, ac_0_offset, ac_0_fed_csa_shift, ac_0_fed_csa_mask, val);
}

void Pmc::set_idiscr(uint8_t val) const
{
    set_reg_bits(regs, ac_0_offset, ac_0_idiscr_shift, ac_0_idiscr_mask, val);
}

void Pmc::set_ikrum(uint8_t val) const
{
    set_reg_bits(regs, ac_2_offset, ac_2_ikrum_shift, ac_2_ikrum_mask, val);
}

void Pmc::set_ref_csa_in(uint8_t val) const
{
    set_reg_bits(regs, ac_0_offset, ac_0_ref_csa_in_shift, ac_0_ref_csa_in_mask, val);
}

void Pmc::set_ref_csa_mid(uint8_t val) const
{
    set_reg_bits(regs, ac_0_offset, ac_0_ref_csa_mid_shift, ac_0_ref_csa_mid_mask, val);
}

void Pmc::set_ref_csa_out(uint8_t val) const
{
    set_reg_bits(regs, ac_0_offset, ac_0_ref_csa_out_shift, ac_0_ref_csa_out_mask, val);
}

void Pmc::set_ref_dac(uint8_t val) const
{
    set_reg_bits(regs, ac_1_offset, ac_1_ref_dac_shift, ac_1_ref_dac_mask, val);
}

void Pmc::set_ref_dac_base(uint8_t val) const
{
    set_reg_bits(regs, ac_1_offset, ac_1_ref_dac_base_shift, ac_1_ref_dac_base_mask, val);
}

void Pmc::set_ref_dac_krum(uint8_t val) const
{
    set_reg_bits(regs, ac_1_offset, ac_1_ref_dac_krum_shift, ac_1_ref_dac_krum_mask, val);
}

void Pmc::set_shift_high(uint8_t val) const
{
    set_reg_bits(regs, ac_1_offset, ac_1_shift_high_shift, ac_1_shift_high_mask, val);
}

void Pmc::set_shift_low(uint8_t val) const
{
    set_reg_bits(regs, ac_1_offset, ac_1_shift_low_shift, ac_1_shift_low_mask, val);
}

void Pmc::set_th_high(uint8_t val) const
{
    set_reg_bits(regs, ac_2_offset, ac_2_th_high_shift, ac_2_th_high_mask, val);
}

void Pmc::set_th_low(uint8_t val) const
{
    set_reg_bits(regs, ac_2_offset, ac_2_th_low_shift, ac_2_th_low_mask, val);
}

void Pmc::set_vblr(uint8_t val) const
{
    set_reg_bits(regs, ac_2_offset, ac_2_vblr_shift, ac_2_vblr_mask, val);
}

void Pmc::set_lc_mode(uint8_t val) const
{
    set_reg_bits(regs, dc_offset, dc_lc_mode_shift, dc_lc_mode_mask, val);
}

void Pmc::set_limit_enable(uint8_t val) const
{
    set_reg_bits(regs, dc_offset, dc_limit_enable_shift, dc_limit_enable_mask, val);
}

void Pmc::set_num_bit_sel(uint8_t val) const
{
    set_reg_bits(regs, dc_offset, dc_num_bit_sel_shift, dc_num_bit_sel_mask, val);
}

void Pmc::set_sample_mode(uint8_t val) const
{
    set_reg_bits(regs, dc_offset, dc_sample_mode_shift, dc_sample_mode_mask, val);
}

void Pmc::set_pmcc_reset(bool val) const
{
    set_reg_bits(regs, cr_offset,
        cr_pmcc_rst_n_shift, cr_pmcc_rst_n_mask, !val);
}

void Pmc::load_pmcc_application(const uint8_t *buf, int len) const
{
    union Code_ram_word {
        uint8_t bytes[4];
        uint32_t word;
    };

    set_pmcc_reset(true);

    int words_written;
    for (words_written = 0; words_written < len / 4; ++words_written) {
        Code_ram_word code_ram_word;
        for (int i = 0; i < 4; ++i)
            code_ram_word.bytes[i] = buf[words_written * 4 + i];
        pmcc_code_ram.write(words_written * 4, code_ram_word.word);
    }

    int bytes_left = len - 4 * words_written;
    if (bytes_left) {
        Code_ram_word code_ram_word;
        for (int i = 0; i < 3; ++i)
            code_ram_word.bytes[i] = (bytes_left > i) ? buf[words_written * 4 + i] : 0;
        code_ram_word.bytes[3] = 0;
        pmcc_code_ram.write(words_written * 4, code_ram_word.word);
    }

    set_pmcc_reset(false);
}

void Pmc::trigger_pmcc() const
{
    set_reg_bits(regs, cr_offset,
        cr_pmcc_trg_shift, cr_pmcc_trg_mask, 1);
}

bool Pmc::is_pmcc_waiting_for_trigger() const
{
    return get_reg_bits(regs, sr_offset, sr_pmcc_wtt_shift, sr_pmcc_wtt_mask);
}
