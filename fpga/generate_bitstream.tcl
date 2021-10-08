# Copyright (C) 2021  AGH University of Science and Technology
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

set target [lindex $argv 0]
set part xc7a100tcsg324-1
set top_module top_pixel_riscv_soc_arty_a7_100

create_project pixel_riscv_soc build -part ${part} -force

read_verilog -sv {
    ../deps/ibex/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh
    ../deps/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv
    ../deps/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv

    ../deps/ibex/rtl/ibex_pkg.sv
    ../deps/ibex/rtl/ibex_alu.sv
    ../deps/ibex/rtl/ibex_compressed_decoder.sv
    ../deps/ibex/rtl/ibex_controller.sv
    ../deps/ibex/rtl/ibex_core.sv
    ../deps/ibex/rtl/ibex_counter.sv
    ../deps/ibex/rtl/ibex_csr.sv
    ../deps/ibex/rtl/ibex_cs_registers.sv
    ../deps/ibex/rtl/ibex_decoder.sv
    ../deps/ibex/rtl/ibex_dummy_instr.sv
    ../deps/ibex/rtl/ibex_ex_block.sv
    ../deps/ibex/rtl/ibex_fetch_fifo.sv
    ../deps/ibex/rtl/ibex_icache.sv
    ../deps/ibex/rtl/ibex_id_stage.sv
    ../deps/ibex/rtl/ibex_if_stage.sv
    ../deps/ibex/rtl/ibex_load_store_unit.sv
    ../deps/ibex/rtl/ibex_multdiv_fast.sv
    ../deps/ibex/rtl/ibex_pmp.sv
    ../deps/ibex/rtl/ibex_prefetch_buffer.sv
    ../deps/ibex/rtl/ibex_register_file_fpga.sv
    ../deps/ibex/rtl/ibex_top.sv
    ../deps/ibex/rtl/ibex_wb_stage.sv

    ../rtl/misc/spi_flash_memory/spi_flash_memory.sv
    ../rtl/misc/spi_flash_memory/spi_mem.sv
    ../rtl/misc/spi_flash_memory/spi_slave.sv

    ../rtl/soc/gpio/gpio_pkg.sv
    ../rtl/soc/gpio/gpio_interrupt_detector.sv
    ../rtl/soc/gpio/gpio.sv

    ../rtl/soc/interfaces/ibex_data_bus.sv
    ../rtl/soc/interfaces/ibex_instr_bus.sv
    ../rtl/soc/interfaces/soc_gpio_bus.sv
    ../rtl/soc/interfaces/soc_pm_analog_config.sv
    ../rtl/soc/interfaces/soc_pm_ctrl.sv
    ../rtl/soc/interfaces/soc_pm_data.sv
    ../rtl/soc/interfaces/soc_pm_digital_config.sv
    ../rtl/soc/interfaces/soc_spi_bus.sv
    ../rtl/soc/interfaces/soc_timer_bus.sv
    ../rtl/soc/interfaces/soc_uart_bus.sv

    ../rtl/soc/memories/fpga/ram.sv
    ../rtl/soc/memories/boot_mem.sv
    ../rtl/soc/memories/boot_rom.sv
    ../rtl/soc/memories/code_ram.sv
    ../rtl/soc/memories/data_ram.sv

    ../rtl/soc/misc/edge_detector.sv
    ../rtl/soc/misc/serial_clock_generator.sv

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
    ../rtl/soc/pmc/pmc_receiver.sv
    ../rtl/soc/pmc/pmc_transmitter.sv
    ../rtl/soc/pmc/pmc.sv

    ../rtl/soc/spi/spi_pkg.sv
    ../rtl/soc/spi/spi_master.sv
    ../rtl/soc/spi/spi.sv

    ../rtl/soc/timer/timer_pkg.sv
    ../rtl/soc/timer/timer_core.sv
    ../rtl/soc/timer/timer.sv

    ../rtl/soc/uart/uart_pkg.sv
    ../rtl/soc/uart/uart_receiver.sv
    ../rtl/soc/uart/uart_transmitter.sv
    ../rtl/soc/uart/uart.sv

    ../rtl/soc/pixel_riscv_soc_pkg.sv
    ../rtl/soc/data_bus_arbiter.sv
    ../rtl/soc/instr_bus_arbiter.sv
    ../rtl/soc/peripherals.sv
    ../rtl/soc/pixel_riscv_soc.sv

    rtl/clkgen_xil7series.sv
    rtl/prim_clock_gating.sv
    rtl/top_pixel_riscv_soc_arty_a7_100.sv
}

read_xdc constraints/arty_a7_100.xdc

set_property file_type "Verilog Header" [get_files [list \
    ../deps/ibex/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh \
    ../deps/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv \
]]

set_property top ${top_module} [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
exit
