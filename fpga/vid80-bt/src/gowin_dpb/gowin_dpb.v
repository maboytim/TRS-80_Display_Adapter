//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Fri Jul 15 21:17:25 2022

module Gowin_DPB (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [7:0] douta;
output [7:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [14:0] ada;
input [7:0] dina;
input [14:0] adb;
input [7:0] dinb;

wire [14:0] dpb_inst_0_douta_w;
wire [0:0] dpb_inst_0_douta;
wire [14:0] dpb_inst_0_doutb_w;
wire [0:0] dpb_inst_0_doutb;
wire [14:0] dpb_inst_1_douta_w;
wire [1:1] dpb_inst_1_douta;
wire [14:0] dpb_inst_1_doutb_w;
wire [1:1] dpb_inst_1_doutb;
wire [14:0] dpb_inst_2_douta_w;
wire [2:2] dpb_inst_2_douta;
wire [14:0] dpb_inst_2_doutb_w;
wire [2:2] dpb_inst_2_doutb;
wire [14:0] dpb_inst_3_douta_w;
wire [3:3] dpb_inst_3_douta;
wire [14:0] dpb_inst_3_doutb_w;
wire [3:3] dpb_inst_3_doutb;
wire [11:0] dpb_inst_4_douta_w;
wire [3:0] dpb_inst_4_douta;
wire [11:0] dpb_inst_4_doutb_w;
wire [3:0] dpb_inst_4_doutb;
wire [14:0] dpb_inst_5_douta_w;
wire [4:4] dpb_inst_5_douta;
wire [14:0] dpb_inst_5_doutb_w;
wire [4:4] dpb_inst_5_doutb;
wire [14:0] dpb_inst_6_douta_w;
wire [5:5] dpb_inst_6_douta;
wire [14:0] dpb_inst_6_doutb_w;
wire [5:5] dpb_inst_6_doutb;
wire [14:0] dpb_inst_7_douta_w;
wire [6:6] dpb_inst_7_douta;
wire [14:0] dpb_inst_7_doutb_w;
wire [6:6] dpb_inst_7_doutb;
wire [14:0] dpb_inst_8_douta_w;
wire [7:7] dpb_inst_8_douta;
wire [14:0] dpb_inst_8_doutb_w;
wire [7:7] dpb_inst_8_doutb;
wire [11:0] dpb_inst_9_douta_w;
wire [7:4] dpb_inst_9_douta;
wire [11:0] dpb_inst_9_doutb_w;
wire [7:4] dpb_inst_9_doutb;
wire dff_q_0;
wire dff_q_1;
wire dff_q_2;
wire dff_q_3;
wire cea_w;
wire ceb_w;
wire gw_gnd;

assign cea_w = ~wrea & cea;
assign ceb_w = ~wreb & ceb;
assign gw_gnd = 1'b0;

DPB dpb_inst_0 (
    .DOA({dpb_inst_0_douta_w[14:0],dpb_inst_0_douta[0]}),
    .DOB({dpb_inst_0_doutb_w[14:0],dpb_inst_0_doutb[0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[0]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[0]})
);

defparam dpb_inst_0.READ_MODE0 = 1'b1;
defparam dpb_inst_0.READ_MODE1 = 1'b1;
defparam dpb_inst_0.WRITE_MODE0 = 2'b00;
defparam dpb_inst_0.WRITE_MODE1 = 2'b00;
defparam dpb_inst_0.BIT_WIDTH_0 = 1;
defparam dpb_inst_0.BIT_WIDTH_1 = 1;
defparam dpb_inst_0.BLK_SEL_0 = 3'b000;
defparam dpb_inst_0.BLK_SEL_1 = 3'b000;
defparam dpb_inst_0.RESET_MODE = "SYNC";

DPB dpb_inst_1 (
    .DOA({dpb_inst_1_douta_w[14:0],dpb_inst_1_douta[1]}),
    .DOB({dpb_inst_1_doutb_w[14:0],dpb_inst_1_doutb[1]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[1]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[1]})
);

defparam dpb_inst_1.READ_MODE0 = 1'b1;
defparam dpb_inst_1.READ_MODE1 = 1'b1;
defparam dpb_inst_1.WRITE_MODE0 = 2'b00;
defparam dpb_inst_1.WRITE_MODE1 = 2'b00;
defparam dpb_inst_1.BIT_WIDTH_0 = 1;
defparam dpb_inst_1.BIT_WIDTH_1 = 1;
defparam dpb_inst_1.BLK_SEL_0 = 3'b000;
defparam dpb_inst_1.BLK_SEL_1 = 3'b000;
defparam dpb_inst_1.RESET_MODE = "SYNC";

DPB dpb_inst_2 (
    .DOA({dpb_inst_2_douta_w[14:0],dpb_inst_2_douta[2]}),
    .DOB({dpb_inst_2_doutb_w[14:0],dpb_inst_2_doutb[2]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[2]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[2]})
);

defparam dpb_inst_2.READ_MODE0 = 1'b1;
defparam dpb_inst_2.READ_MODE1 = 1'b1;
defparam dpb_inst_2.WRITE_MODE0 = 2'b00;
defparam dpb_inst_2.WRITE_MODE1 = 2'b00;
defparam dpb_inst_2.BIT_WIDTH_0 = 1;
defparam dpb_inst_2.BIT_WIDTH_1 = 1;
defparam dpb_inst_2.BLK_SEL_0 = 3'b000;
defparam dpb_inst_2.BLK_SEL_1 = 3'b000;
defparam dpb_inst_2.RESET_MODE = "SYNC";

DPB dpb_inst_3 (
    .DOA({dpb_inst_3_douta_w[14:0],dpb_inst_3_douta[3]}),
    .DOB({dpb_inst_3_doutb_w[14:0],dpb_inst_3_doutb[3]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[3]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[3]})
);

defparam dpb_inst_3.READ_MODE0 = 1'b1;
defparam dpb_inst_3.READ_MODE1 = 1'b1;
defparam dpb_inst_3.WRITE_MODE0 = 2'b00;
defparam dpb_inst_3.WRITE_MODE1 = 2'b00;
defparam dpb_inst_3.BIT_WIDTH_0 = 1;
defparam dpb_inst_3.BIT_WIDTH_1 = 1;
defparam dpb_inst_3.BLK_SEL_0 = 3'b000;
defparam dpb_inst_3.BLK_SEL_1 = 3'b000;
defparam dpb_inst_3.RESET_MODE = "SYNC";

DPB dpb_inst_4 (
    .DOA({dpb_inst_4_douta_w[11:0],dpb_inst_4_douta[3:0]}),
    .DOB({dpb_inst_4_doutb_w[11:0],dpb_inst_4_doutb[3:0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({ada[14],ada[13],ada[12]}),
    .BLKSELB({adb[14],adb[13],adb[12]}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[3:0]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[3:0]})
);

defparam dpb_inst_4.READ_MODE0 = 1'b1;
defparam dpb_inst_4.READ_MODE1 = 1'b1;
defparam dpb_inst_4.WRITE_MODE0 = 2'b00;
defparam dpb_inst_4.WRITE_MODE1 = 2'b00;
defparam dpb_inst_4.BIT_WIDTH_0 = 4;
defparam dpb_inst_4.BIT_WIDTH_1 = 4;
defparam dpb_inst_4.BLK_SEL_0 = 3'b100;
defparam dpb_inst_4.BLK_SEL_1 = 3'b100;
defparam dpb_inst_4.RESET_MODE = "SYNC";

DPB dpb_inst_5 (
    .DOA({dpb_inst_5_douta_w[14:0],dpb_inst_5_douta[4]}),
    .DOB({dpb_inst_5_doutb_w[14:0],dpb_inst_5_doutb[4]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[4]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[4]})
);

defparam dpb_inst_5.READ_MODE0 = 1'b1;
defparam dpb_inst_5.READ_MODE1 = 1'b1;
defparam dpb_inst_5.WRITE_MODE0 = 2'b00;
defparam dpb_inst_5.WRITE_MODE1 = 2'b00;
defparam dpb_inst_5.BIT_WIDTH_0 = 1;
defparam dpb_inst_5.BIT_WIDTH_1 = 1;
defparam dpb_inst_5.BLK_SEL_0 = 3'b000;
defparam dpb_inst_5.BLK_SEL_1 = 3'b000;
defparam dpb_inst_5.RESET_MODE = "SYNC";

DPB dpb_inst_6 (
    .DOA({dpb_inst_6_douta_w[14:0],dpb_inst_6_douta[5]}),
    .DOB({dpb_inst_6_doutb_w[14:0],dpb_inst_6_doutb[5]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[5]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[5]})
);

defparam dpb_inst_6.READ_MODE0 = 1'b1;
defparam dpb_inst_6.READ_MODE1 = 1'b1;
defparam dpb_inst_6.WRITE_MODE0 = 2'b00;
defparam dpb_inst_6.WRITE_MODE1 = 2'b00;
defparam dpb_inst_6.BIT_WIDTH_0 = 1;
defparam dpb_inst_6.BIT_WIDTH_1 = 1;
defparam dpb_inst_6.BLK_SEL_0 = 3'b000;
defparam dpb_inst_6.BLK_SEL_1 = 3'b000;
defparam dpb_inst_6.RESET_MODE = "SYNC";

DPB dpb_inst_7 (
    .DOA({dpb_inst_7_douta_w[14:0],dpb_inst_7_douta[6]}),
    .DOB({dpb_inst_7_doutb_w[14:0],dpb_inst_7_doutb[6]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[6]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[6]})
);

defparam dpb_inst_7.READ_MODE0 = 1'b1;
defparam dpb_inst_7.READ_MODE1 = 1'b1;
defparam dpb_inst_7.WRITE_MODE0 = 2'b00;
defparam dpb_inst_7.WRITE_MODE1 = 2'b00;
defparam dpb_inst_7.BIT_WIDTH_0 = 1;
defparam dpb_inst_7.BIT_WIDTH_1 = 1;
defparam dpb_inst_7.BLK_SEL_0 = 3'b000;
defparam dpb_inst_7.BLK_SEL_1 = 3'b000;
defparam dpb_inst_7.RESET_MODE = "SYNC";

DPB dpb_inst_8 (
    .DOA({dpb_inst_8_douta_w[14:0],dpb_inst_8_douta[7]}),
    .DOB({dpb_inst_8_doutb_w[14:0],dpb_inst_8_doutb[7]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[14]}),
    .ADA(ada[13:0]),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[7]}),
    .ADB(adb[13:0]),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[7]})
);

defparam dpb_inst_8.READ_MODE0 = 1'b1;
defparam dpb_inst_8.READ_MODE1 = 1'b1;
defparam dpb_inst_8.WRITE_MODE0 = 2'b00;
defparam dpb_inst_8.WRITE_MODE1 = 2'b00;
defparam dpb_inst_8.BIT_WIDTH_0 = 1;
defparam dpb_inst_8.BIT_WIDTH_1 = 1;
defparam dpb_inst_8.BLK_SEL_0 = 3'b000;
defparam dpb_inst_8.BLK_SEL_1 = 3'b000;
defparam dpb_inst_8.RESET_MODE = "SYNC";

DPB dpb_inst_9 (
    .DOA({dpb_inst_9_douta_w[11:0],dpb_inst_9_douta[7:4]}),
    .DOB({dpb_inst_9_doutb_w[11:0],dpb_inst_9_doutb[7:4]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({ada[14],ada[13],ada[12]}),
    .BLKSELB({adb[14],adb[13],adb[12]}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[7:4]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[7:4]})
);

defparam dpb_inst_9.READ_MODE0 = 1'b1;
defparam dpb_inst_9.READ_MODE1 = 1'b1;
defparam dpb_inst_9.WRITE_MODE0 = 2'b00;
defparam dpb_inst_9.WRITE_MODE1 = 2'b00;
defparam dpb_inst_9.BIT_WIDTH_0 = 4;
defparam dpb_inst_9.BIT_WIDTH_1 = 4;
defparam dpb_inst_9.BLK_SEL_0 = 3'b100;
defparam dpb_inst_9.BLK_SEL_1 = 3'b100;
defparam dpb_inst_9.RESET_MODE = "SYNC";

DFFE dff_inst_0 (
  .Q(dff_q_0),
  .D(ada[14]),
  .CLK(clka),
  .CE(cea_w)
);
DFFE dff_inst_1 (
  .Q(dff_q_1),
  .D(dff_q_0),
  .CLK(clka),
  .CE(ocea)
);
DFFE dff_inst_2 (
  .Q(dff_q_2),
  .D(adb[14]),
  .CLK(clkb),
  .CE(ceb_w)
);
DFFE dff_inst_3 (
  .Q(dff_q_3),
  .D(dff_q_2),
  .CLK(clkb),
  .CE(oceb)
);
MUX2 mux_inst_4 (
  .O(douta[0]),
  .I0(dpb_inst_0_douta[0]),
  .I1(dpb_inst_4_douta[0]),
  .S0(dff_q_1)
);
MUX2 mux_inst_9 (
  .O(douta[1]),
  .I0(dpb_inst_1_douta[1]),
  .I1(dpb_inst_4_douta[1]),
  .S0(dff_q_1)
);
MUX2 mux_inst_14 (
  .O(douta[2]),
  .I0(dpb_inst_2_douta[2]),
  .I1(dpb_inst_4_douta[2]),
  .S0(dff_q_1)
);
MUX2 mux_inst_19 (
  .O(douta[3]),
  .I0(dpb_inst_3_douta[3]),
  .I1(dpb_inst_4_douta[3]),
  .S0(dff_q_1)
);
MUX2 mux_inst_24 (
  .O(douta[4]),
  .I0(dpb_inst_5_douta[4]),
  .I1(dpb_inst_9_douta[4]),
  .S0(dff_q_1)
);
MUX2 mux_inst_29 (
  .O(douta[5]),
  .I0(dpb_inst_6_douta[5]),
  .I1(dpb_inst_9_douta[5]),
  .S0(dff_q_1)
);
MUX2 mux_inst_34 (
  .O(douta[6]),
  .I0(dpb_inst_7_douta[6]),
  .I1(dpb_inst_9_douta[6]),
  .S0(dff_q_1)
);
MUX2 mux_inst_39 (
  .O(douta[7]),
  .I0(dpb_inst_8_douta[7]),
  .I1(dpb_inst_9_douta[7]),
  .S0(dff_q_1)
);
MUX2 mux_inst_44 (
  .O(doutb[0]),
  .I0(dpb_inst_0_doutb[0]),
  .I1(dpb_inst_4_doutb[0]),
  .S0(dff_q_3)
);
MUX2 mux_inst_49 (
  .O(doutb[1]),
  .I0(dpb_inst_1_doutb[1]),
  .I1(dpb_inst_4_doutb[1]),
  .S0(dff_q_3)
);
MUX2 mux_inst_54 (
  .O(doutb[2]),
  .I0(dpb_inst_2_doutb[2]),
  .I1(dpb_inst_4_doutb[2]),
  .S0(dff_q_3)
);
MUX2 mux_inst_59 (
  .O(doutb[3]),
  .I0(dpb_inst_3_doutb[3]),
  .I1(dpb_inst_4_doutb[3]),
  .S0(dff_q_3)
);
MUX2 mux_inst_64 (
  .O(doutb[4]),
  .I0(dpb_inst_5_doutb[4]),
  .I1(dpb_inst_9_doutb[4]),
  .S0(dff_q_3)
);
MUX2 mux_inst_69 (
  .O(doutb[5]),
  .I0(dpb_inst_6_doutb[5]),
  .I1(dpb_inst_9_doutb[5]),
  .S0(dff_q_3)
);
MUX2 mux_inst_74 (
  .O(doutb[6]),
  .I0(dpb_inst_7_doutb[6]),
  .I1(dpb_inst_9_doutb[6]),
  .S0(dff_q_3)
);
MUX2 mux_inst_79 (
  .O(doutb[7]),
  .I0(dpb_inst_8_doutb[7]),
  .I1(dpb_inst_9_doutb[7]),
  .S0(dff_q_3)
);
endmodule //Gowin_DPB
