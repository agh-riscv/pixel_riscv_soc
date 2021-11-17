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

interface soc_pmc_pm_ctrl;

logic [9:0] res;
logic       store, strobe, gate, sh_b, sh_a, clk_sh;

modport master (
    output res,
    output store,
    output strobe,
    output gate,
    output sh_b,
    output sh_a,
    output clk_sh
);

modport slave (
    input res,
    input store,
    input strobe,
    input gate,
    input sh_b,
    input sh_a,
    input clk_sh
);

endinterface
