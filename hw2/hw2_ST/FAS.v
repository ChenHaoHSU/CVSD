/****************************************************************
  Top Module
*****************************************************************/
module FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
  fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
  fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
  input clk, rst;
  input data_valid;
  input [15:0] data; 

  output fir_valid, fft_valid;
  output [15:0] fir_d;
  output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
  output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
  output done;
  output [3:0] freq;

  wire stp_valid;
  // stp outputs; fft inputs
  wire signed [15:0] x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07,
                     x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15;  
  
  FIR_FILTER fas_fir(
    .clk(clk), 
    .rst(rst),
    .data_valid(data_valid),
    .data(data),
    .fir_valid(fir_valid),
    .fir_d(fir_d)
  );

  STP fas_stp(
    .clk(clk), 
    .rst(rst),
    .fir_valid(fir_valid),
    .fir_d(fir_d),
    .stp_valid(stp_valid),
    .x_00(x_00), .x_01(x_01), .x_02(x_02), .x_03(x_03), 
    .x_04(x_04), .x_05(x_05), .x_06(x_06), .x_07(x_07),
    .x_08(x_08), .x_09(x_09), .x_10(x_10), .x_11(x_11), 
    .x_12(x_12), .x_13(x_13), .x_14(x_14), .x_15(x_15)
  );

  FFT fas_fft(
    .clk(clk), 
    .rst(rst),
    .stp_valid(stp_valid),
    .x_00(x_00), .x_01(x_01), .x_02(x_02), .x_03(x_03), .x_04(x_04), .x_05(x_05), .x_06(x_06), .x_07(x_07), 
    .x_08(x_08), .x_09(x_09), .x_10(x_10), .x_11(x_11), .x_12(x_12), .x_13(x_13), .x_14(x_14), .x_15(x_15),
    .fft_valid(fft_valid),
    .fft_d00(fft_d0), .fft_d01(fft_d1), .fft_d02(fft_d2), .fft_d03(fft_d3), 
    .fft_d04(fft_d4), .fft_d05(fft_d5), .fft_d06(fft_d6), .fft_d07(fft_d7),
    .fft_d08(fft_d8), .fft_d09(fft_d9), .fft_d10(fft_d10), .fft_d11(fft_d11),
    .fft_d12(fft_d12), .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15)
  );

  ANALYST fsa_analyst(
    .clk(clk), 
    .rst(rst),
    .fft_valid(fft_valid), 
    .fft_d00(fft_d0), .fft_d01(fft_d1), .fft_d02(fft_d2), .fft_d03(fft_d3), 
    .fft_d04(fft_d4), .fft_d05(fft_d5), .fft_d06(fft_d6), .fft_d07(fft_d7),
    .fft_d08(fft_d8), .fft_d09(fft_d9), .fft_d10(fft_d10), .fft_d11(fft_d11),
    .fft_d12(fft_d12), .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15),
    .done(done),
    .freq(freq)
  );

endmodule

/****************************************************************
  FIR_filter
*****************************************************************/

module FIR_FILTER (clk, rst, data_valid, data, fir_valid, fir_d);
  input clk, rst;
  input data_valid;
  input signed [15:0] data;
  output fir_valid;
  output signed [15:0] fir_d;

  /* ============================================ */
  parameter signed [19:0] FIR_C00 = 20'hFFF9E ;  //The FIR_coefficient value  0: -1.495361e-003
  parameter signed [19:0] FIR_C01 = 20'hFFF86 ;  //The FIR_coefficient value  1: -1.861572e-003
  parameter signed [19:0] FIR_C02 = 20'hFFFA7 ;  //The FIR_coefficient value  2: -1.358032e-003
  parameter signed [19:0] FIR_C03 = 20'h0003B ;  //The FIR_coefficient value  3:  9.002686e-004
  parameter signed [19:0] FIR_C04 = 20'h0014B ;  //The FIR_coefficient value  4:  5.050659e-003
  parameter signed [19:0] FIR_C05 = 20'h0024A ;  //The FIR_coefficient value  5:  8.941650e-003
  parameter signed [19:0] FIR_C06 = 20'h00222 ;  //The FIR_coefficient value  6:  8.331299e-003
  parameter signed [19:0] FIR_C07 = 20'hFFFE4 ;  //The FIR_coefficient value  7: -4.272461e-004
  parameter signed [19:0] FIR_C08 = 20'hFFBC5 ;  //The FIR_coefficient value  8: -1.652527e-002
  parameter signed [19:0] FIR_C09 = 20'hFF7CA ;  //The FIR_coefficient value  9: -3.207397e-002
  parameter signed [19:0] FIR_C10 = 20'hFF74E ;  //The FIR_coefficient value 10: -3.396606e-002
  parameter signed [19:0] FIR_C11 = 20'hFFD74 ;  //The FIR_coefficient value 11: -9.948730e-003
  parameter signed [19:0] FIR_C12 = 20'h00B1A ;  //The FIR_coefficient value 12:  4.336548e-002
  parameter signed [19:0] FIR_C13 = 20'h01DAC ;  //The FIR_coefficient value 13:  1.159058e-001
  parameter signed [19:0] FIR_C14 = 20'h02F9E ;  //The FIR_coefficient value 14:  1.860046e-001
  parameter signed [19:0] FIR_C15 = 20'h03AA9 ;  //The FIR_coefficient value 15:  2.291412e-001
  parameter signed [19:0] FIR_C16 = 20'h03AA9 ;  //The FIR_coefficient value 16:  2.291412e-001
  parameter signed [19:0] FIR_C17 = 20'h02F9E ;  //The FIR_coefficient value 17:  1.860046e-001
  parameter signed [19:0] FIR_C18 = 20'h01DAC ;  //The FIR_coefficient value 18:  1.159058e-001
  parameter signed [19:0] FIR_C19 = 20'h00B1A ;  //The FIR_coefficient value 19:  4.336548e-002
  parameter signed [19:0] FIR_C20 = 20'hFFD74 ;  //The FIR_coefficient value 20: -9.948730e-003
  parameter signed [19:0] FIR_C21 = 20'hFF74E ;  //The FIR_coefficient value 21: -3.396606e-002
  parameter signed [19:0] FIR_C22 = 20'hFF7CA ;  //The FIR_coefficient value 22: -3.207397e-002
  parameter signed [19:0] FIR_C23 = 20'hFFBC5 ;  //The FIR_coefficient value 23: -1.652527e-002
  parameter signed [19:0] FIR_C24 = 20'hFFFE4 ;  //The FIR_coefficient value 24: -4.272461e-004
  parameter signed [19:0] FIR_C25 = 20'h00222 ;  //The FIR_coefficient value 25:  8.331299e-003
  parameter signed [19:0] FIR_C26 = 20'h0024A ;  //The FIR_coefficient value 26:  8.941650e-003
  parameter signed [19:0] FIR_C27 = 20'h0014B ;  //The FIR_coefficient value 27:  5.050659e-003
  parameter signed [19:0] FIR_C28 = 20'h0003B ;  //The FIR_coefficient value 28:  9.002686e-004
  parameter signed [19:0] FIR_C29 = 20'hFFFA7 ;  //The FIR_coefficient value 29: -1.358032e-003
  parameter signed [19:0] FIR_C30 = 20'hFFF86 ;  //The FIR_coefficient value 30: -1.861572e-003
  parameter signed [19:0] FIR_C31 = 20'hFFF9E ;  //The FIR_coefficient value 31: -1.495361e-003

  /* ============================================ */
  reg [5:0] fir_cnt_r, fir_cnt_w;
  reg signed [66:0] sum_r, sum_w;
  reg signed [15:0] x_00_r, x_01_r, x_02_r, x_03_r, x_04_r, x_05_r, x_06_r, x_07_r,
                    x_08_r, x_09_r, x_10_r, x_11_r, x_12_r, x_13_r, x_14_r, x_15_r,
                    x_16_r, x_17_r, x_18_r, x_19_r, x_20_r, x_21_r, x_22_r, x_23_r,
                    x_24_r, x_25_r, x_26_r, x_27_r, x_28_r, x_29_r, x_30_r, x_31_r;
  reg signed [15:0] x_00_w, x_01_w, x_02_w, x_03_w, x_04_w, x_05_w, x_06_w, x_07_w,
                    x_08_w, x_09_w, x_10_w, x_11_w, x_12_w, x_13_w, x_14_w, x_15_w,
                    x_16_w, x_17_w, x_18_w, x_19_w, x_20_w, x_21_w, x_22_w, x_23_w,
                    x_24_w, x_25_w, x_26_w, x_27_w, x_28_w, x_29_w, x_30_w, x_31_w;

  /* ============================================ */
  assign fir_valid = (fir_cnt_w > 33);
  assign fir_d = sum_w >= 0 ? {sum_w[66], sum_w[30:24], sum_w[23:16]} : {sum_w[66], sum_w[30:24], sum_w[23:16]} + 16'd1;

  /* ============================================ */
  always@ (*) begin
    x_00_w    = x_00_r; 
    x_01_w    = x_01_r; 
    x_02_w    = x_02_r; 
    x_03_w    = x_03_r; 
    x_04_w    = x_04_r;  
    x_05_w    = x_05_r;  
    x_06_w    = x_06_r;  
    x_07_w    = x_07_r;  
    x_08_w    = x_08_r;  
    x_09_w    = x_09_r;  
    x_10_w    = x_10_r;  
    x_11_w    = x_11_r;  
    x_12_w    = x_12_r;  
    x_13_w    = x_13_r;  
    x_14_w    = x_14_r;  
    x_15_w    = x_15_r;  
    x_16_w    = x_16_r;  
    x_17_w    = x_17_r;  
    x_18_w    = x_18_r;  
    x_19_w    = x_19_r;  
    x_20_w    = x_20_r;  
    x_21_w    = x_21_r;  
    x_22_w    = x_22_r;  
    x_23_w    = x_23_r;  
    x_24_w    = x_24_r;  
    x_25_w    = x_25_r;  
    x_26_w    = x_26_r;  
    x_27_w    = x_27_r;  
    x_28_w    = x_28_r;  
    x_29_w    = x_29_r;  
    x_30_w    = x_30_r;  
    x_31_w    = x_31_r;  
    sum_w     = sum_r;
    fir_cnt_w = fir_cnt_r;

    if (data_valid) begin
      if (fir_cnt_r <= 33) begin 
        fir_cnt_w = fir_cnt_r + 1;
      end
      x_31_w = data;
      x_30_w = x_31_r;
      x_29_w = x_30_r;
      x_28_w = x_29_r;
      x_27_w = x_28_r;
      x_26_w = x_27_r;
      x_25_w = x_26_r;
      x_24_w = x_25_r;
      x_23_w = x_24_r;
      x_22_w = x_23_r;
      x_21_w = x_22_r;
      x_20_w = x_21_r;
      x_19_w = x_20_r;
      x_18_w = x_19_r;
      x_17_w = x_18_r;
      x_16_w = x_17_r;
      x_15_w = x_16_r;
      x_14_w = x_15_r;
      x_13_w = x_14_r;
      x_12_w = x_13_r;
      x_11_w = x_12_r;
      x_10_w = x_11_r;
      x_09_w = x_10_r;
      x_08_w = x_09_r;
      x_07_w = x_08_r;
      x_06_w = x_07_r;
      x_05_w = x_06_r;
      x_04_w = x_05_r;
      x_03_w = x_04_r;
      x_02_w = x_03_r;
      x_01_w = x_02_r;
      x_00_w = x_01_r;

      sum_w = x_31_r * FIR_C00
            + x_30_r * FIR_C01
            + x_29_r * FIR_C02
            + x_28_r * FIR_C03
            + x_27_r * FIR_C04
            + x_26_r * FIR_C05
            + x_25_r * FIR_C06
            + x_24_r * FIR_C07
            + x_23_r * FIR_C08
            + x_22_r * FIR_C09
            + x_21_r * FIR_C10
            + x_20_r * FIR_C11
            + x_19_r * FIR_C12
            + x_18_r * FIR_C13
            + x_17_r * FIR_C14
            + x_16_r * FIR_C15
            + x_15_r * FIR_C16
            + x_14_r * FIR_C17
            + x_13_r * FIR_C18
            + x_12_r * FIR_C19
            + x_11_r * FIR_C20
            + x_10_r * FIR_C21
            + x_09_r * FIR_C22
            + x_08_r * FIR_C23
            + x_07_r * FIR_C24
            + x_06_r * FIR_C25
            + x_05_r * FIR_C26
            + x_04_r * FIR_C27
            + x_03_r * FIR_C28
            + x_02_r * FIR_C29
            + x_01_r * FIR_C30
            + x_00_r * FIR_C31;
    end else begin
      sum_w     = 0;
      fir_cnt_w = 0;
    end
  end

  /* ============================================ */
  always@ (posedge clk or posedge rst) begin 
    if (rst) begin
      x_00_r    <= 0;
      x_01_r    <= 0;
      x_02_r    <= 0;
      x_03_r    <= 0;
      x_04_r    <= 0;
      x_05_r    <= 0;
      x_06_r    <= 0;
      x_07_r    <= 0;
      x_08_r    <= 0;
      x_09_r    <= 0;
      x_10_r    <= 0;
      x_11_r    <= 0;
      x_12_r    <= 0;
      x_13_r    <= 0;
      x_14_r    <= 0;
      x_15_r    <= 0;
      x_16_r    <= 0;
      x_17_r    <= 0;
      x_18_r    <= 0;
      x_19_r    <= 0;
      x_20_r    <= 0;
      x_21_r    <= 0;
      x_22_r    <= 0;
      x_23_r    <= 0;
      x_24_r    <= 0;
      x_25_r    <= 0;
      x_26_r    <= 0;
      x_27_r    <= 0;
      x_28_r    <= 0;
      x_29_r    <= 0;
      x_30_r    <= 0;
      x_31_r    <= 0;
      sum_r     <= 0;
      fir_cnt_r <= 0;
    end else begin
      x_00_r    <= x_00_w;   
      x_01_r    <= x_01_w;   
      x_02_r    <= x_02_w;   
      x_03_r    <= x_03_w;   
      x_04_r    <= x_04_w;   
      x_05_r    <= x_05_w;   
      x_06_r    <= x_06_w;   
      x_07_r    <= x_07_w;   
      x_08_r    <= x_08_w;   
      x_09_r    <= x_09_w;   
      x_10_r    <= x_10_w;  
      x_11_r    <= x_11_w;  
      x_12_r    <= x_12_w;  
      x_13_r    <= x_13_w;  
      x_14_r    <= x_14_w;  
      x_15_r    <= x_15_w;  
      x_16_r    <= x_16_w;  
      x_17_r    <= x_17_w;  
      x_18_r    <= x_18_w;  
      x_19_r    <= x_19_w;  
      x_20_r    <= x_20_w;  
      x_21_r    <= x_21_w;  
      x_22_r    <= x_22_w;  
      x_23_r    <= x_23_w;  
      x_24_r    <= x_24_w;  
      x_25_r    <= x_25_w;  
      x_26_r    <= x_26_w;  
      x_27_r    <= x_27_w;  
      x_28_r    <= x_28_w;  
      x_29_r    <= x_29_w;  
      x_30_r    <= x_30_w;  
      x_31_r    <= x_31_w;  
      sum_r     <= sum_w;
      fir_cnt_r <= fir_cnt_w;
    end
  end

endmodule

/****************************************************************
  STP (Serial to Parallel)
*****************************************************************/

module STP (clk, rst, fir_valid, fir_d, stp_valid,
  x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07, 
  x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15);
  input clk, rst;
  input fir_valid;
  input signed [15:0] fir_d;
  output stp_valid;
  output signed [15:0] x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07, 
                       x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15;

  /* ============================================ */
  reg [5:0] stp_cnt_r, stp_cnt_w;
  reg [15:0] x_r[15:0];
  reg [15:0] x_w[15:0];

  /* ============================================ */
  integer i;

  /* ============================================ */
  assign stp_valid = (stp_cnt_w >= 16);
  assign x_00 = x_w[ 0];
  assign x_01 = x_w[ 1];
  assign x_02 = x_w[ 2];
  assign x_03 = x_w[ 3];
  assign x_04 = x_w[ 4];
  assign x_05 = x_w[ 5];
  assign x_06 = x_w[ 6];
  assign x_07 = x_w[ 7];
  assign x_08 = x_w[ 8];
  assign x_09 = x_w[ 9];
  assign x_10 = x_w[10];
  assign x_11 = x_w[11];
  assign x_12 = x_w[12];
  assign x_13 = x_w[13];
  assign x_14 = x_w[14];
  assign x_15 = x_w[15];

  /* ============================================ */
  always@ (*) begin

    stp_cnt_w = stp_cnt_r;
    for (i = 0; i < 16; i = i + 1)
      x_w[i] = x_r[i];

    if (fir_valid || stp_cnt_r > 0) begin
      if (stp_cnt_r >= 16) begin
        stp_cnt_w = 1;
        x_w[0] = fir_d;
      end else begin 
        stp_cnt_w = stp_cnt_r + 1;
        x_w[stp_cnt_r] = fir_d;
      end
    end else begin 
      stp_cnt_w = 0;
    end
  end

  /* ============================================ */
  always@ (posedge clk or posedge rst) begin
    if (rst) begin 
      for (i = 0; i < 16; i = i + 1)
        x_r[i] <= 0;
      stp_cnt_r <= 0;
    end else begin 
      for (i = 0; i < 16; i = i + 1)
        x_r[i] <= x_w[i];
      stp_cnt_r <= stp_cnt_w;
    end
  end 

endmodule

/****************************************************************
  FFT
*****************************************************************/

module FFT (clk, rst, stp_valid,
  x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07, 
  x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15,
  fft_valid,
  fft_d00, fft_d01, fft_d02, fft_d03, fft_d04, fft_d05, fft_d06, fft_d07, 
  fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15);
  input clk, rst;
  input stp_valid;
  input signed [15:0] x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07, 
                      x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15;
  output fft_valid;
  output signed [31:0] fft_d00, fft_d01, fft_d02, fft_d03, fft_d04, fft_d05, fft_d06, fft_d07, 
                       fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15;

  /* ============================================ */
  parameter signed [31:0]  CONST1     = 32'h00010000;   // Constant 1
  parameter signed [147:0] CONST1_148 = {83'b0, 1'b1, 64'b0};  // Constant 1
  parameter signed [31:0] W_REAL_0 = 32'h00010000;  // The real part of the reference table about COS(x)+i*SIN(x) value , 0: 001
  parameter signed [31:0] W_REAL_1 = 32'h0000EC83;  // The real part of the reference table about COS(x)+i*SIN(x) value , 1: 9.238739e-001
  parameter signed [31:0] W_REAL_2 = 32'h0000B504;  // The real part of the reference table about COS(x)+i*SIN(x) value , 2: 7.070923e-001
  parameter signed [31:0] W_REAL_3 = 32'h000061F7;  // The real part of the reference table about COS(x)+i*SIN(x) value , 3: 3.826752e-001
  parameter signed [31:0] W_REAL_4 = 32'h00000000;  // The real part of the reference table about COS(x)+i*SIN(x) value , 4: 000
  parameter signed [31:0] W_REAL_5 = 32'hFFFF9E09;  // The real part of the reference table about COS(x)+i*SIN(x) value , 5: -3.826752e-001
  parameter signed [31:0] W_REAL_6 = 32'hFFFF4AFC;  // The real part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
  parameter signed [31:0] W_REAL_7 = 32'hFFFF137D;  // The real part of the reference table about COS(x)+i*SIN(x) value , 7: -9.238739e-001

  parameter signed [31:0] W_IMAG_0 = 32'h00000000;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 0: 000
  parameter signed [31:0] W_IMAG_1 = 32'hFFFF9E09;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 1: -3.826752e-001
  parameter signed [31:0] W_IMAG_2 = 32'hFFFF4AFC;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 2: -7.070923e-001
  parameter signed [31:0] W_IMAG_3 = 32'hFFFF137D;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 3: -9.238739e-001
  parameter signed [31:0] W_IMAG_4 = 32'hFFFF0000;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 4: -01
  parameter signed [31:0] W_IMAG_5 = 32'hFFFF137D;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 5: -9.238739e-001
  parameter signed [31:0] W_IMAG_6 = 32'hFFFF4AFC;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
  parameter signed [31:0] W_IMAG_7 = 32'hFFFF9E09;  // The imag part of the reference table about COS(x)+i*SIN(x) value , 7: -3.826752e-001

  /* ============================================ */
  reg signed [31:0] W_REAL_r[7:0], W_REAL_w[7:0]; 
  reg signed [31:0] W_IMAG_r[7:0], W_IMAG_w[7:0]; 
  reg signed [147:0] stage1_real_r[15:0], stage1_real_w[15:0];
  reg signed [147:0] stage2_real_r[15:0], stage2_real_w[15:0];
  reg signed [147:0] stage3_real_r[15:0], stage3_real_w[15:0];
  reg signed [147:0] stage4_real_r[15:0], stage4_real_w[15:0];
  reg signed [147:0] stage1_imag_r[15:0], stage1_imag_w[15:0];
  reg signed [147:0] stage2_imag_r[15:0], stage2_imag_w[15:0];
  reg signed [147:0] stage3_imag_r[15:0], stage3_imag_w[15:0];
  reg signed [147:0] stage4_imag_r[15:0], stage4_imag_w[15:0];
  reg signed [15:0] truncate_real_r[15:0], truncate_real_w[15:0];
  reg signed [15:0] truncate_imag_r[15:0], truncate_imag_w[15:0];
  reg [4:0] fft_cnt_r, fft_cnt_w;

  /* ============================================ */
  integer i, j;

  /* ============================================ */
  assign fft_valid = (fft_cnt_w > 4);
  assign fft_d00 = { truncate_real_w[ 0], truncate_imag_w[ 0] };
  assign fft_d08 = { truncate_real_w[ 1], truncate_imag_w[ 1] };
  assign fft_d04 = { truncate_real_w[ 2], truncate_imag_w[ 2] };
  assign fft_d12 = { truncate_real_w[ 3], truncate_imag_w[ 3] };
  assign fft_d02 = { truncate_real_w[ 4], truncate_imag_w[ 4] };
  assign fft_d10 = { truncate_real_w[ 5], truncate_imag_w[ 5] };
  assign fft_d06 = { truncate_real_w[ 6], truncate_imag_w[ 6] };
  assign fft_d14 = { truncate_real_w[ 7], truncate_imag_w[ 7] };
  assign fft_d01 = { truncate_real_w[ 8], truncate_imag_w[ 8] };
  assign fft_d09 = { truncate_real_w[ 9], truncate_imag_w[ 9] };
  assign fft_d05 = { truncate_real_w[10], truncate_imag_w[10] };
  assign fft_d13 = { truncate_real_w[11], truncate_imag_w[11] };
  assign fft_d03 = { truncate_real_w[12], truncate_imag_w[12] };
  assign fft_d11 = { truncate_real_w[13], truncate_imag_w[13] };
  assign fft_d07 = { truncate_real_w[14], truncate_imag_w[14] };
  assign fft_d15 = { truncate_real_w[15], truncate_imag_w[15] };
                    
  // assign fft_d00 = { stage4_real_w[ 0][147], stage4_real_w[ 0][78:72], stage4_real_w[ 0][71:64], 
  //                    stage4_imag_w[ 0][147], stage4_imag_w[ 0][78:72], stage4_imag_w[ 0][71:64]};
  // assign fft_d08 = { stage4_real_w[ 1][147], stage4_real_w[ 1][78:72], stage4_real_w[ 1][71:64], 
  //                    stage4_imag_w[ 1][147], stage4_imag_w[ 1][78:72], stage4_imag_w[ 1][71:64]};
  // assign fft_d04 = { stage4_real_w[ 2][147], stage4_real_w[ 2][78:72], stage4_real_w[ 2][71:64], 
  //                    stage4_imag_w[ 2][147], stage4_imag_w[ 2][78:72], stage4_imag_w[ 2][71:64]};
  // assign fft_d12 = { stage4_real_w[ 3][147], stage4_real_w[ 3][78:72], stage4_real_w[ 3][71:64], 
  //                    stage4_imag_w[ 3][147], stage4_imag_w[ 3][78:72], stage4_imag_w[ 3][71:64]};
  // assign fft_d02 = { stage4_real_w[ 4][147], stage4_real_w[ 4][78:72], stage4_real_w[ 4][71:64], 
  //                    stage4_imag_w[ 4][147], stage4_imag_w[ 4][78:72], stage4_imag_w[ 4][71:64]};
  // assign fft_d10 = { stage4_real_w[ 5][147], stage4_real_w[ 5][78:72], stage4_real_w[ 5][71:64], 
  //                    stage4_imag_w[ 5][147], stage4_imag_w[ 5][78:72], stage4_imag_w[ 5][71:64]};
  // assign fft_d06 = { stage4_real_w[ 6][147], stage4_real_w[ 6][78:72], stage4_real_w[ 6][71:64], 
  //                    stage4_imag_w[ 6][147], stage4_imag_w[ 6][78:72], stage4_imag_w[ 6][71:64]};
  // assign fft_d14 = { stage4_real_w[ 7][147], stage4_real_w[ 7][78:72], stage4_real_w[ 7][71:64], 
  //                    stage4_imag_w[ 7][147], stage4_imag_w[ 7][78:72], stage4_imag_w[ 7][71:64]};
  // assign fft_d01 = { stage4_real_w[ 8][147], stage4_real_w[ 8][78:72], stage4_real_w[ 8][71:64], 
  //                    stage4_imag_w[ 8][147], stage4_imag_w[ 8][78:72], stage4_imag_w[ 8][71:64]};
  // assign fft_d09 = { stage4_real_w[ 9][147], stage4_real_w[ 9][78:72], stage4_real_w[ 9][71:64], 
  //                    stage4_imag_w[ 9][147], stage4_imag_w[ 9][78:72], stage4_imag_w[ 9][71:64]};
  // assign fft_d05 = { stage4_real_w[10][147], stage4_real_w[10][78:72], stage4_real_w[10][71:64], 
  //                    stage4_imag_w[10][147], stage4_imag_w[10][78:72], stage4_imag_w[10][71:64]};
  // assign fft_d13 = { stage4_real_w[11][147], stage4_real_w[11][78:72], stage4_real_w[11][71:64], 
  //                    stage4_imag_w[11][147], stage4_imag_w[11][78:72], stage4_imag_w[11][71:64]};
  // assign fft_d03 = { stage4_real_w[12][147], stage4_real_w[12][78:72], stage4_real_w[12][71:64], 
  //                    stage4_imag_w[12][147], stage4_imag_w[12][78:72], stage4_imag_w[12][71:64]};
  // assign fft_d11 = { stage4_real_w[13][147], stage4_real_w[13][78:72], stage4_real_w[13][71:64], 
  //                    stage4_imag_w[13][147], stage4_imag_w[13][78:72], stage4_imag_w[13][71:64]};
  // assign fft_d07 = { stage4_real_w[14][147], stage4_real_w[14][78:72], stage4_real_w[14][71:64], 
  //                    stage4_imag_w[14][147], stage4_imag_w[14][78:72], stage4_imag_w[14][71:64]};
  // assign fft_d15 = { stage4_real_w[15][147], stage4_real_w[15][78:72], stage4_real_w[15][71:64], 
  //                    stage4_imag_w[15][147], stage4_imag_w[15][78:72], stage4_imag_w[15][71:64]};

  // assign fft_d00 = { ({stage4_real_w[ 0][147], stage4_real_w[ 0][78:72], stage4_real_w[ 0][71:64]} + stage4_real_w[ 0][147]), 
  //                    ({stage4_imag_w[ 0][147], stage4_imag_w[ 0][78:72], stage4_imag_w[ 0][71:64]} + stage4_imag_w[ 0][147])};
  // assign fft_d08 = { ({stage4_real_w[ 1][147], stage4_real_w[ 1][78:72], stage4_real_w[ 1][71:64]} + stage4_real_w[ 1][147]), 
  //                    ({stage4_imag_w[ 1][147], stage4_imag_w[ 1][78:72], stage4_imag_w[ 1][71:64]} + stage4_imag_w[ 1][147])};
  // assign fft_d04 = { ({stage4_real_w[ 2][147], stage4_real_w[ 2][78:72], stage4_real_w[ 2][71:64]} + stage4_real_w[ 2][147]), 
  //                    ({stage4_imag_w[ 2][147], stage4_imag_w[ 2][78:72], stage4_imag_w[ 2][71:64]} + stage4_imag_w[ 2][147])};
  // assign fft_d12 = { ({stage4_real_w[ 3][147], stage4_real_w[ 3][78:72], stage4_real_w[ 3][71:64]} + stage4_real_w[ 3][147]), 
  //                    ({stage4_imag_w[ 3][147], stage4_imag_w[ 3][78:72], stage4_imag_w[ 3][71:64]} + stage4_imag_w[ 3][147])};
  // assign fft_d02 = { ({stage4_real_w[ 4][147], stage4_real_w[ 4][78:72], stage4_real_w[ 4][71:64]} + stage4_real_w[ 4][147]), 
  //                    ({stage4_imag_w[ 4][147], stage4_imag_w[ 4][78:72], stage4_imag_w[ 4][71:64]} + stage4_imag_w[ 4][147])};
  // assign fft_d10 = { ({stage4_real_w[ 5][147], stage4_real_w[ 5][78:72], stage4_real_w[ 5][71:64]} + stage4_real_w[ 5][147]), 
  //                    ({stage4_imag_w[ 5][147], stage4_imag_w[ 5][78:72], stage4_imag_w[ 5][71:64]} + stage4_imag_w[ 5][147])};
  // assign fft_d06 = { ({stage4_real_w[ 6][147], stage4_real_w[ 6][78:72], stage4_real_w[ 6][71:64]} + stage4_real_w[ 6][147]), 
  //                    ({stage4_imag_w[ 6][147], stage4_imag_w[ 6][78:72], stage4_imag_w[ 6][71:64]} + stage4_imag_w[ 6][147])};
  // assign fft_d14 = { ({stage4_real_w[ 7][147], stage4_real_w[ 7][78:72], stage4_real_w[ 7][71:64]} + stage4_real_w[ 7][147]), 
  //                    ({stage4_imag_w[ 7][147], stage4_imag_w[ 7][78:72], stage4_imag_w[ 7][71:64]} + stage4_imag_w[ 7][147])};
  // assign fft_d01 = { ({stage4_real_w[ 8][147], stage4_real_w[ 8][78:72], stage4_real_w[ 8][71:64]} + stage4_real_w[ 8][147]), 
  //                    ({stage4_imag_w[ 8][147], stage4_imag_w[ 8][78:72], stage4_imag_w[ 8][71:64]} + stage4_imag_w[ 8][147])};
  // assign fft_d09 = { ({stage4_real_w[ 9][147], stage4_real_w[ 9][78:72], stage4_real_w[ 9][71:64]} + stage4_real_w[ 9][147]), 
  //                    ({stage4_imag_w[ 9][147], stage4_imag_w[ 9][78:72], stage4_imag_w[ 9][71:64]} + stage4_imag_w[ 9][147])};
  // assign fft_d05 = { ({stage4_real_w[10][147], stage4_real_w[10][78:72], stage4_real_w[10][71:64]} + stage4_real_w[10][147]), 
  //                    ({stage4_imag_w[10][147], stage4_imag_w[10][78:72], stage4_imag_w[10][71:64]} + stage4_imag_w[10][147])};
  // assign fft_d13 = { ({stage4_real_w[11][147], stage4_real_w[11][78:72], stage4_real_w[11][71:64]} + stage4_real_w[11][147]), 
  //                    ({stage4_imag_w[11][147], stage4_imag_w[11][78:72], stage4_imag_w[11][71:64]} + stage4_imag_w[11][147])};
  // assign fft_d03 = { ({stage4_real_w[12][147], stage4_real_w[12][78:72], stage4_real_w[12][71:64]} + stage4_real_w[12][147]), 
  //                    ({stage4_imag_w[12][147], stage4_imag_w[12][78:72], stage4_imag_w[12][71:64]} + stage4_imag_w[12][147])};
  // assign fft_d11 = { ({stage4_real_w[13][147], stage4_real_w[13][78:72], stage4_real_w[13][71:64]} + stage4_real_w[13][147]), 
  //                    ({stage4_imag_w[13][147], stage4_imag_w[13][78:72], stage4_imag_w[13][71:64]} + stage4_imag_w[13][147])};
  // assign fft_d07 = { ({stage4_real_w[14][147], stage4_real_w[14][78:72], stage4_real_w[14][71:64]} + stage4_real_w[14][147]), 
  //                    ({stage4_imag_w[14][147], stage4_imag_w[14][78:72], stage4_imag_w[14][71:64]} + stage4_imag_w[14][147])};
  // assign fft_d15 = { ({stage4_real_w[15][147], stage4_real_w[15][78:72], stage4_real_w[15][71:64]} + stage4_real_w[15][147]), 
  //                    ({stage4_imag_w[15][147], stage4_imag_w[15][78:72], stage4_imag_w[15][71:64]} + stage4_imag_w[15][147])};
 
  /* ============================================ */
  always@ (*) begin
    fft_cnt_w = fft_cnt_r;
    for (i = 0; i < 8; i = i + 1) begin 
      W_REAL_w[i] = W_REAL_r[i];
      W_IMAG_w[i] = W_IMAG_r[i];
    end
    for (i = 0; i < 16; i = i + 1) begin 
      stage1_real_w[i]   = stage1_real_r[i];
      stage2_real_w[i]   = stage2_real_r[i];
      stage3_real_w[i]   = stage3_real_r[i];
      stage4_real_w[i]   = stage4_real_r[i];
      stage1_imag_w[i]   = stage1_imag_r[i];
      stage2_imag_w[i]   = stage2_imag_r[i];
      stage3_imag_w[i]   = stage3_imag_r[i];
      stage4_imag_w[i]   = stage4_imag_r[i];
      truncate_real_w[i] = truncate_real_r[i];
      truncate_imag_w[i] = truncate_imag_r[i];
    end

    if (stp_valid || fft_cnt_r > 0) begin
      fft_cnt_w = (fft_cnt_r > 4 ? 0 : fft_cnt_r + 1);

      case (fft_cnt_r)
        //////////////////////// 
        // STAGE 1:
        //////////////////////// 
        5'd0: begin
          stage1_real_w[0] = (x_00 + x_08) * CONST1;
          stage1_real_w[1] = (x_01 + x_09) * CONST1;
          stage1_real_w[2] = (x_02 + x_10) * CONST1;
          stage1_real_w[3] = (x_03 + x_11) * CONST1;
          stage1_real_w[4] = (x_04 + x_12) * CONST1;
          stage1_real_w[5] = (x_05 + x_13) * CONST1;
          stage1_real_w[6] = (x_06 + x_14) * CONST1;
          stage1_real_w[7] = (x_07 + x_15) * CONST1;

          stage1_imag_w[0] = 0; 
          stage1_imag_w[1] = 0; 
          stage1_imag_w[2] = 0; 
          stage1_imag_w[3] = 0; 
          stage1_imag_w[4] = 0; 
          stage1_imag_w[5] = 0; 
          stage1_imag_w[6] = 0; 
          stage1_imag_w[7] = 0; 

          stage1_real_w[ 8] = (x_00 - x_08) * W_REAL_r[0];
          stage1_real_w[ 9] = (x_01 - x_09) * W_REAL_r[1];
          stage1_real_w[10] = (x_02 - x_10) * W_REAL_r[2];
          stage1_real_w[11] = (x_03 - x_11) * W_REAL_r[3];
          stage1_real_w[12] = (x_04 - x_12) * W_REAL_r[4];
          stage1_real_w[13] = (x_05 - x_13) * W_REAL_r[5];
          stage1_real_w[14] = (x_06 - x_14) * W_REAL_r[6];
          stage1_real_w[15] = (x_07 - x_15) * W_REAL_r[7];

          stage1_imag_w[ 8] = (x_00 - x_08) * W_IMAG_r[0];
          stage1_imag_w[ 9] = (x_01 - x_09) * W_IMAG_r[1];
          stage1_imag_w[10] = (x_02 - x_10) * W_IMAG_r[2];
          stage1_imag_w[11] = (x_03 - x_11) * W_IMAG_r[3];
          stage1_imag_w[12] = (x_04 - x_12) * W_IMAG_r[4];
          stage1_imag_w[13] = (x_05 - x_13) * W_IMAG_r[5];
          stage1_imag_w[14] = (x_06 - x_14) * W_IMAG_r[6];
          stage1_imag_w[15] = (x_07 - x_15) * W_IMAG_r[7];
        end  

        //////////////////////// 
        // STAGE 2:
        ////////////////////////
        5'd1: begin
          for (i = 0; i < 2; i = i + 1) begin 
            for (j = i * 8; j < i * 8 + 4; j = j + 1) begin 
              stage2_real_w[j] = (stage1_real_r[j] + stage1_real_r[j + 4]) * CONST1;
              stage2_imag_w[j] = (stage1_imag_r[j] + stage1_imag_r[j + 4]) * CONST1;
              stage2_real_w[j + 4] = ((stage1_real_r[j] - stage1_real_r[j + 4]) * W_REAL_r[(j - i * 8) * 2])
                                   + ((stage1_imag_r[j + 4] - stage1_imag_r[j]) * W_IMAG_r[(j - i * 8) * 2]);
              stage2_imag_w[j + 4] = ((stage1_real_r[j] - stage1_real_r[j + 4]) * W_IMAG_r[(j - i * 8) * 2])
                                   + ((stage1_imag_r[j] - stage1_imag_r[j + 4]) * W_REAL_r[(j - i * 8) * 2]);
            end
          end
        end

        //////////////////////// 
        // STAGE 3:
        //////////////////////// 
        5'd2: begin
          for (i = 0; i < 4; i = i + 1) begin 
            for (j = i * 4; j < i * 4 + 2; j = j + 1) begin 
              stage3_real_w[j] = (stage2_real_r[j] + stage2_real_r[j + 2]) * CONST1;
              stage3_imag_w[j] = (stage2_imag_r[j] + stage2_imag_r[j + 2]) * CONST1;
              stage3_real_w[j + 2] = ((stage2_real_r[j] - stage2_real_r[j + 2]) * W_REAL_r[(j - i * 4) * 4])
                                   + ((stage2_imag_r[j + 2] - stage2_imag_r[j]) * W_IMAG_r[(j - i * 4) * 4]);
              stage3_imag_w[j + 2] = ((stage2_real_r[j] - stage2_real_r[j + 2]) * W_IMAG_r[(j - i * 4) * 4])
                                   + ((stage2_imag_r[j] - stage2_imag_r[j + 2]) * W_REAL_r[(j - i * 4) * 4]);
            end
          end
        end

        //////////////////////// 
        // STAGE 4:
        //////////////////////// 
        5'd3: begin
          for (i = 0; i < 8; i = i + 1) begin 
            for (j = i * 2; j < i * 2 + 1; j = j + 1) begin 
              stage4_real_w[j] = (stage3_real_r[j] + stage3_real_r[j + 1]) * CONST1;
              stage4_imag_w[j] = (stage3_imag_r[j] + stage3_imag_r[j + 1]) * CONST1;
              stage4_real_w[j + 1] = ((stage3_real_r[j] - stage3_real_r[j + 1]) * W_REAL_r[0])
                                   + ((stage3_imag_r[j + 1] - stage3_imag_r[j]) * W_IMAG_r[0]);
              stage4_imag_w[j + 1] = ((stage3_real_r[j] - stage3_real_r[j + 1]) * W_IMAG_r[0])
                                   + ((stage3_imag_r[j] - stage3_imag_r[j + 1]) * W_REAL_r[0]);
            end
          end
        end

        //////////////////////// 
        // Truncate
        //////////////////////// 
        5'd4: begin
          for (i = 0; i < 16; i = i + 1) begin 
            truncate_real_w[i] = stage4_real_r[i] < 0 ?
                                 {stage4_real_r[i][147], stage4_real_r[i][78:72], stage4_real_r[i][71:64]}  :
                                 {stage4_real_r[i][147], stage4_real_r[i][78:72], stage4_real_r[i][71:64]};
            truncate_imag_w[i] = stage4_imag_r[i] < 0 ? 
                                 {stage4_imag_r[i][147], stage4_imag_r[i][78:72], stage4_imag_r[i][71:64]}  :
                                 {stage4_imag_r[i][147], stage4_imag_r[i][78:72], stage4_imag_r[i][71:64]};
          end
        end

        default: begin
        end
      endcase

    end else begin 
      fft_cnt_w = 0;
      for (i = 0; i < 16; i = i + 1) begin 
        stage1_real_w[i] = 0;
        stage2_real_w[i] = 0;
        stage3_real_w[i] = 0;
        stage4_real_w[i] = 0;
        stage1_imag_w[i] = 0;
        stage2_imag_w[i] = 0;
        stage3_imag_w[i] = 0;
        stage4_imag_w[i] = 0;
      end
    end 
  end

  /* ============================================ */
  always@ (posedge clk or posedge rst) begin
    if (rst) begin 
      W_REAL_r[0] <= W_REAL_0;
      W_REAL_r[1] <= W_REAL_1;
      W_REAL_r[2] <= W_REAL_2;
      W_REAL_r[3] <= W_REAL_3;
      W_REAL_r[4] <= W_REAL_4;
      W_REAL_r[5] <= W_REAL_5;
      W_REAL_r[6] <= W_REAL_6;
      W_REAL_r[7] <= W_REAL_7;
      W_IMAG_r[0] <= W_IMAG_0;
      W_IMAG_r[1] <= W_IMAG_1;
      W_IMAG_r[2] <= W_IMAG_2;
      W_IMAG_r[3] <= W_IMAG_3;
      W_IMAG_r[4] <= W_IMAG_4;
      W_IMAG_r[5] <= W_IMAG_5;
      W_IMAG_r[6] <= W_IMAG_6;
      W_IMAG_r[7] <= W_IMAG_7;
      for (i = 0; i < 16; i = i + 1) begin 
        stage1_real_r[i]   <= 0;
        stage2_real_r[i]   <= 0;
        stage3_real_r[i]   <= 0;
        stage4_real_r[i]   <= 0;
        stage1_imag_r[i]   <= 0;
        stage2_imag_r[i]   <= 0;
        stage3_imag_r[i]   <= 0;
        stage4_imag_r[i]   <= 0;
        truncate_real_r[i] <= 0;
        truncate_imag_r[i] <= 0;
      end
      fft_cnt_r <= 0;
    end else begin 
      for (i = 0; i < 8; i = i + 1) begin 
        W_REAL_r[i] <= W_REAL_w[i];
        W_IMAG_r[i] <= W_IMAG_w[i];
      end
      for (i = 0; i < 16; i = i + 1) begin 
        stage1_real_r[i]   <= stage1_real_w[i];
        stage2_real_r[i]   <= stage2_real_w[i];
        stage3_real_r[i]   <= stage3_real_w[i];
        stage4_real_r[i]   <= stage4_real_w[i];
        stage1_imag_r[i]   <= stage1_imag_w[i];
        stage2_imag_r[i]   <= stage2_imag_w[i];
        stage3_imag_r[i]   <= stage3_imag_w[i];
        stage4_imag_r[i]   <= stage4_imag_w[i];
        truncate_real_r[i] <= truncate_real_w[i];
        truncate_imag_r[i] <= truncate_imag_w[i];
      end
      fft_cnt_r <= fft_cnt_w;      
    end
  end 

endmodule

/****************************************************************
  ANALYST
*****************************************************************/
module ANALYST(clk, rst, fft_valid, 
  fft_d00, fft_d01, fft_d02, fft_d03, fft_d04, fft_d05, fft_d06, fft_d07, 
  fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15,
  done, freq);
  input clk, rst;
  input fft_valid;
  input [31:0] fft_d00, fft_d01, fft_d02, fft_d03, fft_d04, fft_d05, fft_d06, fft_d07, 
               fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15;
  output done;
  output [3:0] freq;

  /* ============================================ */
  reg [3:0] analyst_cnt_r, analyst_cnt_w;

  // reg signed [15:0] stage0_real_r[15:0], stage1_real_w[15:0];
  // reg signed [15:0] stage0_imag_r[15:0], stage1_imag_w[15:0];
  reg [32:0] stage1_r[15:0], stage1_w[15:0];
  reg [32:0] stage2_r[ 7:0], stage2_w[ 7:0];
  reg [32:0] stage3_r[ 3:0], stage3_w[ 3:0];
  reg [32:0] stage4_r[ 1:0], stage4_w[ 1:0];
  reg [32:0] stage5_r, stage5_w;
  
  reg [32:0] freq1_r[15:0], freq1_w[15:0];
  reg [32:0] freq2_r[ 7:0], freq2_w[ 7:0];
  reg [32:0] freq3_r[ 3:0], freq3_w[ 3:0];
  reg [32:0] freq4_r[ 1:0], freq4_w[ 1:0];
  reg [32:0] freq5_r, freq5_w;

  /* ============================================ */
  integer i;

  /* ============================================ */
  assign done = (analyst_cnt_w > 6);
  assign freq = freq5_w;

  /* ============================================ */
  always@ (*) begin
    
    for (i = 0; i < 16; i = i + 1)
      stage1_w[i] = stage1_r[i];
    for (i = 0; i < 8; i = i + 1)
      stage2_w[i] = stage2_r[i];
    for (i = 0; i < 4; i = i + 1)
      stage3_w[i] = stage3_r[i];
    for (i = 0; i < 2; i = i + 1)
      stage4_w[i] = stage4_r[i];
    stage5_w = stage5_r;

    for (i = 0; i < 16; i = i + 1)
      freq1_w[i] <= freq1_r[i];
    for (i = 0; i < 8; i = i + 1)
      freq2_w[i] <= freq2_r[i];
    for (i = 0; i < 4; i = i + 1)
      freq3_w[i] <= freq3_r[i];
    for (i = 0; i < 2; i = i + 1)
      freq4_w[i] <= freq4_r[i];
    freq5_w <= freq5_r[i];

    analyst_cnt_w = analyst_cnt_r;

    if (fft_valid || analyst_cnt_r > 0) begin
      analyst_cnt_w = analyst_cnt_r > 6 ? 0 : analyst_cnt_r + 1;
      case (analyst_cnt_r)
        //////////////////////// 
        // STAGE 1:
        //////////////////////// 
        4'd0: begin
          stage1_w[ 0] = $signed({fft_d00[31:16]}) * $signed({fft_d00[31:16]}) 
                       + $signed({fft_d00[15: 0]}) * $signed({fft_d00[15: 0]});
          stage1_w[ 1] = $signed({fft_d01[31:16]}) * $signed({fft_d01[31:16]}) 
                       + $signed({fft_d01[15: 0]}) * $signed({fft_d01[15: 0]});
          stage1_w[ 2] = $signed({fft_d02[31:16]}) * $signed({fft_d02[31:16]}) 
                       + $signed({fft_d02[15: 0]}) * $signed({fft_d02[15: 0]});
          stage1_w[ 3] = $signed({fft_d03[31:16]}) * $signed({fft_d03[31:16]}) 
                       + $signed({fft_d03[15: 0]}) * $signed({fft_d03[15: 0]});
          stage1_w[ 4] = $signed({fft_d04[31:16]}) * $signed({fft_d04[31:16]}) 
                       + $signed({fft_d04[15: 0]}) * $signed({fft_d04[15: 0]});
          stage1_w[ 5] = $signed({fft_d05[31:16]}) * $signed({fft_d05[31:16]}) 
                       + $signed({fft_d05[15: 0]}) * $signed({fft_d05[15: 0]});
          stage1_w[ 6] = $signed({fft_d06[31:16]}) * $signed({fft_d06[31:16]}) 
                       + $signed({fft_d06[15: 0]}) * $signed({fft_d06[15: 0]});
          stage1_w[ 7] = $signed({fft_d07[31:16]}) * $signed({fft_d07[31:16]}) 
                       + $signed({fft_d07[15: 0]}) * $signed({fft_d07[15: 0]});
          stage1_w[ 8] = $signed({fft_d08[31:16]}) * $signed({fft_d08[31:16]}) 
                       + $signed({fft_d08[15: 0]}) * $signed({fft_d08[15: 0]});
          stage1_w[ 9] = $signed({fft_d09[31:16]}) * $signed({fft_d09[31:16]}) 
                       + $signed({fft_d09[15: 0]}) * $signed({fft_d09[15: 0]});
          stage1_w[10] = $signed({fft_d10[31:16]}) * $signed({fft_d10[31:16]}) 
                       + $signed({fft_d10[15: 0]}) * $signed({fft_d10[15: 0]});
          stage1_w[11] = $signed({fft_d11[31:16]}) * $signed({fft_d11[31:16]}) 
                       + $signed({fft_d11[15: 0]}) * $signed({fft_d11[15: 0]});
          stage1_w[12] = $signed({fft_d12[31:16]}) * $signed({fft_d12[31:16]}) 
                       + $signed({fft_d12[15: 0]}) * $signed({fft_d12[15: 0]});
          stage1_w[13] = $signed({fft_d13[31:16]}) * $signed({fft_d13[31:16]}) 
                       + $signed({fft_d13[15: 0]}) * $signed({fft_d13[15: 0]});
          stage1_w[14] = $signed({fft_d14[31:16]}) * $signed({fft_d14[31:16]}) 
                       + $signed({fft_d14[15: 0]}) * $signed({fft_d14[15: 0]});
          stage1_w[15] = $signed({fft_d15[31:16]}) * $signed({fft_d15[31:16]}) 
                       + $signed({fft_d15[15: 0]}) * $signed({fft_d15[15: 0]});
          
          for (i = 0; i < 16; i = i + 1)
            freq1_w[i] = i;

          // for (i = 0; i < 16; i = i + 1)
          //   $display("stage[%d] = %f", i, stage1_w[i]);
          // for (i = 0; i < 16; i = i + 1)
          //   $display("freq[%d] = %d", i, freq1_w[i]);

        end
        //////////////////////// 
        // STAGE 2:
        //////////////////////// 
        4'd1: begin
          for (i = 0; i < 8; i = i + 1) begin
            if (stage1_r[i * 2] > stage1_r[i * 2 + 1]) begin
              stage2_w[i] = stage1_r[i * 2];
              freq2_w [i] = freq1_r [i * 2];
            end else begin
              stage2_w[i] = stage1_r[i * 2 + 1];
              freq2_w [i] = freq1_r [i * 2 + 1];
            end
          end
        end
        //////////////////////// 
        // STAGE 3:
        //////////////////////// 
        4'd2: begin
          for (i = 0; i < 4; i = i + 1) begin
            if (stage2_r[i * 2] > stage2_r[i * 2 + 1]) begin
              stage3_w[i] = stage2_r[i * 2];
              freq3_w [i] = freq2_r [i * 2];
            end else begin
              stage3_w[i] = stage2_r[i * 2 + 1];
              freq3_w [i] = freq2_r [i * 2 + 1];
            end
          end
        end
        //////////////////////// 
        // STAGE 4:
        //////////////////////// 
        4'd3: begin
          for (i = 0; i < 2; i = i + 1) begin
            if (stage3_r[i * 2] > stage3_r[i * 2 + 1]) begin
              stage4_w[i] = stage3_r[i * 2];
              freq4_w [i] = freq3_r [i * 2];
            end else begin
              stage4_w[i] = stage3_r[i * 2 + 1];
              freq4_w [i] = freq3_r [i * 2 + 1];
            end
          end
        end
        //////////////////////// 
        // STAGE 5:
        //////////////////////// 
        4'd4: begin
          if (stage4_r[0] > stage4_r[1]) begin
            stage5_w = stage4_r[0];
            freq5_w  = freq4_r [0];
          end else begin
            stage5_w = stage4_r[1];
            freq5_w  = freq4_r [1];
          end
        end

        default: begin 
        end

      endcase
    end else begin
      analyst_cnt_w = 0;
    end
  end

  /* ============================================ */
  always@ (posedge clk or posedge rst) begin
    if (rst) begin 
      for (i = 0; i < 16; i = i + 1)
        stage1_r[i] <= 0;
      for (i = 0; i < 8; i = i + 1)
        stage2_r[i] <= 0;
      for (i = 0; i < 4; i = i + 1)
        stage3_r[i] <= 0;
      for (i = 0; i < 2; i = i + 1)
        stage4_r[i] <= 0;
      stage5_r <= 0;

      for (i = 0; i < 16; i = i + 1)
        freq1_r[i] <= 0;
      for (i = 0; i < 8; i = i + 1)
        freq2_r[i] <= 0;
      for (i = 0; i < 4; i = i + 1)
        freq3_r[i] <= 0;
      for (i = 0; i < 2; i = i + 1)
        freq4_r[i] <= 0;
      freq5_r <= 0;

      analyst_cnt_r <= 0;
    end else begin
      for (i = 0; i < 16; i = i + 1)
        stage1_r[i] <= stage1_w[i];
      for (i = 0; i < 8; i = i + 1)
        stage2_r[i] <= stage2_w[i];
      for (i = 0; i < 4; i = i + 1)
        stage3_r[i] <= stage3_w[i];
      for (i = 0; i < 2; i = i + 1)
        stage4_r[i] <= stage4_w[i];
      stage5_r <= stage5_w;

      for (i = 0; i < 16; i = i + 1)
        freq1_r[i] <= freq1_w[i];
      for (i = 0; i < 8; i = i + 1)
        freq2_r[i] <= freq2_w[i];
      for (i = 0; i < 4; i = i + 1)
        freq3_r[i] <= freq3_w[i];
      for (i = 0; i < 2; i = i + 1)
        freq4_r[i] <= freq4_w[i];
      freq5_r <= freq5_w;

      analyst_cnt_r <= analyst_cnt_w;
    end
  end 

endmodule





