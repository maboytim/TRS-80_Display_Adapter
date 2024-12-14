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
   input [7:0] test8,

   // HDMI
   output [2:0] tmds_p,
   output [2:0] tmds_n,
   output tmds_clock_p,
   output tmds_clock_n,

   // ADC
   output vga_red,  // adc cs
   input vga_green, // adc dta
   output vga_blue, // ads clk
   output vga_hsync,
   output vga_vsync
);

assign vga_hsync = 1'b1;
assign vga_vsync = 1'b1;
wire adc_dta = vga_green;


// 200MHz clock
wire vgaclk_x5;

Gowin_rPLL vgaclkpll(
   .clkout(vgaclk_x5), //output
   .clkin(clk_in)      //input
);

// 40MHz clock
wire vgaclk;

Gowin_CLKDIV clkdiv(
  .clkout(vgaclk),    //output
  .hclkin(vgaclk_x5), //input
  .resetn(1'b1)       //input
);


// generate adc enable at 32*48kHz
reg [9:0] adc_nco;
reg adc_en;

always @ (posedge vgaclk)
begin
   if(adc_nco < 10'd833) // 833=40MHz/48kHz
   begin
      adc_nco <= adc_nco + 10'd32; // 32=32*48kHz/48kHz
      adc_en <= 1'b0;
   end
   else
   begin
      adc_nco <= adc_nco + 10'd32 - 10'd833;
      adc_en <= 1'b1;
   end
end

//-----AUDIO ADC-------------------------------------------------------------------

reg [4:0] adc_cnt;
reg [12:0] adc_shreg;
reg [11:0] adc_reg = 12'd0;
reg adc_null = 1'b0;
reg adc_cs = 1'b1;

always @ (posedge vgaclk)
begin
   if(adc_en)
   begin
      adc_cnt <= adc_cnt + 5'b1;
      // lsb is adc clk
      // if clk is high then transitioning to low
      if(adc_cnt[0] == 1'b1)
      begin
         // adc clk falling edge
         if(adc_cnt[4:1] == 4'b1110)
         begin
            adc_cs <= 1'b1;
            adc_null = adc_shreg[12];
            // the null bit is always 0
            if(~adc_shreg[12])
               adc_reg <= {~adc_shreg[11], adc_shreg[10:0]};
         end
         else
            adc_cs <= 1'b0;
      end
      else
         // adc clk rising edge
         adc_shreg <= {adc_shreg[11:0], adc_dta};
   end
end

wire audclk = adc_cnt[4];

assign vga_blue = adc_cnt[0];
assign vga_red = adc_cs;
assign led[2] = ~adc_null;

//-----HDMI------------------------------------------------------------------------

logic vga_rgb;

//pll pll(.c0(clk_pixel_x5), .c1(clk_pixel), .c2(clk_audio));

wire [15:0] audio_sample_word [1:0] = '{{adc_reg, 4'b0000}, {adc_reg, 4'b0000}};

reg [23:0] rgb = 24'h000000;
wire [23:0] rgb_screen_color = test8[7:6] == 2'b00 ? 24'hffcc00 :  // Amber
                               test8[7:6] == 2'b01 ? 24'h33ff33 :  // Green - from trs-io {51, 255, 51}
                               test8[7:6] == 2'b10 ? 24'hffb100 :  // Amber - from trs-io {255, 177, 0}
                                                     24'hffffff ;  // White
logic [10:0] cx, frame_width;
logic [9:0] screen_width;
logic [9:0] cy, frame_height, screen_height;

always @(posedge vgaclk)
begin
  if(!sw[1] && (cx == 0 || cx == (screen_width - 1) || cy == 0 || cy == (screen_height - 1)))
     rgb <= 24'h0000ff;
  else
  if(cx >= 16 && cx < 784 && cy >= 12 && cy < 588)
     rgb <= vga_rgb ? rgb_screen_color : 24'h000000;
  else
     rgb <= test_in ? 24'h404040 : 24'h000000;
end

wire [2:0] tmds_x;
wire tmds_clock_x;

// 800x600 @ 60Hz
hdmi #(.VIDEO_ID_CODE(5), .VIDEO_REFRESH_RATE(60), .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmi(
  .clk_pixel_x5(vgaclk_x5),
  .clk_pixel(vgaclk),
  .clk_audio(audclk),
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
   //hsync_in_dly <= { hsync_in_dly[0], (^hsync_in_dly) ? hsync_in_dly[0] : hsync_in }; // glitch suppression
end


// The M1 has 672=112*6 pixels per line, 384=64*6 active and 288 blanked.
// The horizontal rate is 15.84kHz.  The dotclock is 672*15.84=10.6445MHz
reg [31:0] nco;
reg [4:0] prev_nco;
reg [9:0] hcnt; // mod 672 horizontal counter -336..335
reg [9:0] phserr; // phaase error
reg [4:0] phserr_rdy; // strobe to update loop filter
reg [15:0] nco_in; // frequency control input
reg [8:0] lock;

always @ (posedge vgaclk_x5)
begin
   // 0x06D1BD99 = 2^31*10.6445/199.8
   nco <= {1'b0, nco[30:0]} + {1'b0, 31'h06D1BD99 + {{10{nco_in[15]}}, nco_in, 5'b0}};
   // The nco is the fractional part of hcnt.  However the carry-out from the nco is
   // pipelined (delayed one clock) so it is actually the delayed nco that is the
   // fractional part.
   prev_nco <= nco[30:26];

   // When locked the hsync will sample hcnt when it crosses through zero.
   if(hsync_in_dly == 2'b01) // rising edge
   begin
      // If the hsync is in the neighborhood of zero crossing then take the offset
      // as the phase error.  Otherwise just reset hcnt to align it to hsync.
      if(hcnt[9:4] == 6'b111111 || hcnt[9:4] == 6'b000000)
      begin
         phserr <= sw[0] ? -{hcnt[4:0], prev_nco} : 10'd0;
         phserr_rdy <= 1'b1;
         if(nco[31])
            hcnt <= (hcnt == 10'd335) ? -10'd336 : (hcnt + 10'd1);
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
         hcnt <= (hcnt == 10'd335) ? -10'd336 : (hcnt + 10'd1);
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


assign gpio_29 = hcnt[9];
assign gpio_30 = nco[30];

//========================================================================

// 10.6445MHz dot clock
wire dotclk;

BUFG dotclk_bufg(
   .O(dotclk),
   .I(~nco[30])
);


// Synchronize the hzync, vsync, and pixel signals to the recovered dotclk.
// From observation hsync rises on the dotclk rising edge so sample with
// falling.

reg [1:0] hsync_in_shr;

always @ (negedge dotclk)
begin
   hsync_in_shr <= {hsync_in_shr[0], hsync_in};
end


// The vsync signal is generated by a one-shot so only one edge is reliabe
// which from observation is the falling edge - and which from observation
// falls on the dotclk falling edge so sample it with the dotclk rising edge.

reg [1:0] vsync_in_shr;

always @ (negedge dotclk)
begin
   vsync_in_shr <= {vsync_in_shr[0], vsync_in};
end


reg [5:0] pixel_in_shr;

always @ (posedge dotclk)
begin
   pixel_in_shr <= {pixel_in_shr[4:0], pixel_in | test8[0]};
end

//=================================================================================

// The horizontal and vertical oscillators (looping counters).
// These don't have to be oscillators - they could just be one-shots that trigger
// from their respective syncs.
// The blanking periods correspond to when the counters are negative.

reg [9:0] hcnt_in; // -48*6..64*6-1
// The M1 has 264=22*12 lines @60Hz and 312=26*12 lines @50Hz, 192=16*12 active
// and the rest blanked. 
reg [8:0] vcnt_in; // 60Hz: -6*12..16*12-1 (50Hz: -10*12..16*12-1)
reg pix_wr;
reg hcheck, vcheck;

always @ (posedge dotclk)
begin
   // The horizontal sync value -102 was found experimentally such that the
   // active portion of the line is captured.  This can be tweaked +/- to shift
   // the captured portion left/right.
   if(hsync_in_shr == 2'b01) // rising edge
   begin
      hcnt_in <= {-7'd2, 3'b000};
      // If the counter modulo is right then once synced the counter will already
      // be transitioning to the sync count when the horizontal sync occurs.
      hcheck <= (hcnt_in == {-7'd3, 3'b101});
   end
   else
   begin
      if(hcnt_in[2:0] == 3'b101)
      begin
         hcnt_in[2:0] <= 3'b000;
         hcnt_in[9:3] <= (hcnt_in[9:3] == 7'd63) ? -7'd48 : (hcnt_in[9:3] + 7'd1);
      end
      else
         hcnt_in[2:0] <= hcnt_in[2:0] + 3'b001;
   end

   // The vertical sync value -36 was found experimentally such that the
   // active portion of the display is captured.
   if(vsync_in_shr == 2'b10) // falling edge
   begin
      vcnt_in <= -9'd72;
      // If the counter modulo is right then once synced the counter will already
      // be at the sync count when the vertical sync occurs.
      vcheck <= (vcnt_in == -9'd72);
   end
   else
   begin
      if(hcnt_in == {7'd63, 3'b101})
         vcnt_in <= (vcnt_in == 9'd191) ? -9'd72 : (vcnt_in + 9'd1);
   end

   // The pix_wr write pulse is generated only during the active portion of the display
   // because the address to the ram isn't valid during the inactive portion.
   // Any hcnt_in[2:0] can be used here, the hsync sync value can just be adjusted.
   // A value of 3'b100 is used here so that the high part of hcnt_in doesn't
   // increment on the same clock.
   pix_wr <= (hcnt_in[9] == 1'b0 && hcnt_in[2:0] == 3'b100 && vcnt_in[8] == 1'b0);
end

assign led[4:3] = {~vcheck, ~hcheck};

//=================================================================================

reg [10:0] cxx;
reg [9:0] cyy;

always @ (posedge vgaclk)
begin
   if(cx == (11'd15 - 11'd12) && cy == 10'd12)
   begin
      cxx <= {7'd0, 3'b000, 1'b0};
      cyy <= {8'd0, 2'b00};
   end
   else
      if(cxx[0] == 1'b1)
      begin
         cxx[0] <= 1'b0;
         if(cxx[3:1] == 3'b101)
         begin
            cxx[3:1] <= 3'b000;
            if(cxx[10:4] == 7'd87)
            begin
               cxx[10:4] <= 7'd0;
               if(cyy[1:0] == 2'b10)
               begin
                  cyy[1:0] <= 2'b00;
                  cyy[9:2] <= cyy[9:2] + 8'd1;
               end
               else
               begin
                  if(cyy[1:0] == 2'b00 && cyy[9:2] == 8'd209)
                     cyy <= {8'd0, 2'b00};
                  else
                     cyy[1:0] <= cyy[1:0] + 2'b01;
               end
            end
            else
               cxx[10:4] <= cxx[10:4] + 7'd1;
         end
         else
            cxx[3:1] <= cxx[3:1] + 3'b001;
      end
      else
         cxx[0] <= 1'b1;
   begin
   end
end

wire [5:0] vgadta;

Gowin_DPB display_ram(
   .clka(dotclk),              //input
   .cea(pix_wr),               //input
   .ada({vcnt_in[7:0], hcnt_in[8:3]}), //input [13:0]
   .douta(),                   //output [5:0]
   .dina(pixel_in_shr),        //input [5:0]
   .ocea(1'b0),                //input
   .wrea(pix_wr),              //input
   .reseta(1'b0),              //input

   .clkb(vgaclk),              //input
   .ceb(cxx[3:0] == 4'b1001),  //input
   .adb({cyy[9:2], cxx[9:4]}), //input [13:0]
   .doutb(vgadta),             //output [5:0]
   .dinb(6'b0),                //input [5:0]
   .oceb(cxx[3:0] == 4'b1010), //input
   .wreb(1'b0),                //input
   .resetb(1'b0)               //input
);


reg [5:0] vgashr;

always @ (posedge vgaclk)
begin
   if(cxx[0] == 1'b1)
      vgashr <= (cxx[3:1] == 3'b101) ? vgadta : {vgashr[4:0], 1'b0};
end

// This is one vgaclk earlier than the hdmi wants the rgb data.
// This is to allow for the rgb register that was in the original hdmi example.
assign vga_rgb = vgashr[5];

endmodule
