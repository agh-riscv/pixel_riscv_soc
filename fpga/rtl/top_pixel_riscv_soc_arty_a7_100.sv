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

module top_pixel_riscv_soc_arty_a7_100 (
    output logic [3:0] led,
    output logic       sout,
    output logic       led3_g,
    output logic       led2_g,
    output logic       led1_g,
    output logic       led0_g,
    input logic        clk_io,
    input logic        rst_n_io,
    input logic        sw,
    input logic        sin
);


/**
 * Local variables and signals
 */

logic clk, rst_n;
logic ss, sck, mosi, miso;


/**
 * Signals assignments
 */

assign led[2:0] = 3'b0;


/**
 * Submodules placement
 */

pixel_riscv_soc u_pixel_riscv_soc (
    .clk,
    .rst_n,

    .gpio31_out(),
    .gpio30_uart_sout_out(sout),
    .gpio29_out(),
    .gpio28_spi_mosi_out(mosi),
    .gpio27_spi_sck_out(sck),
    .gpio26_spi_ss1_out(led[3]),
    .gpio25_spi_ss0_out(ss),
    .gpio24_out(),
    .gpio23_out(),
    .gpio22_out(),
    .gpio21_out(),
    .gpio20_out(),
    .gpio19_out(),
    .gpio18_out(),
    .gpio17_out(),
    .gpio16_out(),
    .gpio15_out(),
    .gpio14_out(),
    .gpio13_out(),
    .gpio12_out(),
    .gpio11_out(),
    .gpio10_out(),
    .gpio9_out(),
    .gpio8_out(),
    .gpio7_out(),
    .gpio6_out(),
    .gpio5_out(),
    .gpio4_out(),
    .gpio3_out(led3_g),
    .gpio2_out(led2_g),
    .gpio1_out(led1_g),
    .gpio0_out(led0_g),

    .gpio31_uart_sin_in(sin),
    .gpio30_in(1'b0),
    .gpio29_spi_miso_in(miso),
    .gpio28_in(1'b0),
    .gpio27_in(1'b0),
    .gpio26_in(1'b0),
    .gpio25_in(1'b0),
    .gpio24_pmc_strobe_in(sw),
    .gpio23_pmc_gate_in(1'b0),
    .gpio22_in(1'b0),
    .gpio21_in(1'b0),
    .gpio20_in(1'b0),
    .gpio19_in(1'b0),
    .gpio18_in(1'b0),
    .gpio17_in(1'b0),
    .gpio16_in(1'b0),
    .gpio15_in(1'b0),
    .gpio14_in(1'b0),
    .gpio13_in(1'b0),
    .gpio12_in(1'b0),
    .gpio11_in(1'b0),
    .gpio10_in(1'b0),
    .gpio9_in(1'b0),
    .gpio8_in(1'b0),
    .gpio7_in(1'b0),
    .gpio6_in(1'b0),
    .gpio5_in(1'b0),
    .gpio4_in(1'b0),
    .gpio3_in(led3_g),
    .gpio2_in(led2_g),
    .gpio1_in(led1_g),
    .gpio0_in(led0_g),

    .pm_ctrl_store(),
    .pm_ctrl_strobe(),
    .pm_ctrl_gate(),
    .pm_ctrl_sh_b(),
    .pm_ctrl_sh_a(),
    .pm_ctrl_clk_sh(),

    .pm_data_din(),
    .pm_data_dout_a(),
    .pm_data_dout_b(),

    .pm_analog_config_fed_csa(),
    .pm_analog_config_fed_csa_b(),

    .pm_analog_config_idiscr(),
    .pm_analog_config_idiscr_b(),

    .pm_analog_config_ikrum(),
    .pm_analog_config_ikrum_b(),

    .pm_analog_config_ref_csa_in(),
    .pm_analog_config_ref_csa_in_b(),

    .pm_analog_config_ref_csa_mid(),
    .pm_analog_config_ref_csa_mid_b(),

    .pm_analog_config_ref_csa_out(),
    .pm_analog_config_ref_csa_out_b(),

    .pm_analog_config_ref_dac(),
    .pm_analog_config_ref_dac_b(),

    .pm_analog_config_ref_dac_base(),
    .pm_analog_config_ref_dac_base_b(),

    .pm_analog_config_ref_dac_krum(),
    .pm_analog_config_ref_dac_krum_b(),

    .pm_analog_config_shift_high(),
    .pm_analog_config_shift_high_b(),

    .pm_analog_config_shift_low(),
    .pm_analog_config_shift_low_b(),

    .pm_analog_config_th_high(),
    .pm_analog_config_th_high_b(),

    .pm_analog_config_th_low(),
    .pm_analog_config_th_low_b(),

    .pm_analog_config_vblr(),
    .pm_analog_config_vblr_b(),

    .pm_digital_config_lc_mode(),
    .pm_digital_config_limit_enable(),
    .pm_digital_config_num_bit_sel(),
    .pm_digital_config_sample_mode()
);

clkgen_xil7series u_clkgen_xil7series (
    .IO_CLK(clk_io),
    .IO_RST_N(rst_n_io),
    .clk_sys(clk),
    .rst_sys_n(rst_n)
);

spi_flash_memory u_spi_flash_memory (
    .miso,
    .clk,
    .rst_n,
    .ss,
    .sck,
    .mosi
);

endmodule
