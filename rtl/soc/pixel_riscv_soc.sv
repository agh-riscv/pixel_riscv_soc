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

import ibex_pkg::*;

module pixel_riscv_soc (
    output logic [31:0] gpio_out,
    output logic        ss,
    output logic        sck,
    output logic        mosi,
    output logic        sout,
    output logic [63:0] pm_din,
    input logic         clk,
    input logic         rst_n,
    input logic [31:0]  gpio_in,
    input logic         miso,
    input logic         sin,
    input logic [63:0]  pm_dout,

    pmc_ctrl.master         ctrl,
    pmc_analog_conf.master  analog_conf,
    pmc_digital_conf.master digital_conf
);


/**
 * Local parameters
 */

parameter logic [31:0] BOOT_ROM_ADDRESS = 32'h0000_0000;


/**
 * Local variables and signals
 */

ibex_instr_bus instr_bus();
ibex_data_bus  data_bus();

logic [14:0] irq_fast;
logic        tmr_irq, gpio_irq;


/**
 * Signals assignments
 */

assign irq_fast[14:2] = 13'b0;
assign irq_fast[1] = tmr_irq;
assign irq_fast[0] = gpio_irq;


/**
 * Submodules placement
 */

ibex_core #(
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
    .SecureIbex(1'b0),
    .DmHaltAddr(32'h00000000),
    .DmExceptionAddr(32'h00000000)
) u_core (
    .clk_i(clk),
    .rst_ni(rst_n),
    .test_en_i(1'b0),

    .hart_id_i(32'b0),
    .boot_addr_i(BOOT_ROM_ADDRESS),

    .instr_req_o(instr_bus.req),
    .instr_gnt_i(instr_bus.gnt),
    .instr_rvalid_i(instr_bus.rvalid),
    .instr_addr_o(instr_bus.addr),
    .instr_rdata_i(instr_bus.rdata),
    .instr_err_i(instr_bus.err),

    .data_req_o(data_bus.req),
    .data_gnt_i(data_bus.gnt),
    .data_rvalid_i(data_bus.rvalid),
    .data_we_o(data_bus.we),
    .data_be_o(data_bus.be),
    .data_addr_o(data_bus.addr),
    .data_wdata_o(data_bus.wdata),
    .data_rdata_i(data_bus.rdata),
    .data_err_i(data_bus.err),

    .irq_software_i(1'b0),
    .irq_timer_i(1'b0),
    .irq_external_i(1'b0),
    .irq_fast_i(irq_fast),
    .irq_nm_i(1'b0),

    .debug_req_i(1'b0),

    .fetch_enable_i(1'b1),
    .alert_minor_o(),
    .alert_major_o(),
    .core_sleep_o()
);

peripherals u_peripherals (
    .tmr_irq,
    .gpio_irq,
    .gpio_out,
    .ss,
    .sck,
    .mosi,
    .sout,
    .pm_din,
    .clk,
    .rst_n,
    .gpio_in,
    .miso,
    .sin,
    .pm_dout,

    .instr_bus,
    .data_bus,
    .ctrl,
    .analog_conf,
    .digital_conf
);

endmodule
