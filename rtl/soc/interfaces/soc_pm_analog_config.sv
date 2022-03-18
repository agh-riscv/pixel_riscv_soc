/**
 * Copyright (C) 2021  AGH University of Science and Technology
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

interface soc_pm_analog_config;

logic [37:0] res;
logic [7:0]  th_high, th_low;
logic [6:0]  ikrum, vblr;
logic [5:0]  fed_csa, idiscr, ref_csa_in, ref_csa_mid, ref_csa_out, ref_dac, ref_dac_base,
             ref_dac_krum, shift_high, shift_low;

modport master (
    output fed_csa,
    output idiscr,
    output ikrum,
    output ref_csa_in,
    output ref_csa_mid,
    output ref_csa_out,
    output ref_dac,
    output ref_dac_base,
    output ref_dac_krum,
    output shift_high,
    output shift_low,
    output th_high,
    output th_low,
    output vblr,
    output res
);

modport slave (
    input fed_csa,
    input idiscr,
    input ikrum,
    input ref_csa_in,
    input ref_csa_mid,
    input ref_csa_out,
    input ref_dac,
    input ref_dac_base,
    input ref_dac_krum,
    input shift_high,
    input shift_low,
    input th_high,
    input th_low,
    input vblr,
    input res
);

endinterface
