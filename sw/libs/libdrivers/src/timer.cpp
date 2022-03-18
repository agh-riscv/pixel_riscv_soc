#include <timer.hpp>
#include <common.hpp>
#include <memory_map.hpp>

static constexpr uint8_t cr_offset{0x000};
static constexpr uint8_t sr_offset{0x004};
static constexpr uint8_t cntr_offset{0x008};
static constexpr uint8_t cmpr_offset{0x00c};
static constexpr uint32_t ier_offset{0x010};
static constexpr uint32_t isr_offset{0x014};

static constexpr uint8_t cr_trg_shift{0};
static constexpr uint32_t cr_trg_mask{0x01};
static constexpr uint8_t cr_hlt_shift{1};
static constexpr uint32_t cr_hlt_mask{0x01};
static constexpr uint8_t cr_sngl_shift{2};
static constexpr uint32_t cr_sngl_mask{0x01};

static constexpr uint8_t sr_mtch_shift{0};
static constexpr uint32_t sr_mtch_mask{0x01};
static constexpr uint8_t sr_act_shift{1};
static constexpr uint32_t sr_act_mask{0x01};

static constexpr uint8_t ier_mtchie_shift{0};
static constexpr uint32_t ier_mtchie_mask{0x01};

static constexpr uint8_t isr_mtchf_shift{0};
static constexpr uint32_t isr_mtchf_mask{0x01};

Timer timer{timer_base_address};

Timer::Timer(const uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{ }

void Timer::set_cmpr(uint32_t val) const
{
    regs[cmpr_offset>>2] = val;
}

void Timer::enable() const
{
    set_reg_bits(regs, cr_offset, cr_trg_shift, cr_trg_mask, true);
}

void Timer::disable() const
{
    set_reg_bits(regs, cr_offset, cr_trg_shift, cr_trg_mask, false);
}

void Timer::clear_matched() const
{
    set_reg_bits(regs, sr_offset, sr_mtch_shift, sr_mtch_mask, false);
}

void Timer::enable_interrupts() const
{
    clear_interrupt();
    set_reg_bits(regs, ier_offset, ier_mtchie_shift, ier_mtchie_mask, true);
}

void Timer::disable_interrupts() const
{
    set_reg_bits(regs, ier_offset, ier_mtchie_shift, ier_mtchie_mask, false);
}

bool Timer::is_interrupt_pending() const
{
    return get_reg_bits(regs, isr_offset, isr_mtchf_shift, isr_mtchf_mask);
}

void Timer::clear_interrupt() const
{
    set_reg_bits(regs, isr_offset, isr_mtchf_shift, isr_mtchf_mask, false);
}
