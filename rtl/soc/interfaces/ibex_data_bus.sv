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

interface ibex_data_bus;

logic [31:0] addr, wdata, rdata;
logic [3:0]  be;
logic        req, we, gnt, rvalid, err;

modport master (
    output req,
    output addr,
    output we,
    output be,
    output wdata,
    input  gnt,
    input  rvalid,
    input  err,
    input  rdata
);

modport slave (
    output gnt,
    output rvalid,
    output err,
    output rdata,
    input  req,
    input  addr,
    input  we,
    input  be,
    input  wdata
);

endinterface
