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

module boot_mem (
    output logic [31:0] rdata,
    input logic [31:0] addr
);

/**
 * Module internal logic
 */

always_comb begin
    case (addr[13:2])
           0:    rdata = 32'h0f60006f;
           1:    rdata = 32'h0f20006f;
           2:    rdata = 32'h0ee0006f;
           3:    rdata = 32'h0ea0006f;
           4:    rdata = 32'h0e60006f;
           5:    rdata = 32'h0e20006f;
           6:    rdata = 32'h0de0006f;
           7:    rdata = 32'h0da0006f;
           8:    rdata = 32'h0d60006f;
           9:    rdata = 32'h0d20006f;
          10:    rdata = 32'h0ce0006f;
          11:    rdata = 32'h0ca0006f;
          12:    rdata = 32'h0c60006f;
          13:    rdata = 32'h0c20006f;
          14:    rdata = 32'h0be0006f;
          15:    rdata = 32'h0ba0006f;
          16:    rdata = 32'h0b60006f;
          17:    rdata = 32'h0b20006f;
          18:    rdata = 32'h0ae0006f;
          19:    rdata = 32'h0aa0006f;
          20:    rdata = 32'h0a60006f;
          21:    rdata = 32'h0a20006f;
          22:    rdata = 32'h09e0006f;
          23:    rdata = 32'h09a0006f;
          24:    rdata = 32'h0960006f;
          25:    rdata = 32'h0920006f;
          26:    rdata = 32'h08e0006f;
          27:    rdata = 32'h08a0006f;
          28:    rdata = 32'h0860006f;
          29:    rdata = 32'h0820006f;
          30:    rdata = 32'h07e0006f;
          31:    rdata = 32'h07a0006f;
          32:    rdata = 32'h07a0006f;
          33:    rdata = 32'h0720006f;
          34:    rdata = 32'h06e0006f;
          35:    rdata = 32'hc4221141;
          36:    rdata = 32'hc04ac226;
          37:    rdata = 32'h17b7c606;
          38:    rdata = 32'h43980100;
          39:    rdata = 32'h69414401;
          40:    rdata = 32'h00176713;
          41:    rdata = 32'h470dc398;
          42:    rdata = 32'h00e78823;
          43:    rdata = 32'h2a256491;
          44:    rdata = 32'h008907b3;
          45:    rdata = 32'h00a78023;
          46:    rdata = 32'h1ae30405;
          47:    rdata = 32'h40b2fe94;
          48:    rdata = 32'h44924422;
          49:    rdata = 32'h01414902;
          50:    rdata = 32'h11418082;
          51:    rdata = 32'hc226c422;
          52:    rdata = 32'hc606c04a;
          53:    rdata = 32'h69414401;
          54:    rdata = 32'h2abd6491;
          55:    rdata = 32'h008907b3;
          56:    rdata = 32'h00a78023;
          57:    rdata = 32'h1ae30405;
          58:    rdata = 32'h40b2fe94;
          59:    rdata = 32'h44924422;
          60:    rdata = 32'h01414902;
          61:    rdata = 32'h006f8082;
          62:    rdata = 32'h00930000;
          63:    rdata = 32'h01130000;
          64:    rdata = 32'h01930000;
          65:    rdata = 32'h02130000;
          66:    rdata = 32'h02930000;
          67:    rdata = 32'h03130000;
          68:    rdata = 32'h03930000;
          69:    rdata = 32'h04130000;
          70:    rdata = 32'h04930000;
          71:    rdata = 32'h05130000;
          72:    rdata = 32'h05930000;
          73:    rdata = 32'h06130000;
          74:    rdata = 32'h06930000;
          75:    rdata = 32'h07130000;
          76:    rdata = 32'h07930000;
          77:    rdata = 32'h08130000;
          78:    rdata = 32'h08930000;
          79:    rdata = 32'h09130000;
          80:    rdata = 32'h09930000;
          81:    rdata = 32'h0a130000;
          82:    rdata = 32'h0a930000;
          83:    rdata = 32'h0b130000;
          84:    rdata = 32'h0b930000;
          85:    rdata = 32'h0c130000;
          86:    rdata = 32'h0c930000;
          87:    rdata = 32'h0d130000;
          88:    rdata = 32'h0d930000;
          89:    rdata = 32'h0e130000;
          90:    rdata = 32'h0e930000;
          91:    rdata = 32'h0f130000;
          92:    rdata = 32'h0f930000;
          93:    rdata = 32'h41170000;
          94:    rdata = 32'h01130010;
          95:    rdata = 32'h0297e8a1;
          96:    rdata = 32'h82930010;
          97:    rdata = 32'h0317e822;
          98:    rdata = 32'h03130010;
          99:    rdata = 32'hd863e7a3;
         100:    rdata = 32'ha0230062;
         101:    rdata = 32'h82930002;
         102:    rdata = 32'h5ce30042;
         103:    rdata = 32'h0293fe53;
         104:    rdata = 32'h03173ec0;
         105:    rdata = 32'h03130010;
         106:    rdata = 32'h0397e5e3;
         107:    rdata = 32'h83930010;
         108:    rdata = 32'h5c63e563;
         109:    rdata = 32'hae030073;
         110:    rdata = 32'h20230002;
         111:    rdata = 32'h829301c3;
         112:    rdata = 32'h03130042;
         113:    rdata = 32'hd8e30043;
         114:    rdata = 32'h0513fe63;
         115:    rdata = 32'h05930000;
         116:    rdata = 32'h00ef0000;
         117:    rdata = 32'h07b71140;
         118:    rdata = 32'h47980100;
         119:    rdata = 32'h8de98db9;
         120:    rdata = 32'hc78c8db9;
         121:    rdata = 32'h17b78082;
         122:    rdata = 32'h84230100;
         123:    rdata = 32'h17370007;
         124:    rdata = 32'h435c0100;
         125:    rdata = 32'hdff58b85;
         126:    rdata = 32'h00c74503;
         127:    rdata = 32'h0ff57513;
         128:    rdata = 32'h11018082;
         129:    rdata = 32'hca26cc22;
         130:    rdata = 32'h4401ce06;
         131:    rdata = 32'h3fe14491;
         132:    rdata = 32'h97a2007c;
         133:    rdata = 32'h00a78023;
         134:    rdata = 32'h1ae30405;
         135:    rdata = 32'h40f2fe94;
         136:    rdata = 32'h45324462;
         137:    rdata = 32'h610544d2;
         138:    rdata = 32'h17b78082;
         139:    rdata = 32'h84230100;
         140:    rdata = 32'h173700a7;
         141:    rdata = 32'h435c0100;
         142:    rdata = 32'h4817d793;
         143:    rdata = 32'h4783ffed;
         144:    rdata = 32'h808200c7;
         145:    rdata = 32'h010027b7;
         146:    rdata = 32'h88234719;
         147:    rdata = 32'h439800e7;
         148:    rdata = 32'h00176713;
         149:    rdata = 32'h8082c398;
         150:    rdata = 32'h01002737;
         151:    rdata = 32'h8b85435c;
         152:    rdata = 32'h4503dff5;
         153:    rdata = 32'h751300c7;
         154:    rdata = 32'h80820ff5;
         155:    rdata = 32'hcc221101;
         156:    rdata = 32'hc84aca26;
         157:    rdata = 32'hce06c452;
         158:    rdata = 32'h892ac64e;
         159:    rdata = 32'h440184ae;
         160:    rdata = 32'h44634a29;
         161:    rdata = 32'h45050094;
         162:    rdata = 32'h09b3a819;
         163:    rdata = 32'h37e90089;
         164:    rdata = 32'h00a98023;
         165:    rdata = 32'h01451d63;
         166:    rdata = 32'h00098023;
         167:    rdata = 32'h40f24501;
         168:    rdata = 32'h44d24462;
         169:    rdata = 32'h49b24942;
         170:    rdata = 32'h61054a22;
         171:    rdata = 32'h04058082;
         172:    rdata = 32'h27b7bfc9;
         173:    rdata = 32'h84230100;
         174:    rdata = 32'h273700a7;
         175:    rdata = 32'h435c0100;
         176:    rdata = 32'h4817d793;
         177:    rdata = 32'h8082ffed;
         178:    rdata = 32'hc4221141;
         179:    rdata = 32'h842ac606;
         180:    rdata = 32'h00044503;
         181:    rdata = 32'h4422e511;
         182:    rdata = 32'h452940b2;
         183:    rdata = 32'hbfd10141;
         184:    rdata = 32'h3fc10405;
         185:    rdata = 32'h1141b7f5;
         186:    rdata = 32'h3fa9c606;
         187:    rdata = 32'h00000517;
         188:    rdata = 32'h08050513;
         189:    rdata = 32'h07b73fd1;
         190:    rdata = 32'h47d80100;
         191:    rdata = 32'h00000517;
         192:    rdata = 32'h08450513;
         193:    rdata = 32'h00e71693;
         194:    rdata = 32'h0206c163;
         195:    rdata = 32'h971347dc;
         196:    rdata = 32'h5e6300f7;
         197:    rdata = 32'h05170207;
         198:    rdata = 32'h05130000;
         199:    rdata = 32'h376d07e5;
         200:    rdata = 32'h0517336d;
         201:    rdata = 32'h05130000;
         202:    rdata = 32'h3f790a25;
         203:    rdata = 32'h92f362c1;
         204:    rdata = 32'h05173052;
         205:    rdata = 32'h05130000;
         206:    rdata = 32'h37790a65;
         207:    rdata = 32'h652165a1;
         208:    rdata = 32'hf06f3d59;
         209:    rdata = 32'h40b253f0;
         210:    rdata = 32'h01414501;
         211:    rdata = 32'h05178082;
         212:    rdata = 32'h05130000;
         213:    rdata = 32'h3f8d05e5;
         214:    rdata = 32'hb7e13b15;
         215:    rdata = 32'h00000000;
         216:    rdata = 32'h00000000;
         217:    rdata = 32'h00000000;
         218:    rdata = 32'h00000000;
         219:    rdata = 32'h746f6f62;
         220:    rdata = 32'h64616f6c;
         221:    rdata = 32'h73207265;
         222:    rdata = 32'h74726174;
         223:    rdata = 32'h00006465;
         224:    rdata = 32'h65646f63;
         225:    rdata = 32'h64616f6c;
         226:    rdata = 32'h696b7320;
         227:    rdata = 32'h64657070;
         228:    rdata = 32'h00000000;
         229:    rdata = 32'h65646f63;
         230:    rdata = 32'h64616f6c;
         231:    rdata = 32'h756f7320;
         232:    rdata = 32'h3a656372;
         233:    rdata = 32'h72617520;
         234:    rdata = 32'h00000074;
         235:    rdata = 32'h65646f63;
         236:    rdata = 32'h64616f6c;
         237:    rdata = 32'h756f7320;
         238:    rdata = 32'h3a656372;
         239:    rdata = 32'h69707320;
         240:    rdata = 32'h00000000;
         241:    rdata = 32'h65646f63;
         242:    rdata = 32'h64616f6c;
         243:    rdata = 32'h6e696620;
         244:    rdata = 32'h65687369;
         245:    rdata = 32'h00000064;
         246:    rdata = 32'h746f6f62;
         247:    rdata = 32'h64616f6c;
         248:    rdata = 32'h66207265;
         249:    rdata = 32'h73696e69;
         250:    rdata = 32'h00646568;
        default: rdata = 32'h00000000;
    endcase
end
endmodule
