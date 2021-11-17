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
    input logic                  clk,
    input logic                  rst_n,

    soc_gpio_bus.master          gpio_bus,
    soc_pmc_bus.master           pmc_bus,
    soc_spi_bus.master           spi_bus,
    soc_uart_bus.master          uart_bus,

    soc_pm_ctrl.master           pm_ctrl,
    soc_pm_data.master           pm_data,
    soc_pm_analog_config.master  pm_analog_config,
    soc_pm_digital_config.master pm_digital_config
);


/**
 * Local variables and signals
 */

ibex_data_bus  core_data_bus ();
ibex_instr_bus core_instr_bus ();

ibex_data_bus  boot_rom_data_bus ();
ibex_data_bus  code_ram_data_bus ();
ibex_data_bus  data_ram_data_bus ();

ibex_data_bus  gpio_data_bus ();
ibex_data_bus  pmc_data_bus ();
ibex_data_bus  spi_data_bus ();
ibex_data_bus  timer_data_bus ();
ibex_data_bus  uart_data_bus ();

ibex_instr_bus boot_rom_instr_bus ();
ibex_instr_bus code_ram_instr_bus ();

soc_timer_bus  timer_bus ();


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
    .RV32B(ibex_pkg::RV32BFull),
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
    .irq_fast_i({13'b0, timer_bus.irq, gpio_bus.irq}),
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

    .gpio_bus,
    .pmc_bus,
    .spi_bus,
    .timer_bus,
    .uart_bus,

    .pm_ctrl,
    .pm_data,
    .pm_analog_config,
    .pm_digital_config
);

endmodule
