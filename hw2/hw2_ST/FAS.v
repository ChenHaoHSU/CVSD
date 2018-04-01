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
  input [15:0] data;
  input fir_valid;
  output [15:0] fir_d;

  `include "./dat/FIR_coefficient.dat"

  reg [5:0] fir_cnt_r, fir_cnt_w;
  reg signed [15:0] data_r, data_w;

  reg signed [15:0] x_00_r, x_01_r, x_02_r, x_03_r, x_04_r, x_05_r, x_06_r, x_07_r,
                    x_08_r, x_09_r, x_10_r, x_11_r, x_12_r, x_13_r, x_14_r, x_15_r,
                    x_16_r, x_17_r, x_18_r, x_19_r, x_20_r, x_21_r, x_22_r, x_23_r,
                    x_24_r, x_25_r, x_26_r, x_27_r, x_28_r, x_29_r, x_30_r, x_31_r;
  reg signed [15:0] x_00_w, x_01_w, x_02_w, x_03_w, x_04_w, x_05_w, x_06_w, x_07_w,
                    x_08_w, x_09_w, x_10_w, x_11_w, x_12_w, x_13_w, x_14_w, x_15_w,
                    x_16_w, x_17_w, x_18_w, x_19_w, x_20_w, x_21_w, x_22_w, x_23_w,
                    x_24_w, x_25_w, x_26_w, x_27_w, x_28_w, x_29_w, x_30_w, x_31_w;

  reg signed [66:0] sum_00_r, sum_01_r, sum_02_r, sum_03_r, sum_04_r, sum_05_r, sum_06_r, sum_07_r,
                    sum_08_r, sum_09_r, sum_10_r, sum_11_r, sum_12_r, sum_13_r, sum_14_r, sum_15_r,
                    sum_16_r, sum_17_r, sum_18_r, sum_19_r, sum_20_r, sum_21_r, sum_22_r, sum_23_r,
                    sum_24_r, sum_25_r, sum_26_r, sum_27_r, sum_28_r, sum_29_r, sum_30_r, sum_31_r;
  reg signed [66:0] sum_00_w, sum_01_w, sum_02_w, sum_03_w, sum_04_w, sum_05_w, sum_06_w, sum_07_w,
                    sum_08_w, sum_09_w, sum_10_w, sum_11_w, sum_12_w, sum_13_w, sum_14_w, sum_15_w,
                    sum_16_w, sum_17_w, sum_18_w, sum_19_w, sum_20_w, sum_21_w, sum_22_w, sum_23_w,
                    sum_24_w, sum_25_w, sum_26_w, sum_27_w, sum_28_w, sum_29_w, sum_30_w, sum_31_w;

  assign fir_valid = (fir_cnt_w > 32);
  assign fir_d = {sum_31_w[66], sum_31_w[30:24], sum_31_w[23:16]};

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
    sum_00_w = sum_00_r; 
    sum_01_w = sum_01_r; 
    sum_02_w = sum_02_r; 
    sum_03_w = sum_03_r; 
    sum_04_w = sum_04_r; 
    sum_05_w = sum_05_r; 
    sum_06_w = sum_06_r; 
    sum_07_w = sum_07_r; 
    sum_08_w = sum_08_r; 
    sum_09_w = sum_09_r; 
    sum_10_w = sum_10_r;
    sum_11_w = sum_11_r;
    sum_12_w = sum_12_r;
    sum_13_w = sum_13_r;
    sum_14_w = sum_14_r;
    sum_15_w = sum_15_r;
    sum_16_w = sum_16_r;
    sum_17_w = sum_17_r;
    sum_18_w = sum_18_r;
    sum_19_w = sum_19_r;
    sum_20_w = sum_20_r;
    sum_21_w = sum_21_r;
    sum_22_w = sum_22_r;
    sum_23_w = sum_23_r;
    sum_24_w = sum_24_r;
    sum_25_w = sum_25_r;
    sum_26_w = sum_26_r;
    sum_27_w = sum_27_r;
    sum_28_w = sum_28_r;
    sum_29_w = sum_29_r;
    sum_30_w = sum_30_r;
    sum_31_w = sum_31_r;
    fir_cnt_w = fir_cnt_r;
    data_w    = data_r;

    if (data_valid) begin
      fir_cnt_w = (fir_cnt_r > 32 ? 33 : fir_cnt_r + 1);
      data_w = data;
      x_31_w = data_r;
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

      sum_00_w = x_31_r * FIR_C00 + 0;
      sum_01_w = x_30_r * FIR_C01 + sum_00_r;
      sum_02_w = x_29_r * FIR_C02 + sum_01_r;
      sum_03_w = x_28_r * FIR_C03 + sum_02_r;
      sum_04_w = x_27_r * FIR_C04 + sum_03_r;
      sum_05_w = x_26_r * FIR_C05 + sum_04_r;
      sum_06_w = x_25_r * FIR_C06 + sum_05_r;
      sum_07_w = x_24_r * FIR_C07 + sum_06_r;
      sum_08_w = x_23_r * FIR_C08 + sum_07_r;
      sum_09_w = x_22_r * FIR_C09 + sum_08_r;
      sum_10_w = x_21_r * FIR_C10 + sum_09_r;
      sum_11_w = x_20_r * FIR_C11 + sum_10_r;
      sum_12_w = x_19_r * FIR_C12 + sum_11_r;
      sum_13_w = x_18_r * FIR_C13 + sum_12_r;
      sum_14_w = x_17_r * FIR_C14 + sum_13_r;
      sum_15_w = x_16_r * FIR_C15 + sum_14_r;
      sum_16_w = x_15_r * FIR_C16 + sum_15_r;
      sum_17_w = x_14_r * FIR_C17 + sum_16_r;
      sum_18_w = x_13_r * FIR_C18 + sum_17_r;
      sum_19_w = x_12_r * FIR_C19 + sum_18_r;
      sum_20_w = x_11_r * FIR_C20 + sum_19_r;
      sum_21_w = x_10_r * FIR_C21 + sum_20_r;
      sum_22_w = x_09_r * FIR_C22 + sum_21_r;
      sum_23_w = x_08_r * FIR_C23 + sum_22_r;
      sum_24_w = x_07_r * FIR_C24 + sum_23_r;
      sum_25_w = x_06_r * FIR_C25 + sum_24_r;
      sum_26_w = x_05_r * FIR_C26 + sum_25_r;
      sum_27_w = x_04_r * FIR_C27 + sum_26_r;
      sum_28_w = x_03_r * FIR_C28 + sum_27_r;
      sum_29_w = x_02_r * FIR_C29 + sum_28_r;
      sum_30_w = x_01_r * FIR_C30 + sum_29_r;
      sum_31_w = x_00_r * FIR_C31 + sum_30_r;

    end else begin 
      fir_cnt_w = 0;
      data_w    = 0;
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
      sum_00_r  <= 66'b0;
      sum_01_r  <= 66'b0;
      sum_02_r  <= 66'b0;
      sum_03_r  <= 66'b0;
      sum_04_r  <= 66'b0;
      sum_05_r  <= 66'b0;
      sum_06_r  <= 66'b0;
      sum_07_r  <= 66'b0;
      sum_08_r  <= 66'b0;
      sum_09_r  <= 66'b0;
      sum_10_r  <= 66'b0;
      sum_11_r  <= 66'b0;
      sum_12_r  <= 66'b0;
      sum_13_r  <= 66'b0;
      sum_14_r  <= 66'b0;
      sum_15_r  <= 66'b0;
      sum_16_r  <= 66'b0;
      sum_17_r  <= 66'b0;
      sum_18_r  <= 66'b0;
      sum_19_r  <= 66'b0;
      sum_20_r  <= 66'b0;
      sum_21_r  <= 66'b0;
      sum_22_r  <= 66'b0;
      sum_23_r  <= 66'b0;
      sum_24_r  <= 66'b0;
      sum_25_r  <= 66'b0;
      sum_26_r  <= 66'b0;
      sum_27_r  <= 66'b0;
      sum_28_r  <= 66'b0;
      sum_29_r  <= 66'b0;
      sum_30_r  <= 66'b0;
      sum_31_r  <= 66'b0;
      fir_cnt_r <= 6'b0;
      data_r    <= 15'b0;
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
      sum_00_r  <= sum_00_w; 
      sum_01_r  <= sum_01_w; 
      sum_02_r  <= sum_02_w; 
      sum_03_r  <= sum_03_w; 
      sum_04_r  <= sum_04_w; 
      sum_05_r  <= sum_05_w; 
      sum_06_r  <= sum_06_w; 
      sum_07_r  <= sum_07_w; 
      sum_08_r  <= sum_08_w; 
      sum_09_r  <= sum_09_w; 
      sum_10_r  <= sum_10_w;
      sum_11_r  <= sum_11_w;
      sum_12_r  <= sum_12_w;
      sum_13_r  <= sum_13_w;
      sum_14_r  <= sum_14_w;
      sum_15_r  <= sum_15_w;
      sum_16_r  <= sum_16_w;
      sum_17_r  <= sum_17_w;
      sum_18_r  <= sum_18_w;
      sum_19_r  <= sum_19_w;
      sum_20_r  <= sum_20_w;
      sum_21_r  <= sum_21_w;
      sum_22_r  <= sum_22_w;
      sum_23_r  <= sum_23_w;
      sum_24_r  <= sum_24_w;
      sum_25_r  <= sum_25_w;
      sum_26_r  <= sum_26_w;
      sum_27_r  <= sum_27_w;
      sum_28_r  <= sum_28_w;
      sum_29_r  <= sum_29_w;
      sum_30_r  <= sum_30_w;
      sum_31_r  <= sum_31_w;
      fir_cnt_r <= fir_cnt_w;
      data_r    <= data_w;
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

