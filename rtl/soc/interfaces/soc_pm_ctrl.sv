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

interface soc_pm_ctrl;

logic [9:0] res;        /* ctrl[15:6]:  the reserved bits */
logic       write_cfg;  /* ctrl[5]:     latch configuration into the pixel config registers (copy from shift register) */
logic       strobe;     /* ctrl[4]:     increment all counters in the pixels that are not masked */
logic       gate;       /* ctrl[3]:     gate for registration of the hits in the pixel; when closed (1->0) a new */
                        /*              random value appears in the counter; this works only if shA == 0; */
logic       shB;        /* ctrl[2]:     not used */
logic       shA;        /* ctrl[1]:     mode select for the pixel counters/registers, when: */
                        /*                  shA == 0; pixel operates in the counter mode */
                        /*                  shA == 1; pixel operates in the shift mode */
logic       clkSh;      /* ctrl[0]:     clock for shifting the pixel counters/registers, works only if shA == 1 */

modport master (
    output res,
    output write_cfg,
    output strobe,
    output gate,
    output shB,
    output shA,
    output clkSh
);

modport slave (
    input res,
    input write_cfg,
    input strobe,
    input gate,
    input shB,
    input shA,
    input clkSh
);

endinterface
