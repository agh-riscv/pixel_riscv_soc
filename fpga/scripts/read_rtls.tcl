# Copyright (C) 2020  AGH University of Science and Technology
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Ibex RTL files
read_verilog -sv {
    ../ibex/vendor/lowrisc_ip/prim/rtl/prim_assert.sv
    ../ibex/rtl/ibex_pkg.sv
    ../ibex/rtl/ibex_alu.sv
    ../ibex/rtl/ibex_compressed_decoder.sv
    ../ibex/rtl/ibex_controller.sv
    ../ibex/rtl/ibex_core.sv
    ../ibex/rtl/ibex_counter.sv
    ../ibex/rtl/ibex_cs_registers.sv
    ../ibex/rtl/ibex_decoder.sv
    ../ibex/rtl/ibex_dummy_instr.sv
    ../ibex/rtl/ibex_ex_block.sv
    ../ibex/rtl/ibex_fetch_fifo.sv
    ../ibex/rtl/ibex_icache.sv
    ../ibex/rtl/ibex_id_stage.sv
    ../ibex/rtl/ibex_if_stage.sv
    ../ibex/rtl/ibex_load_store_unit.sv
    ../ibex/rtl/ibex_multdiv_fast.sv
    ../ibex/rtl/ibex_pmp.sv
    ../ibex/rtl/ibex_prefetch_buffer.sv
    ../ibex/rtl/ibex_register_file_fpga.sv
    ../ibex/rtl/ibex_wb_stage.sv
}

set_property file_type "Verilog Header" [get_files ../ibex/vendor/lowrisc_ip/prim/rtl/prim_assert.sv]

# Miscellaneous RTL files
read_verilog -sv {
    ../rtl/misc/spi_flash_memory/spi_flash_memory.sv
    ../rtl/misc/spi_flash_memory/spi_mem.sv
    ../rtl/misc/spi_flash_memory/spi_slave.sv
}

# SoC RTL files
read_verilog -sv {
    ../rtl/soc/common/ibex_data_bus.sv
    ../rtl/soc/common/ibex_instr_bus.sv
    ../rtl/soc/common/rxd_pkg.sv

    ../rtl/soc/gpio/gpio_pkg.sv
    ../rtl/soc/gpio/gpio_interrupt_detector.sv
    ../rtl/soc/gpio/gpio_offset_decoder.sv
    ../rtl/soc/gpio/gpio.sv

    ../rtl/soc/memories/fpga/ram.sv
    ../rtl/soc/memories/boot_mem.sv
    ../rtl/soc/memories/boot_rom.sv
    ../rtl/soc/memories/code_ram.sv
    ../rtl/soc/memories/data_ram.sv

    ../rtl/soc/misc/edge_detector.sv
    ../rtl/soc/misc/serial_clock_generator.sv

    ../rtl/soc/pmc/analog_conf/pmc_analog_conf.sv
    ../rtl/soc/pmc/analog_conf/pmc_ac_pkg.sv
    ../rtl/soc/pmc/analog_conf/pmc_ac_offset_decoder.sv
    ../rtl/soc/pmc/analog_conf/pmc_ac.sv

    ../rtl/soc/pmc/digital_conf/pmc_digital_conf.sv
    ../rtl/soc/pmc/digital_conf/pmc_dc_pkg.sv
    ../rtl/soc/pmc/digital_conf/pmc_dc_offset_decoder.sv
    ../rtl/soc/pmc/digital_conf/pmc_dc.sv

    ../rtl/soc/pmc/coprocessor/pmcc_pkg.sv
    ../rtl/soc/pmc/coprocessor/pmcc_instr_decoder.sv
    ../rtl/soc/pmc/coprocessor/pmcc_loop_controller.sv
    ../rtl/soc/pmc/coprocessor/pmcc_loop_lifo.sv
    ../rtl/soc/pmc/coprocessor/pmcc_matrix_controller.sv
    ../rtl/soc/pmc/coprocessor/pmcc_wait_controller.sv
    ../rtl/soc/pmc/coprocessor/pmcc.sv

    ../rtl/soc/pmc/memories/fpga/pmcc_dpram.sv
    ../rtl/soc/pmc/memories/pmcc_code_ram.sv

    ../rtl/soc/pmc/pmc_pkg.sv
    ../rtl/soc/pmc/pmc_ctrl.sv
    ../rtl/soc/pmc/pmc_offset_decoder.sv
    ../rtl/soc/pmc/pmc.sv

    ../rtl/soc/spi/spi_pkg.sv
    ../rtl/soc/spi/spi_offset_decoder.sv
    ../rtl/soc/spi/spi_master.sv
    ../rtl/soc/spi/spi.sv

    ../rtl/soc/tmr/timer.sv
    ../rtl/soc/tmr/tmr_pkg.sv
    ../rtl/soc/tmr/tmr_offset_decoder.sv
    ../rtl/soc/tmr/tmr.sv

    ../rtl/soc/uart/uart_pkg.sv
    ../rtl/soc/uart/uart_offset_decoder.sv
    ../rtl/soc/uart/uart_receiver.sv
    ../rtl/soc/uart/uart_transmitter.sv
    ../rtl/soc/uart/uart.sv

    ../rtl/soc/data_bus_arbiter.sv
    ../rtl/soc/instr_bus_arbiter.sv
    ../rtl/soc/peripherals.sv
    ../rtl/soc/pixel_riscv_soc.sv
}

# FPGA specific RTL files
read_verilog -sv {
    rtl/clkgen_xil7series.sv
    rtl/prim_clock_gating.sv
}
