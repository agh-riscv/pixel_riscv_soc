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

interface soc_spi_bus;

logic ss0, ss1, sck, mosi, miso;

modport master (
    output ss0,
    output ss1,
    output sck,
    output mosi,
    input  miso
);

modport slave (
    output miso,
    input  ss0,
    input  ss1,
    input  sck,
    input  mosi
);

endinterface
