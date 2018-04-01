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

  FIR_FILTER fir(
    .clk(clk), 
    .rst(rst),
    .data_valid(data_valid),
    .data(data),
    .fir_valid(fir_valid),
    .fir_d(fir_d)
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
  input fir_valid;
  output signed [15:0] fir_d;

  `include "./dat/FIR_coefficient.dat"

  reg [5:0] fir_cnt_r, fir_cnt_w;
  reg signed [15:0] x_00_r, x_01_r, x_02_r, x_03_r, x_04_r, x_05_r, x_06_r, x_07_r,
                    x_08_r, x_09_r, x_10_r, x_11_r, x_12_r, x_13_r, x_14_r, x_15_r,
                    x_16_r, x_17_r, x_18_r, x_19_r, x_20_r, x_21_r, x_22_r, x_23_r,
                    x_24_r, x_25_r, x_26_r, x_27_r, x_28_r, x_29_r, x_30_r, x_31_r;
  reg signed [15:0] x_00_w, x_01_w, x_02_w, x_03_w, x_04_w, x_05_w, x_06_w, x_07_w,
                    x_08_w, x_09_w, x_10_w, x_11_w, x_12_w, x_13_w, x_14_w, x_15_w,
                    x_16_w, x_17_w, x_18_w, x_19_w, x_20_w, x_21_w, x_22_w, x_23_w,
                    x_24_w, x_25_w, x_26_w, x_27_w, x_28_w, x_29_w, x_30_w, x_31_w;

  reg signed [66:0] sum_r, sum_w;

  assign fir_valid = (fir_cnt_w > 32);
  assign fir_d = {sum_w[66], sum_w[30:24], sum_w[23:16]};

  always@ (*) begin
    x_00_w   = x_00_r; 
    x_01_w   = x_01_r; 
    x_02_w   = x_02_r; 
    x_03_w   = x_03_r; 
    x_04_w   = x_04_r;  
    x_05_w   = x_05_r;  
    x_06_w   = x_06_r;  
    x_07_w   = x_07_r;  
    x_08_w   = x_08_r;  
    x_09_w   = x_09_r;  
    x_10_w   = x_10_r;  
    x_11_w   = x_11_r;  
    x_12_w   = x_12_r;  
    x_13_w   = x_13_r;  
    x_14_w   = x_14_r;  
    x_15_w   = x_15_r;  
    x_16_w   = x_16_r;  
    x_17_w   = x_17_r;  
    x_18_w   = x_18_r;  
    x_19_w   = x_19_r;  
    x_20_w   = x_20_r;  
    x_21_w   = x_21_r;  
    x_22_w   = x_22_r;  
    x_23_w   = x_23_r;  
    x_24_w   = x_24_r;  
    x_25_w   = x_25_r;  
    x_26_w   = x_26_r;  
    x_27_w   = x_27_r;  
    x_28_w   = x_28_r;  
    x_29_w   = x_29_r;  
    x_30_w   = x_30_r;  
    x_31_w   = x_31_r;  
    sum_w    = sum_r;
    fir_cnt_w = fir_cnt_r;

    if (data_valid) begin
      fir_cnt_w = (fir_cnt_r > 32 ? 33 : fir_cnt_r + 1);
      x_31_w = data;
      x_30_w = data;
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
            + data * FIR_C00 
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
      sum_r     <= 0;
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
  SERIAL_TO_PARALLEL
*****************************************************************/



/****************************************************************
  FFT
*****************************************************************/


/****************************************************************
  ANALYST
*****************************************************************/

