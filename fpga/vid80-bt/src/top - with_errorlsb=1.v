`timescale 1ns / 1ps

module top(
   input clk_in,
   input [1:0] sw,
   output [5:0] led,
   output uart_tx,
   input uart_rx,
   input gpio_25,
   input gpio_26,
   input gpio_27,
   output gpio_28,
   output gpio_29,
   output gpio_30,

   input gpio_33,
   input gpio_34,
   input gpio_40,
   input gpio_35,
   input gpio_41,
   input gpio_42,
   input gpio_51,
   input gpio_53,

   output gpio_86,
   output gpio_85,
   output gpio_84,
   output gpio_83,
   output gpio_82,
   output gpio_81,
   output gpio_80,
   output gpio_79,

  // HDMI
  output [2:0] tmds_p,
  output [2:0] tmds_n,
  output tmds_clock_p,
  output tmds_clock_n
);

wire pixel_in = gpio_25;
wire vsync_in = gpio_26;
wire hsync_in = gpio_27;


wire [7:0] uart_rx_dta;
wire uart_rx_dta_rdy;

uart uart(
   // Inputs
   .clk_i(clk_in),             // System clock
   .uart_rx(uart_rx),          // UART receive wire
   .wr_i(uart_rx_dta_rdy),     // Strobe high to write transmit byte - sets tx_bsy_o
   .rd_i(1'b0),                // Strobe high to read receive byte - clears rx_rdy_o
   .dat_i(uart_rx_dta),        // 8-bit tx data
   // Outputs
   .uart_tx(uart_tx),          // UART transmit wire
   .tx_bsy_o(),                // High means UART transmit register full
   .rx_rdy_o(),                // High means UART receive register empty
   .dat_o(uart_rx_dta),        // 8-bit data out
   .dat_o_stb(uart_rx_dta_rdy) // Strobed high when dat_o changes
);

assign led[2:0] = ~uart_rx_dta[2:0];

reg [15:0] z80_kbd_reg;
reg [21:0] kbd_tmr;
reg [7:0] prev_uart_rx_dta;
reg esc;

always @ (posedge clk_in)
begin
  if(uart_rx_dta_rdy)
  begin
    if(esc)
    begin
      if(uart_rx_dta == "A") // up
        z80_kbd_reg <= 16'h4008;
      else if(uart_rx_dta == "B") // down
        z80_kbd_reg <= 16'h4010;
      else if(uart_rx_dta == "D") // left
        z80_kbd_reg <= 16'h4020;
      else if(uart_rx_dta == "C") // right
        z80_kbd_reg <= 16'h4040;
    end
    else if(uart_rx_dta >= "@" && uart_rx_dta <= "G")
      z80_kbd_reg <= 16'h0100 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "a" && uart_rx_dta <= "g")
      z80_kbd_reg <= 16'h8100 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "H" && uart_rx_dta <= "O")
      z80_kbd_reg <= 16'h0200 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "h" && uart_rx_dta <= "o")
      z80_kbd_reg <= 16'h8200 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "P" && uart_rx_dta <= "W")
      z80_kbd_reg <= 16'h0400 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "p" && uart_rx_dta <= "w")
      z80_kbd_reg <= 16'h8400 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "X" && uart_rx_dta <= "Z")
      z80_kbd_reg <= 16'h0800 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta >= "x" && uart_rx_dta <= "z")
      z80_kbd_reg <= 16'h8800 | (1 << (uart_rx_dta & 7));
    else if((uart_rx_dta >= "0" && uart_rx_dta <= "7")) // 01234567
      z80_kbd_reg <= 16'h1000 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta == "^") // shift-0
      z80_kbd_reg <= 16'h9001;
    else if((uart_rx_dta >= "!" && uart_rx_dta <= "&")) // !"#$%&
      z80_kbd_reg <= 16'h9000 | (1 << (uart_rx_dta & 7));
    else if(uart_rx_dta == "'") // '
      z80_kbd_reg <= 16'h9080;
    else if((uart_rx_dta >= "8" && uart_rx_dta <= ";")) // 89:;
      z80_kbd_reg <= 16'h2000 | (1 << (uart_rx_dta & 7));
    else if((uart_rx_dta >= "," && uart_rx_dta <= "/")) // ,-./
      z80_kbd_reg <= 16'h2000 | (16 << (uart_rx_dta & 3));
    else if((uart_rx_dta >= "(" && uart_rx_dta <= "+")) // ()*+
      z80_kbd_reg <= 16'ha000 | (1 << (uart_rx_dta & 3));
    else if((uart_rx_dta >= "<" && uart_rx_dta <= "?")) // <=>?
      z80_kbd_reg <= 16'ha000 | (16 << (uart_rx_dta & 3));
    else if(uart_rx_dta == 8'D13) // enter
      z80_kbd_reg <= 16'h4001;
    else if(uart_rx_dta == "~") // clear (~)
      z80_kbd_reg <= 16'h4002;
    else if(uart_rx_dta == "`") // break (`)
      z80_kbd_reg <= 16'h4004;
    else if(uart_rx_dta == 8'h7F) // left arrow / backspace
      z80_kbd_reg <= 16'h4020;
    else if(uart_rx_dta == " ") // space
      z80_kbd_reg <= 16'h4080;

    prev_uart_rx_dta <= uart_rx_dta;
    esc <= (prev_uart_rx_dta == 8'h1B && uart_rx_dta == "[");

    kbd_tmr <= 22'h280000 - 1;
  end
  else
  begin
    if(kbd_tmr == 0)
      z80_kbd_reg <= 16'h0000;
    else
      kbd_tmr <= kbd_tmr - 1;
  end
end


wire [7:0] z80_addr = {gpio_53, gpio_51, gpio_42, gpio_41, gpio_35, gpio_40, gpio_34, gpio_33};
reg [7:0] z80_kbd_data;

always @ (posedge clk_in)
begin
   if(~z80_addr[6:0] & z80_kbd_reg[14:8])
      z80_kbd_data <= z80_kbd_reg[7:0];
   else if(~z80_addr[7] & z80_kbd_reg[15])
      z80_kbd_data <= 8'h01;
   else
      z80_kbd_data <= 8'h00;
end

assign {gpio_79, gpio_80, gpio_81, gpio_82, gpio_83, gpio_84, gpio_85, gpio_86} = ~z80_kbd_data;


wire clk;

Gowin_rPLL pll108M(
   .clkout(clk),  //output clkout
   .clkin(clk_in) //input clkin
);


wire vgaclk_x5;

Gowin_rPLL0 vgaclkpll(
   .clkout(vgaclk_x5), //output clkout
   .clkin(clk_in)     //input clkin
);


wire vgaclk;

Gowin_CLKDIV clkdiv(
  .clkout(vgaclk),    //output clkout
  .hclkin(vgaclk_x5), //input hclkin
  .resetn(1'b1)       //input resetn
);

//-----HDMI------------------------------------------------------------------------

logic vga_rgb;

//pll pll(.c0(clk_pixel_x5), .c1(clk_pixel), .c2(clk_audio));

logic [15:0] audio_sample_word [1:0] = '{16'd0, 16'd0};

logic [23:0] rgb = 24'd0;
logic [23:0] rgb_screen_color = 24'hffffff;
logic [10:0] cx, screen_start_x, frame_width, screen_width;
logic [9:0] cy, screen_start_y, frame_height, screen_height;

always @(posedge vgaclk)
begin
  if(cx >= 64 &&  cx < 576 && cy >=48 && cy < 432)
     rgb <= vga_rgb ? rgb_screen_color : 24'b0;
  else
     rgb <= 24'h404040;
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


reg [1:0] hsync_in_dly;

always @ (posedge clk)
begin
   hsync_in_dly <= {hsync_in_dly[0], hsync_in};
end


reg [31:0] nco;
reg [4:0] prev_nco;
reg [9:0] hcnt;
reg [10:0] phserr;
reg [4:0] phserr_rdy;
reg [16:0] nco_in;
reg [8:0] lock;

always @ (posedge clk)
begin
   nco <= {1'b0, nco[30:0]} + {1'b0, 31'h0C03D2AC - {{10{nco_in[16]}}, nco_in, 4'b0}};
   prev_nco <= nco[30:26];

   if(hsync_in_dly == 2'b01) // rising edge
   begin
      if(hcnt[9:4] == 6'b111111 || hcnt[9:4] == 6'b000000)
      begin
         phserr <= sw[0] ? {hcnt[4:0], prev_nco, sw[1]} : 11'd0;
         phserr_rdy <= 1'b1;
         if(nco[31])
            hcnt <= (hcnt == 10'd319) ? -10'd320 : (hcnt + 10'd1);
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
         hcnt <= (hcnt == 10'd319) ? -10'd320 : (hcnt + 10'd1);
   end
end

assign led[5] = {~lock[8]};


reg [15:0] phserr_int;

always @ (posedge clk)
begin
   if(phserr_rdy)
   begin
      //    siiiii.iiiiiiiiii   phserr_int
      //  + SSSSSs.eeeeeeeee1   {{5{phserr[10]}}, phserr}
      phserr_int <= phserr_int + {{5{phserr[10]}}, phserr};
      //   Ssiiiii.iiiiiiiiii  {{1{phserr_int[15]}}, phserr_int}
      // + SSSs.eeeeeeeee1000  {{3{phserr[10]}}, phserr, 3'b0}
      nco_in <= {{1{phserr_int[15]}}, phserr_int} + {{3{phserr[10]}}, phserr, 3'b000};
   end
end


assign gpio_29 = hcnt[9];
assign gpio_30 = nco[30];


wire dotclk;

BUFG dotclk_bufg(
   .O(dotclk),
   .I(nco[30])
);


reg [7:0] pixel_in_shr;
reg [1:0] hsync_in_shr;

always @ (posedge dotclk)
begin
   pixel_in_shr <= {pixel_in_shr[6:0], pixel_in};
   hsync_in_shr <= {hsync_in_shr[0], hsync_in};
end

reg [1:0] vsync_in_shr;

always @ (negedge dotclk)
begin
   vsync_in_shr <= {vsync_in_shr[0], vsync_in};
end


// The horizontal and vertical oscillators (looping counters).
// These don't have to be oscillators - they could just be one-shots that trigger
// from their respective syncs.
reg [9:0] hcnt_in; // -16*8..64*8-1
reg [8:0] vcnt_in; // 60Hz: -6*12..16*12-1, 50Hz: -10*12..16*12-1
reg pix_wr;
reg hcheck, vcheck;

always @ (posedge dotclk)
begin
   // The horizontal sync value -10'd102 was found experimentally such that the
   // active portion of the line is captured.  This can be tweaked +/- to shift
   // the captured portion left/right.
   if(hsync_in_shr == 2'b01) // rising edge
   begin
      hcnt_in <= -10'd102;
      // If the counter modulo is right then once synced the counter will already
      // be transitioning to the sync count when the horizontal sync occurs.
      hcheck <= (hcnt_in == -10'd103);
   end
   else
   begin
      hcnt_in <= (hcnt_in == 10'd511) ? -10'd128 : (hcnt_in + 10'd1);
   end

   // The vertical sync value -9'd36 was found experimentally such that the
   // active portion of the display is captured.
   if(vsync_in_shr == 2'b10) // falling edge
   begin
      vcnt_in <= -9'd36;
      // If the counter modulo is right then once synced the counter will already
      // be at the sync count when the vertical sync occurs.
      vcheck <= (vcnt_in == -9'd36);
   end
   else
   begin
      if(hcnt_in == 10'd511)
         vcnt_in <= (vcnt_in == 9'd191) ? -9'd72 : (vcnt_in + 9'd1);
   end

   // The pix_wr write pulse is generated only during the active portion of the display.
   // Any hcnt_in[2:0] can be used here, the hsync sync value can just be adjusted.
   // A value of 3'b110 is used here so that the high part of hcnt_in doesn't
   // increment on the same clock.
   pix_wr <= (hcnt_in[9] == 1'b0 && hcnt_in[2:0] == 3'b110 && vcnt_in[8] == 1'b0);
end

assign led[4:3] = {~vcheck, ~hcheck};


wire [7:0] vgadta;
wire [10:0] cxx = cx - (11'd64 - 11'd8);
wire [9:0] cyy = cy - 10'd48;

Gowin_DPB display_ram(
   .clka(dotclk),                      //input clka
   .cea(pix_wr),                       //input cea
   .ada({vcnt_in[7:0], hcnt_in[8:3]}), //input [13:0] ada
   .douta(),                           //output [7:0] douta
   .dina(pixel_in_shr),                //input [7:0] dina
   .ocea(1'b0),                        //input ocea
   .wrea(pix_wr),                      //input wrea
   .reseta(1'b0),                      //input reseta

   .clkb(vgaclk),              //input clkb
   .ceb(cxx[2:0] == 3'b101),   //input ceb
   .adb({cyy[8:1], cxx[8:3]}), //input [13:0] adb
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
// This allows for one more pipeline stage to the hdmi rgb input.
assign vga_rgb = vgashr[7];

endmodule
