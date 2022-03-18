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

interface soc_pm_digital_config;

logic [25:0] res;
logic [2:0]  num_bit_sel;
logic        lc_mode, limit_enable, sample_mode;

modport master (
    output res,
    output num_bit_sel,
    output lc_mode,
    output limit_enable,
    output sample_mode
);

modport slave (
    input res,
    input num_bit_sel,
    input lc_mode,
    input limit_enable,
    input sample_mode
);

endinterface
