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

logic [23:0] res;   /* digital_config[31:8]:  the reserved bits */
logic [7:0]  th;    /* digital_config[7:0]:   the threshold */

modport master (
    output res,
    output th
);

modport slave (
    input res,
    input th
);

endinterface
