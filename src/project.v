/*
 * 67 MEME VGA
 * SIX! SEVEN!!!
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,
  output wire [7:0] uo_out,
  input  wire [7:0] uio_in,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe,
  input  wire       ena,
  input  wire       clk,
  input  wire       rst_n
);

  // ============================================================
  // VGA SIGNALS
  // ============================================================

  wire hsync;
  wire vsync;

  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;

  wire video_active;

  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {
    hsync,
    B[0],
    G[0],
    R[0],
    vsync,
    B[1],
    G[1],
    R[1]
  };

  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire _unused_ok = &{ena, ui_in, uio_in};

  // ============================================================
  // VGA GENERATOR
  // ============================================================

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // ============================================================
  // ANIMATION COUNTER
  // ============================================================

  // Only bits [5:2] are used by the animation, so 6 bits are enough.
  // Keep animation logic in the main clk domain and detect the VSYNC
  // rising edge instead of using VSYNC as a generated clock.
  reg [5:0] counter;
  reg       vsync_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 6'd0;
      vsync_d <= 1'b0;
    end else begin
      vsync_d <= vsync;

      if (vsync && !vsync_d)
        counter <= counter + 6'd1;
    end
  end

  // ============================================================
  // RGB OUTPUT
  // ============================================================

  reg [1:0] r_pix;
  reg [1:0] g_pix;
  reg [1:0] b_pix;

  assign R = video_active ? r_pix : 2'b00;
  assign G = video_active ? g_pix : 2'b00;
  assign B = video_active ? b_pix : 2'b00;

  // ============================================================
  // ANIMATION POSITIONS
  // ============================================================

  reg [9:0] six_y;
  reg [9:0] seven_y;

  reg [9:0] left_hand_y;
  reg [9:0] right_hand_y;

  // ============================================================
  // DRAW EVERYTHING
  // ============================================================

  always @* begin

    // ==========================================================
    // ANIMATION
    // ==========================================================

    six_y       = 10'd140;
    seven_y     = 10'd140;
    left_hand_y = 10'd320;
    right_hand_y = 10'd320;

    case (counter[3:2])

      2'b00: begin
        six_y        = 10'd135;
        seven_y      = 10'd150;

        left_hand_y  = 10'd300;
        right_hand_y = 10'd340;
      end

      2'b01: begin
        six_y        = 10'd140;
        seven_y      = 10'd145;

        left_hand_y  = 10'd310;
        right_hand_y = 10'd330;
      end

      2'b10: begin
        six_y        = 10'd150;
        seven_y      = 10'd135;

        left_hand_y  = 10'd340;
        right_hand_y = 10'd300;
      end

      default: begin
        six_y        = 10'd145;
        seven_y      = 10'd140;

        left_hand_y  = 10'd330;
        right_hand_y = 10'd310;
      end

    endcase


    // ==========================================================
    // FLASHING BACKGROUND
    // ==========================================================

    case (counter[5:4])

      // PURPLE
      2'b00: begin
        r_pix = 2'b10;
        g_pix = 2'b00;
        b_pix = 2'b11;
      end

      // RED
      2'b01: begin
        r_pix = 2'b11;
        g_pix = 2'b00;
        b_pix = 2'b01;
      end

      // BLUE
      2'b10: begin
        r_pix = 2'b00;
        g_pix = 2'b01;
        b_pix = 2'b11;
      end

      // DARK
      default: begin
        r_pix = 2'b00;
        g_pix = 2'b00;
        b_pix = 2'b01;
      end

    endcase


    // ==========================================================
    // FLASHING BORDER
    // ==========================================================

    if (
        pix_x < 10'd15 ||
        pix_x > 10'd624 ||
        pix_y < 10'd15 ||
        pix_y > 10'd464
       )
    begin

      if (counter[3]) begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b00;
      end
      else begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b11;
      end

    end


    // ==========================================================
    // CONFETTI
    // ==========================================================

    if (
        // top-left
        (pix_x >= 10'd70 &&
         pix_x < 10'd80 &&
         pix_y >= 10'd70 &&
         pix_y < 10'd90)

        ||

        (pix_x >= 10'd105 &&
         pix_x < 10'd125 &&
         pix_y >= 10'd100 &&
         pix_y < 10'd110)

        ||

        // top-right
        (pix_x >= 10'd520 &&
         pix_x < 10'd530 &&
         pix_y >= 10'd65 &&
         pix_y < 10'd85)

        ||

        (pix_x >= 10'd550 &&
         pix_x < 10'd570 &&
         pix_y >= 10'd115 &&
         pix_y < 10'd125)

        ||

        // lower
        (pix_x >= 10'd85 &&
         pix_x < 10'd95 &&
         pix_y >= 10'd380 &&
         pix_y < 10'd400)

        ||

        (pix_x >= 10'd540 &&
         pix_x < 10'd550 &&
         pix_y >= 10'd370 &&
         pix_y < 10'd390)
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b11;
      b_pix = 2'b00;
    end


    // ==========================================================
    // MORE BLINKING CONFETTI
    // ==========================================================

    if (counter[3]) begin

      if (
          (pix_x >= 10'd145 &&
           pix_x < 10'd155 &&
           pix_y >= 10'd55 &&
           pix_y < 10'd75)

          ||

          (pix_x >= 10'd470 &&
           pix_x < 10'd490 &&
           pix_y >= 10'd75 &&
           pix_y < 10'd85)

          ||

          (pix_x >= 10'd60 &&
           pix_x < 10'd80 &&
           pix_y >= 10'd260 &&
           pix_y < 10'd270)

          ||

          (pix_x >= 10'd565 &&
           pix_x < 10'd585 &&
           pix_y >= 10'd270 &&
           pix_y < 10'd280)
         )
      begin
        r_pix = 2'b00;
        g_pix = 2'b11;
        b_pix = 2'b11;
      end

    end


    // ==========================================================
    // GIANT NUMBER 6
    //
    // Position roughly X = 170
    // ==========================================================

    if (
        // TOP
        (pix_x >= 10'd170 &&
         pix_x < 10'd280 &&
         pix_y >= six_y &&
         pix_y < six_y + 10'd25)

        ||

        // UPPER LEFT
        (pix_x >= 10'd170 &&
         pix_x < 10'd195 &&
         pix_y >= six_y &&
         pix_y < six_y + 10'd90)

        ||

        // MIDDLE
        (pix_x >= 10'd170 &&
         pix_x < 10'd280 &&
         pix_y >= six_y + 10'd75 &&
         pix_y < six_y + 10'd100)

        ||

        // LOWER LEFT
        (pix_x >= 10'd170 &&
         pix_x < 10'd195 &&
         pix_y >= six_y + 10'd75 &&
         pix_y < six_y + 10'd165)

        ||

        // LOWER RIGHT
        (pix_x >= 10'd255 &&
         pix_x < 10'd280 &&
         pix_y >= six_y + 10'd75 &&
         pix_y < six_y + 10'd165)

        ||

        // BOTTOM
        (pix_x >= 10'd170 &&
         pix_x < 10'd280 &&
         pix_y >= six_y + 10'd140 &&
         pix_y < six_y + 10'd165)
       )
    begin

      // flashing 6
      if (counter[2]) begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b00;
      end
      else begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b11;
      end

    end


    // ==========================================================
    // GIANT NUMBER 7
    //
    // Position roughly X = 360
    // ==========================================================

    if (
        // TOP
        (pix_x >= 10'd355 &&
         pix_x < 10'd465 &&
         pix_y >= seven_y &&
         pix_y < seven_y + 10'd25)

        ||

        // UPPER RIGHT
        (pix_x >= 10'd440 &&
         pix_x < 10'd465 &&
         pix_y >= seven_y &&
         pix_y < seven_y + 10'd90)

        ||

        // LOWER RIGHT
        (pix_x >= 10'd440 &&
         pix_x < 10'd465 &&
         pix_y >= seven_y + 10'd75 &&
         pix_y < seven_y + 10'd165)
       )
    begin

      // opposite flash
      if (counter[2]) begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b11;
      end
      else begin
        r_pix = 2'b11;
        g_pix = 2'b11;
        b_pix = 2'b00;
      end

    end


    // ==========================================================
    // EXCLAMATION MARK LEFT
    // ==========================================================

    if (
        (pix_x >= 10'd110 &&
         pix_x < 10'd130 &&
         pix_y >= 10'd155 &&
         pix_y < 10'd245)

        ||

        (pix_x >= 10'd110 &&
         pix_x < 10'd130 &&
         pix_y >= 10'd265 &&
         pix_y < 10'd285)
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b01;
      b_pix = 2'b00;
    end


    // ==========================================================
    // EXCLAMATION MARK RIGHT
    // ==========================================================

    if (
        (pix_x >= 10'd505 &&
         pix_x < 10'd525 &&
         pix_y >= 10'd155 &&
         pix_y < 10'd245)

        ||

        (pix_x >= 10'd505 &&
         pix_x < 10'd525 &&
         pix_y >= 10'd265 &&
         pix_y < 10'd285)
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b01;
      b_pix = 2'b00;
    end


    // ==========================================================
    // LEFT ARM
    // ==========================================================

    if (
        pix_x >= 10'd75 &&
        pix_x < 10'd170 &&
        pix_y >= left_hand_y &&
        pix_y < left_hand_y + 10'd15
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // LEFT PALM
    // ==========================================================

    if (
        pix_x >= 10'd50 &&
        pix_x < 10'd95 &&
        pix_y >= left_hand_y - 10'd10 &&
        pix_y < left_hand_y + 10'd18
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // LEFT FINGERS
    // ==========================================================

    if (
        (pix_x >= 10'd52 &&
         pix_x < 10'd58 &&
         pix_y >= left_hand_y - 10'd25 &&
         pix_y < left_hand_y - 10'd5)

        ||

        (pix_x >= 10'd62 &&
         pix_x < 10'd68 &&
         pix_y >= left_hand_y - 10'd28 &&
         pix_y < left_hand_y - 10'd5)

        ||

        (pix_x >= 10'd72 &&
         pix_x < 10'd78 &&
         pix_y >= left_hand_y - 10'd25 &&
         pix_y < left_hand_y - 10'd5)

        ||

        (pix_x >= 10'd82 &&
         pix_x < 10'd88 &&
         pix_y >= left_hand_y - 10'd20 &&
         pix_y < left_hand_y - 10'd5)
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // RIGHT ARM
    // ==========================================================

    if (
        pix_x >= 10'd470 &&
        pix_x < 10'd565 &&
        pix_y >= right_hand_y &&
        pix_y < right_hand_y + 10'd15
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // RIGHT PALM
    // ==========================================================

    if (
        pix_x >= 10'd545 &&
        pix_x < 10'd590 &&
        pix_y >= right_hand_y - 10'd10 &&
        pix_y < right_hand_y + 10'd18
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // RIGHT FINGERS
    // ==========================================================

    if (
        (pix_x >= 10'd550 &&
         pix_x < 10'd556 &&
         pix_y >= right_hand_y - 10'd20 &&
         pix_y < right_hand_y - 10'd5)

        ||

        (pix_x >= 10'd560 &&
         pix_x < 10'd566 &&
         pix_y >= right_hand_y - 10'd25 &&
         pix_y < right_hand_y - 10'd5)

        ||

        (pix_x >= 10'd570 &&
         pix_x < 10'd576 &&
         pix_y >= right_hand_y - 10'd28 &&
         pix_y < right_hand_y - 10'd5)

        ||

        (pix_x >= 10'd580 &&
         pix_x < 10'd586 &&
         pix_y >= right_hand_y - 10'd25 &&
         pix_y < right_hand_y - 10'd5)
       )
    begin
      r_pix = 2'b11;
      g_pix = 2'b10;
      b_pix = 2'b01;
    end


    // ==========================================================
    // LITTLE ENERGY BLOCKS AROUND THE 67
    // ==========================================================

    if (
        (pix_x >= 10'd300 &&
         pix_x < 10'd315 &&
         pix_y >= 10'd80 &&
         pix_y < 10'd110)

        ||

        (pix_x >= 10'd325 &&
         pix_x < 10'd340 &&
         pix_y >= 10'd65 &&
         pix_y < 10'd100)

        ||

        (pix_x >= 10'd300 &&
         pix_x < 10'd315 &&
         pix_y >= 10'd330 &&
         pix_y < 10'd360)

        ||

        (pix_x >= 10'd325 &&
         pix_x < 10'd340 &&
         pix_y >= 10'd345 &&
         pix_y < 10'd375)
       )
    begin

      if (counter[2]) begin
        r_pix = 2'b00;
        g_pix = 2'b11;
        b_pix = 2'b11;
      end
      else begin
        r_pix = 2'b11;
        g_pix = 2'b00;
        b_pix = 2'b11;
      end

    end

  end

endmodule

`default_nettype wire