/**
 * Copyright (C) 2020  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

module pixel_riscv_soc (
    input logic         clk,
    input logic         rst_n,

    output logic        gpio31_out,
    output logic        gpio30_uart_sout_out,
    output logic        gpio29_out,
    output logic        gpio28_spi_mosi_out,
    output logic        gpio27_spi_sck_out,
    output logic        gpio26_spi_ss1_out,
    output logic        gpio25_spi_ss0_out,
    output logic        gpio24_out,
    output logic        gpio23_out,
    output logic        gpio22_out,
    output logic        gpio21_out,
    output logic        gpio20_out,
    output logic        gpio19_out,
    output logic        gpio18_out,
    output logic        gpio17_out,
    output logic        gpio16_out,
    output logic        gpio15_out,
    output logic        gpio14_out,
    output logic        gpio13_out,
    output logic        gpio12_out,
    output logic        gpio11_out,
    output logic        gpio10_out,
    output logic        gpio9_out,
    output logic        gpio8_out,
    output logic        gpio7_out,
    output logic        gpio6_out,
    output logic        gpio5_out,
    output logic        gpio4_out,
    output logic        gpio3_out,
    output logic        gpio2_out,
    output logic        gpio1_out,
    output logic        gpio0_out,

    input logic         gpio31_uart_sin_in,
    input logic         gpio30_in,
    input logic         gpio29_spi_miso_in,
    input logic         gpio28_in,
    input logic         gpio27_in,
    input logic         gpio26_in,
    input logic         gpio25_in,
    input logic         gpio24_pmc_strobe_in,
    input logic         gpio23_pmc_gate_in,
    input logic         gpio22_in,
    input logic         gpio21_in,
    input logic         gpio20_in,
    input logic         gpio19_in,
    input logic         gpio18_in,
    input logic         gpio17_in,
    input logic         gpio16_in,
    input logic         gpio15_in,
    input logic         gpio14_in,
    input logic         gpio13_in,
    input logic         gpio12_in,
    input logic         gpio11_in,
    input logic         gpio10_in,
    input logic         gpio9_in,
    input logic         gpio8_in,
    input logic         gpio7_in,
    input logic         gpio6_in,
    input logic         gpio5_in,
    input logic         gpio4_in,
    input logic         gpio3_in,
    input logic         gpio2_in,
    input logic         gpio1_in,
    input logic         gpio0_in,

    output logic [31:0] pm_ctrl_store,
    output logic [31:0] pm_ctrl_strobe,
    output logic [31:0] pm_ctrl_gate,
    output logic [31:0] pm_ctrl_sh_b,
    output logic [31:0] pm_ctrl_sh_a,
    output logic [31:0] pm_ctrl_clk_sh,

    output logic [31:0] pm_data_din,
    input logic [31:0]  pm_data_dout_a,
    input logic [31:0]  pm_data_dout_b,

    output logic [5:0]  pm_analog_config_fed_csa,
    output logic [5:0]  pm_analog_config_fed_csa_b,

    output logic [5:0]  pm_analog_config_idiscr,
    output logic [5:0]  pm_analog_config_idiscr_b,

    output logic [6:0]  pm_analog_config_ikrum,
    output logic [6:0]  pm_analog_config_ikrum_b,

    output logic [5:0]  pm_analog_config_ref_csa_in,
    output logic [5:0]  pm_analog_config_ref_csa_in_b,

    output logic [5:0]  pm_analog_config_ref_csa_mid,
    output logic [5:0]  pm_analog_config_ref_csa_mid_b,

    output logic [5:0]  pm_analog_config_ref_csa_out,
    output logic [5:0]  pm_analog_config_ref_csa_out_b,

    output logic [5:0]  pm_analog_config_ref_dac,
    output logic [5:0]  pm_analog_config_ref_dac_b,

    output logic [5:0]  pm_analog_config_ref_dac_base,
    output logic [5:0]  pm_analog_config_ref_dac_base_b,

    output logic [5:0]  pm_analog_config_ref_dac_krum,
    output logic [5:0]  pm_analog_config_ref_dac_krum_b,

    output logic [5:0]  pm_analog_config_shift_high,
    output logic [5:0]  pm_analog_config_shift_high_b,

    output logic [5:0]  pm_analog_config_shift_low,
    output logic [5:0]  pm_analog_config_shift_low_b,

    output logic [7:0]  pm_analog_config_th_high,
    output logic [7:0]  pm_analog_config_th_high_b,

    output logic [7:0]  pm_analog_config_th_low,
    output logic [7:0]  pm_analog_config_th_low_b,

    output logic [6:0]  pm_analog_config_vblr,
    output logic [6:0]  pm_analog_config_vblr_b,

    output logic        pm_digital_config_lc_mode,
    output logic        pm_digital_config_limit_enable,
    output logic [2:0]  pm_digital_config_num_bit_sel,
    output logic        pm_digital_config_sample_mode
);


/**
 * Local variables and signals
 */

ibex_data_bus         core_data_bus ();
ibex_instr_bus        core_instr_bus ();

ibex_data_bus         boot_rom_data_bus ();
ibex_data_bus         code_ram_data_bus ();
ibex_data_bus         data_ram_data_bus ();

ibex_data_bus         gpio_data_bus ();
ibex_data_bus         iomux_data_bus ();
ibex_data_bus         pmc_data_bus ();
ibex_data_bus         spi_data_bus ();
ibex_data_bus         timer_data_bus ();
ibex_data_bus         uart_data_bus ();

ibex_instr_bus        boot_rom_instr_bus ();
ibex_instr_bus        code_ram_instr_bus ();

soc_gpio_bus          gpio_bus ();
soc_pmc_bus           pmc_bus ();
soc_spi_bus           spi_bus ();
soc_uart_bus          uart_bus ();

soc_pm_ctrl           pm_ctrl ();
soc_pm_data           pm_data ();
soc_pm_analog_config  pm_analog_config ();
soc_pm_digital_config pm_digital_config ();

logic                 gpio_irq, spi_irq, timer_irq, uart_irq;


/**
 * Signals assignments
 */

assign pm_ctrl_store = pm_ctrl.store;
assign pm_ctrl_strobe = pm_ctrl.strobe;
assign pm_ctrl_gate = pm_ctrl.gate;
assign pm_ctrl_sh_b = pm_ctrl.sh_b;
assign pm_ctrl_sh_a = pm_ctrl.sh_a;
assign pm_ctrl_clk_sh = pm_ctrl.clk_sh;

assign pm_data_din = pm_data.din;
assign pm_data.dout_a = pm_data_dout_a;
assign pm_data.dout_b = pm_data_dout_b;

assign pm_analog_config_fed_csa = pm_analog_config.fed_csa;
assign pm_analog_config_fed_csa_b = ~pm_analog_config.fed_csa;

assign pm_analog_config_idiscr = pm_analog_config.idiscr;
assign pm_analog_config_idiscr_b = ~pm_analog_config.idiscr;

assign pm_analog_config_ikrum = pm_analog_config.ikrum;
assign pm_analog_config_ikrum_b = ~pm_analog_config.ikrum;

assign pm_analog_config_ref_csa_in = pm_analog_config.ref_csa_in;
assign pm_analog_config_ref_csa_in_b = ~pm_analog_config.ref_csa_in;

assign pm_analog_config_ref_csa_mid = pm_analog_config.ref_csa_mid;
assign pm_analog_config_ref_csa_mid_b = ~pm_analog_config.ref_csa_mid;

assign pm_analog_config_ref_csa_out = pm_analog_config.ref_csa_out;
assign pm_analog_config_ref_csa_out_b = ~pm_analog_config.ref_csa_out;

assign pm_analog_config_ref_dac = pm_analog_config.ref_dac;
assign pm_analog_config_ref_dac_b = ~pm_analog_config.ref_dac;

assign pm_analog_config_ref_dac_base = pm_analog_config.ref_dac_base;
assign pm_analog_config_ref_dac_base_b = ~pm_analog_config.ref_dac_base;

assign pm_analog_config_ref_dac_krum = pm_analog_config.ref_dac_krum;
assign pm_analog_config_ref_dac_krum_b = ~pm_analog_config.ref_dac_krum;

assign pm_analog_config_shift_high = pm_analog_config.shift_high;
assign pm_analog_config_shift_high_b = ~pm_analog_config.shift_high;

assign pm_analog_config_shift_low = pm_analog_config.shift_low;
assign pm_analog_config_shift_low_b = ~pm_analog_config.shift_low;

assign pm_analog_config_th_high = pm_analog_config.th_high;
assign pm_analog_config_th_high_b = ~pm_analog_config.th_high;

assign pm_analog_config_th_low = pm_analog_config.th_low;
assign pm_analog_config_th_low_b = ~pm_analog_config.th_low;

assign pm_analog_config_vblr = pm_analog_config.vblr;
assign pm_analog_config_vblr_b = ~pm_analog_config.vblr;

assign pm_digital_config_lc_mode = pm_digital_config.lc_mode;
assign pm_digital_config_limit_enable = pm_digital_config.limit_enable;
assign pm_digital_config_num_bit_sel = pm_digital_config.num_bit_sel;
assign pm_digital_config_sample_mode = pm_digital_config.sample_mode;


/**
 * Submodules placement
 */

ibex_top #(
    .PMPEnable(1'b0),
    .PMPGranularity(0),
    .PMPNumRegions(4),
    .MHPMCounterNum(0),
    .MHPMCounterWidth(40),
    .RV32E(1'b0),
    .RV32M(ibex_pkg::RV32MFast),
    .RV32B(ibex_pkg::RV32BNone),
    .RegFile(ibex_pkg::RegFileFPGA),
    .BranchTargetALU(1'b1),
    .WritebackStage(1'b0),
    .ICache(1'b0),
    .ICacheECC(1'b0),
    .BranchPredictor(1'b0),
    .DbgTriggerEn(1'b0),
    .DbgHwBreakNum(1),
    .SecureIbex(1'b0),
    .DmHaltAddr(32'h00000000),
    .DmExceptionAddr(32'h00000000)
) u_ibex_top (
    .clk_i(clk),
    .rst_ni(rst_n),

    .test_en_i(1'b0),
    .ram_cfg_i(10'b0),

    .hart_id_i(32'b0),
    .boot_addr_i(32'h0000_0000),

    .instr_req_o(core_instr_bus.req),
    .instr_gnt_i(core_instr_bus.gnt),
    .instr_rvalid_i(core_instr_bus.rvalid),
    .instr_addr_o(core_instr_bus.addr),
    .instr_rdata_i(core_instr_bus.rdata),
    .instr_rdata_intg_i(core_instr_bus.rdata_intg),
    .instr_err_i(core_instr_bus.err),

    .data_req_o(core_data_bus.req),
    .data_gnt_i(core_data_bus.gnt),
    .data_rvalid_i(core_data_bus.rvalid),
    .data_we_o(core_data_bus.we),
    .data_be_o(core_data_bus.be),
    .data_addr_o(core_data_bus.addr),
    .data_wdata_o(core_data_bus.wdata),
    .data_wdata_intg_o(core_data_bus.wdata_intg),
    .data_rdata_i(core_data_bus.rdata),
    .data_rdata_intg_i(core_data_bus.rdata_intg),
    .data_err_i(core_data_bus.err),

    .irq_software_i(1'b0),
    .irq_timer_i(1'b0),
    .irq_external_i(1'b0),
    .irq_fast_i({11'b0, spi_irq, uart_irq, timer_irq, gpio_irq}),
    .irq_nm_i(1'b0),

    .debug_req_i(1'b0),
    .crash_dump_o(),

    .fetch_enable_i(1'b1),
    .alert_minor_o(),
    .alert_major_o(),
    .core_sleep_o(),

    .scan_rst_ni(1'b1)
);

data_bus_arbiter u_data_bus_arbiter (
    .clk,
    .rst_n,

    .core_data_bus,

    .boot_rom_data_bus,
    .code_ram_data_bus,
    .data_ram_data_bus,

    .gpio_data_bus,
    .iomux_data_bus,
    .pmc_data_bus,
    .spi_data_bus,
    .timer_data_bus,
    .uart_data_bus
);

instr_bus_arbiter u_instr_bus_arbiter (
    .clk,
    .rst_n,

    .core_instr_bus,

    .boot_rom_instr_bus,
    .code_ram_instr_bus
);

memories u_memories (
    .clk,
    .rst_n,

    .boot_rom_data_bus,
    .code_ram_data_bus,
    .data_ram_data_bus,

    .boot_rom_instr_bus,
    .code_ram_instr_bus
);

peripherals u_peripherals (
    .clk,
    .rst_n,

    .gpio_data_bus,
    .pmc_data_bus,
    .spi_data_bus,
    .timer_data_bus,
    .uart_data_bus,

    .gpio_irq,
    .spi_irq,
    .timer_irq,
    .uart_irq,

    .gpio_bus,
    .pmc_bus,
    .spi_bus,
    .uart_bus,

    .pm_ctrl,
    .pm_data,
    .pm_analog_config,
    .pm_digital_config
);

iomux u_iomux (
    .clk,
    .rst_n,

    .data_bus(iomux_data_bus),

    .gpio_bus,
    .pmc_bus,
    .spi_bus,
    .uart_bus,

    .gpio31_out,
    .gpio30_uart_sout_out,
    .gpio29_out,
    .gpio28_spi_mosi_out,
    .gpio27_spi_sck_out,
    .gpio26_spi_ss1_out,
    .gpio25_spi_ss0_out,
    .gpio24_out,
    .gpio23_out,
    .gpio22_out,
    .gpio21_out,
    .gpio20_out,
    .gpio19_out,
    .gpio18_out,
    .gpio17_out,
    .gpio16_out,
    .gpio15_out,
    .gpio14_out,
    .gpio13_out,
    .gpio12_out,
    .gpio11_out,
    .gpio10_out,
    .gpio9_out,
    .gpio8_out,
    .gpio7_out,
    .gpio6_out,
    .gpio5_out,
    .gpio4_out,
    .gpio3_out,
    .gpio2_out,
    .gpio1_out,
    .gpio0_out,

    .gpio31_uart_sin_in,
    .gpio30_in,
    .gpio29_spi_miso_in,
    .gpio28_in,
    .gpio27_in,
    .gpio26_in,
    .gpio25_in,
    .gpio24_pmc_strobe_in,
    .gpio23_pmc_gate_in,
    .gpio22_in,
    .gpio21_in,
    .gpio20_in,
    .gpio19_in,
    .gpio18_in,
    .gpio17_in,
    .gpio16_in,
    .gpio15_in,
    .gpio14_in,
    .gpio13_in,
    .gpio12_in,
    .gpio11_in,
    .gpio10_in,
    .gpio9_in,
    .gpio8_in,
    .gpio7_in,
    .gpio6_in,
    .gpio5_in,
    .gpio4_in,
    .gpio3_in,
    .gpio2_in,
    .gpio1_in,
    .gpio0_in
);

endmodule
