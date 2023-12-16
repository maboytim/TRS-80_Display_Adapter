`timescale 1ns / 1ps

module top(
   input clk_in,
   input [1:0] sw,
   output [5:0] led,
   output uart_tx,
   input uart_rx,
   input vsync_in,
   input pixel_in,
   input hsync_in,
   output gpio_28,
   output gpio_29,
   output gpio_30,
   output gpio_33,
   output gpio_34,
   output gpio_40,
   input test_in,

   // HDMI
   output [2:0] tmds_p,
   output [2:0] tmds_n,
   output tmds_clock_p,
   output tmds_clock_n
);

//wire mode80 = test_in;


// 126MHz clock
wire vgaclk_x5;

Gowin_rPLL vgaclkpll(
   .clkout(vgaclk_x5), //output clkout
   .clkin(clk_in)     //input clkin
);

// 25.2MHz clock
wire vgaclk;

Gowin_CLKDIV clkdiv(
  .clkout(vgaclk),    //output clkout
  .hclkin(vgaclk_x5), //input hclkin
  .resetn(1'b1)       //input resetn
);

//=================================================================================

// The hsync pulse is 64 dotclocks wide in both 64 and 80 column modes but
// since the dotclocks are different frequencies the width is 6.3uSec in 64
// column and 5uSec in 80 column mode.  Measure the hsync pules width and
// compare to the mid value to select 64 or 80 column mode.

reg [1:0] mode_hsync_in_dly;
reg [7:0] mode_hsync_cnt;
reg mode80;

always @ (posedge vgaclk)
begin
   mode_hsync_in_dly <= { mode_hsync_in_dly[0], hsync_in }; // no glitch suppression
   //mode_hsync_in_dly  <= { mode_hsync_in_dly[0] , (^mode_hsync_in_dly ) ? mode_hsync_in_dly[0] : hsync_in }; // glitch suppression

   if(mode_hsync_in_dly == 2'b01) // rising edge
      mode_hsync_cnt <= -8'd142;
   else
      mode_hsync_cnt <= mode_hsync_cnt + 8'd1;
   if(mode_hsync_in_dly == 2'b10) // falling edge
      mode80 <= mode_hsync_cnt[7];
end

assign led[0] = ~mode80;

//-----HDMI------------------------------------------------------------------------

logic vga_rgb;

//pll pll(.c0(clk_pixel_x5), .c1(clk_pixel), .c2(clk_audio));

logic [15:0] audio_sample_word [1:0] = '{16'd0, 16'd0};

logic [23:0] rgb = 24'd0;
logic [23:0] rgb_screen_color = 24'hffffff;  // White
//logic [23:0] rgb_screen_color = 24'h33ff33;  // Green - from trs-io {51, 255, 51}
//logic [23:0] rgb_screen_color = 24'hffb100;  // Amber - from trs-io {255, 177, 0}}
logic [9:0] cx, frame_width, screen_width;
logic [9:0] cy, frame_height, screen_height;

always @(posedge vgaclk)
begin
  if(mode80 ? 1'b1 : (cx >= 64 &&  cx < 576 && cy >=48 && cy < 432))
     rgb <= vga_rgb ? rgb_screen_color : 24'b0;
  else
     rgb <= test_in ? 24'h404040 : 24'h000000;
end

wire [2:0] tmds_x;
wire tmds_clock_x;

// 640x480 @ 60Hz
hdmi #(.VIDEO_ID_CODE(1), .VIDEO_REFRESH_RATE(60), .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmi(
  .clk_pixel_x5(vgaclk_x5),
  .clk_pixel(vgaclk),
  .clk_audio(1'b0),
  .reset(1'b0),
  .rgb(rgb),
  .audio_sample_word(audio_sample_word),
  .tmds(tmds_x),
  .tmds_clock(tmds_clock_x),
  .cx(cx),
  .cy(cy),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);

ELVDS_OBUF tmds [2:0] (
  .O(tmds_p),
  .OB(tmds_n),
  .I(tmds_x)
);

ELVDS_OBUF tmds_clock(
  .O(tmds_clock_p),
  .OB(tmds_clock_n),
  .I(tmds_clock_x)
);

//-----DPLL------------------------------------------------------------------------

reg [1:0] hsync_in_dly;

always @ (posedge vgaclk_x5)
begin
   hsync_in_dly <= { hsync_in_dly[0], hsync_in }; // no glitch suppression
   //hsync_in_dly  <= { hsync_in_dly[0] , (^hsync_in_dly ) ? hsync_in_dly[0] : hsync_in }; // glitch suppression
end


// The 64x16 mode has 640=80*8 pixels per line, 512=64*8 active and 128 blanked.
// The horizontal rate is 15.84kHz.  The dotclock is 640*15.84=10.1376MHz
// The 80x24 mode has 800=100*8 pixels per line, 640=80*8 active and 160 blanked.
// The horizontal rate is 15.84kHz.  The dotclock is 800*15.84=12.672MHz

reg [31:0] nco;
reg [4:0] prev_nco;
reg [9:0] hcnt; // mod 640 (800) horizontal counter -320..319 (-400..399)
reg [9:0] phserr; // phaase error
reg [4:0] phserr_rdy; // strobe to update loop filter
reg [15:0] nco_in; // frequency control input
reg [8:0] lock;

always @ (posedge vgaclk_x5)
begin
   // 0x0A4C6B6F = 2^31*10.1376/126
   // 0x0CDF864A = 2^31*12.672/126
   nco <= {1'b0, nco[30:0]} + {1'b0, (mode80 ? 31'h0CDF864A : 31'h0A4C6B6F) + {{10{nco_in[15]}}, nco_in, 5'b0}};
   // The nco is the fractional part of hcnt.  However the carry-out from the nco is
   // pipelined (delayed one clock) so it is actually the delayed nco that is the
   // fractional part.
   prev_nco <= nco[30:26];

   // When locked the hsync rising edge will sample hcnt when it crosses through zero.
   if(hsync_in_dly == 2'b01) // rising edge
   begin
      // If the hsync is in the neighborhood of zero crossing then take the offset
      // as the phase error.  Otherwise just reset hcnt to align it to hsync.
      if(hcnt[9:4] == 6'b111111 || hcnt[9:4] == 6'b000000)
      begin
         phserr <= sw[0] ? -{hcnt[4:0], prev_nco} : 10'd0;
         phserr_rdy <= 1'b1;
         if(nco[31])
            hcnt <= (hcnt == (mode80 ? 10'd399 : 10'd319)) ? (mode80 ? -10'd400 : -10'd320) : (hcnt + 10'd1);
         lock <= lock + {8'b0, ~lock[8]};
      end
      else
      begin
         phserr_rdy <= 1'b0;
         hcnt <= 10'd0;
         lock <= 9'b0;
      end
   end
   else
   begin
      phserr_rdy <= 1'b0;
      if(nco[31])
         hcnt <= (hcnt == (mode80 ? 10'd399 : 10'd319)) ? (mode80 ? -10'd400 : -10'd320) : (hcnt + 10'd1);
   end
end

assign led[5] = ~lock[8];


// Simple PI controller.
// The integral path gain is 1/8 the proportional path gain.
// The loop gain is determined by position where the loop filter
// output is added in to the nco.  The nco pull range is determined
// by this gain and the number of bits in the error integrator.
// The values used here were determined emperically.
reg [15:0] phserr_int; // phase error integrator

always @ (posedge vgaclk_x5)
begin
   // Update the integrator when the phase error is updated.
   if(phserr_rdy)
   begin
      //    siiiiii.iiiiiiiii  phserr_int
      //  + SSSSSSs.eeeeeeeee  {{6{phserr[9]}}, phserr}
      phserr_int <= phserr_int + {{6{phserr[9]}}, phserr};
   end
   //   siiiiii.iiiiiiiii  phserr_int
   // + SSSs.eeeeeeeee000  {{3{phserr[9]}}, phserr, 3'b000}
   nco_in <= phserr_int + {{3{phserr[9]}}, phserr, 3'b000};
end


//=================================================================================

// 10.1376MHz (12.672MHz) dot clock
wire dotclk;

BUFG dotclk_bufg(
   .O(dotclk),
   .I(~nco[30])
);

assign gpio_28 = dotclk;


// Synchronize the hzync, vsync, and pixel signals to the recovered dotclk.
// From observation hsync rises on the dotclk rising edge so sample with
// falling, and vsync falls on the dotclock rising edge so sample with falling.
// so sample them with the dotclk rising edge.

reg [1:0] hsync_in_shr;
reg [1:0] vsync_in_shr;

always @ (negedge dotclk)
begin
   hsync_in_shr <= {hsync_in_shr[0], hsync_in};
   vsync_in_shr <= {vsync_in_shr[0], vsync_in};
end


// The pixel signal transitions near the rising edge of the recovered dotclk
// but is return-to-zero pulses.  First stretch the pulse using the high
// frequency clock then sample the stretched pulse with the falling edge of
// dotclk.

reg [5:0] pixel_in_dly;

always @ (posedge vgaclk_x5)
begin
   pixel_in_dly <= { pixel_in_dly[4:0], pixel_in }; // no glitch suppression
   //pixel_in_dly  <= { pixel_in_dly[4:0] , (^pixel_in_dly[1:0] ) ? pixel_in_dly[0] : pixel_in }; // glitch suppression
end


reg [7:0] pixel_in_shr;

always @ (negedge dotclk)
begin
   pixel_in_shr <= {pixel_in_shr[6:0], |{pixel_in_dly, pixel_in}};
end

//=================================================================================

// The horizontal and vertical oscillators (looping counters).
// These don't have to be oscillators - they could just be one-shots that trigger
// from their respective syncs.
// The blanking periods correspond to when the counters are negative.

reg [10:0] hcnt_in; // -16*8..64*8-1 (-20*8..80*8-1)
// The 64 column mode has 264=22*12 lines @60Hz and 312=26*12 lines @50Hz,
// 192=16*12 active and the rest blanked.
// The 80 column mode has 264=26.4*10 lines @60Hz and 312=31.2*10 lines @50Hz,
// 240=24*10 active and the rest blanked.
reg [8:0] vcnt_in; // 60Hz: -6*12..16*12-1 (50Hz: -10*12..16*12-1)
reg pix_wr;
reg hcheck, vcheck;

always @ (posedge dotclk)
begin
   // The horizontal sync value -110 (-136) was found experimentally such that the
   // active portion of the line is captured.  This can be tweaked +/- to shift
   // the captured portion left/right.
   if(hsync_in_shr == 2'b01) // rising edge
   begin
      hcnt_in <= mode80 ? -11'd136 : -11'd110;
      // If the counter modulo is right then once synced the counter will already
      // be transitioning to the sync count when the horizontal sync occurs.
      hcheck <= (hcnt_in == mode80 ? -11'd137 : -11'd111);
   end
   else
   begin
      hcnt_in <= (hcnt_in == (mode80 ? 11'd639 : 11'd511)) ? (mode80 ? -11'd160 : -11'd128) : (hcnt_in + 11'd1);
   end

   // The vertical sync value -48 (-22) was found experimentally such that the
   // active portion of the display is captured.
   if(vsync_in_shr == 2'b10) // falling edge
   begin
      vcnt_in <= mode80 ? -9'd22 : -9'd48;
      // If the counter modulo is right then once synced the counter will already
      // be at the sync count when the vertical sync occurs.
      vcheck <= (vcnt_in == (mode80 ? -9'd22 : -9'd48));
   end
   else
   begin
      if(hcnt_in == (mode80 ? 11'd639 : 11'd511))
         vcnt_in <= (vcnt_in == (mode80 ? 9'd239 : 9'd191)) ? (mode80 ? -9'd24 : -9'd72) : (vcnt_in + 9'd1);
   end

   // The pix_wr write pulse is generated only during the active portion of the display
   // because the address to the ram isn't valid during the inactive portion.
   // Any hcnt_in[2:0] can be used here, the hsync sync value can just be adjusted.
   // A value of 3'b110 is used here so that the high part of hcnt_in doesn't
   // increment on the same clock.
   pix_wr <= (hcnt_in[10] == 1'b0 && hcnt_in[2:0] == 3'b110 && vcnt_in[8] == 1'b0);
end

assign led[4:3] = {~vcheck, ~hcheck};

//=================================================================================

// The vga data needs to be read a few clocks early to compensate for the output register
// delays so the ram read address is offset from the vga address.  A positive offset is added
// to anticipate the read of the next data, modulo the frame_width/height.  Just a small
// offset is needed but since the full frame_width is a multiple of 8 it's convenient to
// offet the address by a full byte, which provides up to 8 clcock cycles to work with.

wire [9:0] cxx = {(cx[9:3] == (frame_width[9:3] - 7'd1)) ? 7'd0 : (cx[9:3] + 7'd1), cx[2:0]};
wire [9:0] cyy = (cx[9:3] == (frame_width[9:3] - 7'd1)) ? ((cy == (frame_height - 10'd1)) ? 10'd0 : (cy + 10'd1)) : cy;
wire [7:0] vgadta;

Gowin_DPB display_ram(
   .clka(dotclk),              //input clka
   .cea(pix_wr),               //input cea
   .ada({hcnt_in[9:3] + (mode80 ? 7'd0 : 7'd8), vcnt_in[7:0] + (mode80 ? 8'd0 : 8'd24)}), //input [14:0] ada
   .douta(),                   //output [7:0] douta
   .dina(pixel_in_shr),        //input [7:0] dina
   .ocea(1'b0),                //input ocea
   .wrea(pix_wr),              //input wrea
   .reseta(1'b0),              //input reseta

   .clkb(vgaclk),              //input clkb
   .ceb(cxx[2:0] == 3'b101),   //input ceb
   .adb({cxx[9:3], cyy[8:1]}), //input [14:0] adb
   .doutb(vgadta),             //output [7:0] doutb
   .dinb(8'b0),                //input [7:0] dinb
   .oceb(cxx[2:0] == 3'b110),  //input oceb
   .wreb(1'b0),                //input wreb
   .resetb(1'b0)               //input resetb
);


reg [7:0] vgashr;

always @ (posedge vgaclk)
begin
   vgashr <= (cxx[2:0] == 3'b111) ? vgadta : {vgashr[6:0], 1'b0};
end

// This is one vgaclk earlier than the hdmi wants the rgb data.
// This is to allow for the rgb register that was in the original hdmi example.
assign vga_rgb = vgashr[7];

endmodule
