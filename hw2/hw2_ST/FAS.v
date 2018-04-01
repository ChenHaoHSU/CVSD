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

  always@ (*) begin

  end

  always@ (posedge clk or posedge rst) begin 
    if (rst) begin

    end else begin

    end
  end

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

  `include "./dat/FIR_coefficient.dat"

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
  assign fir_d = {sum_w[66], sum_w[30:24], sum_w[23:16]};

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

      sum_w = 0
            + x_31_r * FIR_C00 
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
      x_00_r    <= 15'b0;
      x_01_r    <= 15'b0;
      x_02_r    <= 15'b0;
      x_03_r    <= 15'b0;
      x_04_r    <= 15'b0;
      x_05_r    <= 15'b0;
      x_06_r    <= 15'b0;
      x_07_r    <= 15'b0;
      x_08_r    <= 15'b0;
      x_09_r    <= 15'b0;
      x_10_r    <= 15'b0;
      x_11_r    <= 15'b0;
      x_12_r    <= 15'b0;
      x_13_r    <= 15'b0;
      x_14_r    <= 15'b0;
      x_15_r    <= 15'b0;
      x_16_r    <= 15'b0;
      x_17_r    <= 15'b0;
      x_18_r    <= 15'b0;
      x_19_r    <= 15'b0;
      x_20_r    <= 15'b0;
      x_21_r    <= 15'b0;
      x_22_r    <= 15'b0;
      x_23_r    <= 15'b0;
      x_24_r    <= 15'b0;
      x_25_r    <= 15'b0;
      x_26_r    <= 15'b0;
      x_27_r    <= 15'b0;
      x_28_r    <= 15'b0;
      x_29_r    <= 15'b0;
      x_30_r    <= 15'b0;
      x_31_r    <= 15'b0;
      sum_r     <= 67'b0;
      fir_cnt_r <= 6'b0;
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

    if (fir_valid) begin
      if (stp_cnt_r >= 16) begin
        stp_cnt_w = 0;
        x_w[0] = fir_d;
      end else begin 
        stp_cnt_w = stp_cnt_r + 1;
        x_w[stp_cnt_r] = fir_d;
      end
    end else begin 
      stp_cnt_w = 0;
      for (i = 0; i < 16; i = i + 1)
        x_w[i] = 0;
    end
  end

  /* ============================================ */
  always@ (posedge clk or posedge rst) begin
    if (rst) begin 
      for (i = 0; i < 16; i = i + 1)
        x_r[i] <= 15'b0;
      stp_cnt_r <= 6'b0;
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
  fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, 
);
  input clk, rst;
  input stp_valid;
  input signed [15:0] x_00, x_01, x_02, x_03, x_04, x_05, x_06, x_07, 
                      x_08, x_09, x_10, x_11, x_12, x_13, x_14, x_15;
  output fft_valid;
  output signed [31:0] fft_d00, fft_d01, fft_d02, fft_d03, fft_d04, fft_d05, fft_d06, fft_d07, 
                       fft_d08, fft_d09, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15;

  /* ============================================ */
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
  reg signed [115:0] stage1_real_r[15:0], stage1_real_w[15:0];
  reg signed [115:0] stage2_real_r[15:0], stage2_real_w[15:0];
  reg signed [115:0] stage3_real_r[15:0], stage3_real_w[15:0];
  reg signed [115:0] stage4_real_r[15:0], stage4_real_w[15:0];
  reg signed [115:0] stage1_imag_r[15:0], stage1_imag_w[15:0];
  reg signed [115:0] stage2_imag_r[15:0], stage2_imag_w[15:0];
  reg signed [115:0] stage3_imag_r[15:0], stage3_imag_w[15:0];
  reg signed [115:0] stage4_imag_r[15:0], stage4_imag_w[15:0];
  reg [4:0] fft_cnt_r, fft_cnt_w;

  /* ============================================ */
  integer i;

  /* ============================================ */
  assign fft_valid = (fft_cnt_w > 4);
  assign fft_d00 = {stage4_real_w[ 0][115], stage4_real_w[ 0][62:56], stage4_real_w[ 0][55:48], 
                    stage4_imag_w[ 0][115], stage4_imag_w[ 0][62:56], stage4_imag_w[ 0][55:48]};
  assign fft_d01 = {stage4_real_w[ 1][115], stage4_real_w[ 1][62:56], stage4_real_w[ 1][55:48], 
                    stage4_imag_w[ 1][115], stage4_imag_w[ 1][62:56], stage4_imag_w[ 1][55:48]};
  assign fft_d02 = {stage4_real_w[ 2][115], stage4_real_w[ 2][62:56], stage4_real_w[ 2][55:48], 
                    stage4_imag_w[ 2][115], stage4_imag_w[ 2][62:56], stage4_imag_w[ 2][55:48]};
  assign fft_d03 = {stage4_real_w[ 3][115], stage4_real_w[ 3][62:56], stage4_real_w[ 3][55:48], 
                    stage4_imag_w[ 3][115], stage4_imag_w[ 3][62:56], stage4_imag_w[ 3][55:48]};
  assign fft_d04 = {stage4_real_w[ 4][115], stage4_real_w[ 4][62:56], stage4_real_w[ 4][55:48], 
                    stage4_imag_w[ 4][115], stage4_imag_w[ 4][62:56], stage4_imag_w[ 4][55:48]};
  assign fft_d05 = {stage4_real_w[ 5][115], stage4_real_w[ 5][62:56], stage4_real_w[ 5][55:48], 
                    stage4_imag_w[ 5][115], stage4_imag_w[ 5][62:56], stage4_imag_w[ 5][55:48]};
  assign fft_d06 = {stage4_real_w[ 6][115], stage4_real_w[ 6][62:56], stage4_real_w[ 6][55:48], 
                    stage4_imag_w[ 6][115], stage4_imag_w[ 6][62:56], stage4_imag_w[ 6][55:48]};
  assign fft_d07 = {stage4_real_w[ 7][115], stage4_real_w[ 7][62:56], stage4_real_w[ 7][55:48], 
                    stage4_imag_w[ 7][115], stage4_imag_w[ 7][62:56], stage4_imag_w[ 7][55:48]};
  assign fft_d08 = {stage4_real_w[ 8][115], stage4_real_w[ 8][62:56], stage4_real_w[ 8][55:48], 
                    stage4_imag_w[ 8][115], stage4_imag_w[ 8][62:56], stage4_imag_w[ 8][55:48]};
  assign fft_d09 = {stage4_real_w[ 9][115], stage4_real_w[ 9][62:56], stage4_real_w[ 9][55:48], 
                    stage4_imag_w[ 9][115], stage4_imag_w[ 9][62:56], stage4_imag_w[ 9][55:48]};
  assign fft_d10 = {stage4_real_w[10][115], stage4_real_w[10][62:56], stage4_real_w[10][55:48], 
                    stage4_imag_w[10][115], stage4_imag_w[10][62:56], stage4_imag_w[10][55:48]};
  assign fft_d11 = {stage4_real_w[11][115], stage4_real_w[11][62:56], stage4_real_w[11][55:48], 
                    stage4_imag_w[11][115], stage4_imag_w[11][62:56], stage4_imag_w[11][55:48]};
  assign fft_d12 = {stage4_real_w[12][115], stage4_real_w[12][62:56], stage4_real_w[12][55:48], 
                    stage4_imag_w[12][115], stage4_imag_w[12][62:56], stage4_imag_w[12][55:48]};
  assign fft_d13 = {stage4_real_w[13][115], stage4_real_w[13][62:56], stage4_real_w[13][55:48], 
                    stage4_imag_w[13][115], stage4_imag_w[13][62:56], stage4_imag_w[13][55:48]};
  assign fft_d14 = {stage4_real_w[14][115], stage4_real_w[14][62:56], stage4_real_w[14][55:48], 
                    stage4_imag_w[14][115], stage4_imag_w[14][62:56], stage4_imag_w[14][55:48]};
  assign fft_d15 = {stage4_real_w[15][115], stage4_real_w[15][62:56], stage4_real_w[15][55:48], 
                    stage4_imag_w[15][115], stage4_imag_w[15][62:56], stage4_imag_w[15][55:48]};

  /* ============================================ */
  always@ (*) begin
    fft_cnt_w = fft_cnt_r;
    for (i = 0; i < 8; i = i + 1) begin 
      W_REAL_w[i] = W_REAL_r[i];
      W_IMAG_w[i] = W_IMAG_r[i];
    end
    for (i = 0; i < 16; i = i + 1) begin 
      stage1_real_w[i] = stage1_real_r[i];
      stage2_real_w[i] = stage2_real_r[i];
      stage3_real_w[i] = stage3_real_r[i];
      stage4_real_w[i] = stage4_real_r[i];
      stage1_imag_w[i] = stage1_imag_r[i];
      stage2_imag_w[i] = stage2_imag_r[i];
      stage3_imag_w[i] = stage3_imag_r[i];
      stage4_imag_w[i] = stage4_imag_r[i];
    end

    if (stp_valid) begin
      fft_cnt_w = (fft_cnt_r > 4 ? 0 : fft_cnt_r + 1);

      // STAGE 1:



      // STAGE 2:

      // STAGE 3:

      // STAGE 4:

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
        stage1_real_r[i] <= 0;
        stage2_real_r[i] <= 0;
        stage3_real_r[i] <= 0;
        stage4_real_r[i] <= 0;
        stage1_imag_r[i] <= 0;
        stage2_imag_r[i] <= 0;
        stage3_imag_r[i] <= 0;
        stage4_imag_r[i] <= 0;
      end
      fft_cnt_r <= 0;
    end else begin 
      for (i = 0; i < 8; i = i + 1) begin 
        W_REAL_r[i] <= W_REAL_w[i];
        W_IMAG_r[i] <= W_IMAG_w[i];
      end
      for (i = 0; i < 16; i = i + 1) begin 
        stage1_real_r[i] <= stage1_real_w[i];
        stage2_real_r[i] <= stage2_real_w[i];
        stage3_real_r[i] <= stage3_real_w[i];
        stage4_real_r[i] <= stage4_real_w[i];
        stage1_imag_r[i] <= stage1_imag_w[i];
        stage2_imag_r[i] <= stage2_imag_w[i];
        stage3_imag_r[i] <= stage3_imag_w[i];
        stage4_imag_r[i] <= stage4_imag_w[i];
      end
      fft_cnt_r <= fft_cnt_w;      
    end
  end 

endmodule

/****************************************************************
  ANALYST
*****************************************************************/




/*
  reg [115:0] stage1_real_00_r, stage1_real_01_r, stage1_real_02_r, stage1_real_03_r, 
              stage1_real_04_r, stage1_real_05_r, stage1_real_06_r, stage1_real_07_r, 
              stage1_real_08_r, stage1_real_09_r, stage1_real_10_r, stage1_real_11_r, 
              stage1_real_12_r, stage1_real_13_r, stage1_real_14_r, stage1_real_15_r, 
              stage1_real_00_w, stage1_real_01_w, stage1_real_02_w, stage1_real_03_w, 
              stage1_real_04_w, stage1_real_05_w, stage1_real_06_w, stage1_real_07_w, 
              stage1_real_08_w, stage1_real_09_w, stage1_real_10_w, stage1_real_11_w, 
              stage1_real_12_w, stage1_real_13_w, stage1_real_14_w, stage1_real_15_w;
  reg [115:0] stage2_real_00_r, stage2_real_01_r, stage2_real_02_r, stage2_real_03_r, 
              stage2_real_04_r, stage2_real_05_r, stage2_real_06_r, stage2_real_07_r, 
              stage2_real_08_r, stage2_real_09_r, stage2_real_10_r, stage2_real_11_r, 
              stage2_real_12_r, stage2_real_13_r, stage2_real_14_r, stage2_real_15_r, 
              stage2_real_00_w, stage2_real_01_w, stage2_real_02_w, stage2_real_03_w, 
              stage2_real_04_w, stage2_real_05_w, stage2_real_06_w, stage2_real_07_w, 
              stage2_real_08_w, stage2_real_09_w, stage2_real_10_w, stage2_real_11_w, 
              stage2_real_12_w, stage2_real_13_w, stage2_real_14_w, stage2_real_15_w;
  reg [115:0] stage3_real_00_r, stage3_real_01_r, stage3_real_02_r, stage3_real_03_r, 
              stage3_real_04_r, stage3_real_05_r, stage3_real_06_r, stage3_real_07_r, 
              stage3_real_08_r, stage3_real_09_r, stage3_real_10_r, stage3_real_11_r, 
              stage3_real_12_r, stage3_real_13_r, stage3_real_14_r, stage3_real_15_r, 
              stage3_real_00_w, stage3_real_01_w, stage3_real_02_w, stage3_real_03_w, 
              stage3_real_04_w, stage3_real_05_w, stage3_real_06_w, stage3_real_07_w, 
              stage3_real_08_w, stage3_real_09_w, stage3_real_10_w, stage3_real_11_w, 
              stage3_real_12_w, stage3_real_13_w, stage3_real_14_w, stage3_real_15_w;
  reg [115:0] stage4_real_00_r, stage4_real_01_r, stage4_real_02_r, stage4_real_03_r, 
              stage4_real_04_r, stage4_real_05_r, stage4_real_06_r, stage4_real_07_r, 
              stage4_real_08_r, stage4_real_09_r, stage4_real_10_r, stage4_real_11_r, 
              stage4_real_12_r, stage4_real_13_r, stage4_real_14_r, stage4_real_15_r, 
              stage4_real_00_w, stage4_real_01_w, stage4_real_02_w, stage4_real_03_w, 
              stage4_real_04_w, stage4_real_05_w, stage4_real_06_w, stage4_real_07_w, 
              stage4_real_08_w, stage4_real_09_w, stage4_real_10_w, stage4_real_11_w, 
              stage4_real_12_w, stage4_real_13_w, stage4_real_14_w, stage4_real_15_w;

  reg [115:0] stage1_imag_00_r, stage1_imag_01_r, stage1_imag_02_r, stage1_imag_03_r, 
              stage1_imag_04_r, stage1_imag_05_r, stage1_imag_06_r, stage1_imag_07_r, 
              stage1_imag_08_r, stage1_imag_09_r, stage1_imag_10_r, stage1_imag_11_r, 
              stage1_imag_12_r, stage1_imag_13_r, stage1_imag_14_r, stage1_imag_15_r, 
              stage1_imag_00_w, stage1_imag_01_w, stage1_imag_02_w, stage1_imag_03_w, 
              stage1_imag_04_w, stage1_imag_05_w, stage1_imag_06_w, stage1_imag_07_w, 
              stage1_imag_08_w, stage1_imag_09_w, stage1_imag_10_w, stage1_imag_11_w, 
              stage1_imag_12_w, stage1_imag_13_w, stage1_imag_14_w, stage1_imag_15_w;
  reg [115:0] stage2_imag_00_r, stage2_imag_01_r, stage2_imag_02_r, stage2_imag_03_r, 
              stage2_imag_04_r, stage2_imag_05_r, stage2_imag_06_r, stage2_imag_07_r, 
              stage2_imag_08_r, stage2_imag_09_r, stage2_imag_10_r, stage2_imag_11_r, 
              stage2_imag_12_r, stage2_imag_13_r, stage2_imag_14_r, stage2_imag_15_r, 
              stage2_imag_00_w, stage2_imag_01_w, stage2_imag_02_w, stage2_imag_03_w, 
              stage2_imag_04_w, stage2_imag_05_w, stage2_imag_06_w, stage2_imag_07_w, 
              stage2_imag_08_w, stage2_imag_09_w, stage2_imag_10_w, stage2_imag_11_w, 
              stage2_imag_12_w, stage2_imag_13_w, stage2_imag_14_w, stage2_imag_15_w;
  reg [115:0] stage3_imag_00_r, stage3_imag_01_r, stage3_imag_02_r, stage3_imag_03_r, 
              stage3_imag_04_r, stage3_imag_05_r, stage3_imag_06_r, stage3_imag_07_r, 
              stage3_imag_08_r, stage3_imag_09_r, stage3_imag_10_r, stage3_imag_11_r, 
              stage3_imag_12_r, stage3_imag_13_r, stage3_imag_14_r, stage3_imag_15_r, 
              stage3_imag_00_w, stage3_imag_01_w, stage3_imag_02_w, stage3_imag_03_w, 
              stage3_imag_04_w, stage3_imag_05_w, stage3_imag_06_w, stage3_imag_07_w, 
              stage3_imag_08_w, stage3_imag_09_w, stage3_imag_10_w, stage3_imag_11_w, 
              stage3_imag_12_w, stage3_imag_13_w, stage3_imag_14_w, stage3_imag_15_w;
  reg [115:0] stage4_imag_00_r, stage4_imag_01_r, stage4_imag_02_r, stage4_imag_03_r, 
              stage4_imag_04_r, stage4_imag_05_r, stage4_imag_06_r, stage4_imag_07_r, 
              stage4_imag_08_r, stage4_imag_09_r, stage4_imag_10_r, stage4_imag_11_r, 
              stage4_imag_12_r, stage4_imag_13_r, stage4_imag_14_r, stage4_imag_15_r, 
              stage4_imag_00_w, stage4_imag_01_w, stage4_imag_02_w, stage4_imag_03_w, 
              stage4_imag_04_w, stage4_imag_05_w, stage4_imag_06_w, stage4_imag_07_w, 
              stage4_imag_08_w, stage4_imag_09_w, stage4_imag_10_w, stage4_imag_11_w, 
              stage4_imag_12_w, stage4_imag_13_w, stage4_imag_14_w, stage4_imag_15_w;
*/

