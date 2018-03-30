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

  assign fir_valid = (fir_cnt_w == 32);

  reg signed [15:0] x_0_r, x_1_r, x_2_r, x_3_r, x_4_r, x_5_r, x_6_r, x_7_r,
                    x_8_r, x_9_r, x_10_r, x_11_r, x_12_r, x_13_r, x_14_r, x_15_r,
                    x_16_r, x_17_r, x_18_r, x_19_r, x_20_r, x_21_r, x_22_r, x_23_r,
                    x_24_r, x_25_r, x_26_r, x_27_r, x_28_r, x_29_r, x_30_r, x_31_r;
  reg signed [15:0] x_0_w, x_1_w, x_2_w, x_3_w, x_4_w, x_5_w, x_6_w, x_7_w,
                    x_8_w, x_9_w, x_10_w, x_11_w, x_12_w, x_13_w, x_14_w, x_15_w,
                    x_16_w, x_17_w, x_18_w, x_19_w, x_20_w, x_21_w, x_22_w, x_23_w,
                    x_24_w, x_25_w, x_26_w, x_27_w, x_28_w, x_29_w, x_30_w, x_31_w;

  reg signed [66:0] sum_0_r, sum_1_r, sum_2_r, sum_3_r, sum_4_r, sum_5_r, sum_6_r, sum_7_r,
                    sum_8_r, sum_9_r, sum_10_r, sum_11_r, sum_12_r, sum_13_r, sum_14_r, sum_15_r,
                    sum_16_r, sum_17_r, sum_18_r, sum_19_r, sum_20_r, sum_21_r, sum_22_r, sum_23_r,
                    sum_24_r, sum_25_r, sum_26_r, sum_27_r, sum_28_r, sum_29_r, sum_30_r, sum_31_r;
  reg signed [66:0] sum_0_w, sum_1_w, sum_2_w, sum_3_w, sum_4_w, sum_5_w, sum_6_w, sum_7_w,
                    sum_8_w, sum_9_w, sum_10_w, sum_11_w, sum_12_w, sum_13_w, sum_14_w, sum_15_w,
                    sum_16_w, sum_17_w, sum_18_w, sum_19_w, sum_20_w, sum_21_w, sum_22_w, sum_23_w,
                    sum_24_w, sum_25_w, sum_26_w, sum_27_w, sum_28_w, sum_29_w, sum_30_w, sum_31_w;

  always@ (*) begin
    x_0_w    = x_0_r; 
    x_1_w    = x_1_r; 
    x_2_w    = x_2_r; 
    x_3_w    = x_3_r; 
    x_4_w    = x_4_r;  
    x_5_w    = x_5_r;  
    x_6_w    = x_6_r;  
    x_7_w    = x_7_r;  
    x_8_w    = x_8_r;  
    x_9_w    = x_9_r;  
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
    sum_0_w  = sum_0_r; 
    sum_1_w  = sum_1_r; 
    sum_2_w  = sum_2_r; 
    sum_3_w  = sum_3_r; 
    sum_4_w  = sum_4_r; 
    sum_5_w  = sum_5_r; 
    sum_6_w  = sum_6_r; 
    sum_7_w  = sum_7_r; 
    sum_8_w  = sum_8_r; 
    sum_9_w  = sum_9_r; 
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

    if (data_valid) begin
      fir_cnt_w = (fir_cnt_r >= 32 ? 32 : fir_cnt_r + 1);
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
      x_9_w  = x_10_r;
      x_8_w  = x_9_r;
      x_7_w  = x_8_r;
      x_6_w  = x_7_r;
      x_5_w  = x_6_r;
      x_4_w  = x_5_r;
      x_3_w  = x_4_r;
      x_2_w  = x_3_r;
      x_1_w  = x_2_r;
      x_0_w  = x_1_r;

      sum_0_w  = x_31_r * FIR_C00;
      sum_1_w  = x_30_r * FIR_C01;
      sum_2_w  = x_29_r * FIR_C02;
      sum_3_w  = x_28_r * FIR_C03;
      sum_4_w  = x_27_r * FIR_C04;
      sum_5_w  = x_26_r * FIR_C05;
      sum_6_w  = x_25_r * FIR_C06;
      sum_7_w  = x_24_r * FIR_C07;
      sum_8_w  = x_23_r * FIR_C08;
      sum_9_w  = x_22_r * FIR_C09;
      sum_10_w = x_21_r * FIR_C10;
      sum_11_w = x_20_r * FIR_C11;
      sum_12_w = x_19_r * FIR_C12;
      sum_13_w = x_18_r * FIR_C13;
      sum_14_w = x_17_r * FIR_C14;
      sum_15_w = x_16_r * FIR_C15;
      sum_16_w = x_15_r * FIR_C16;
      sum_17_w = x_14_r * FIR_C17;
      sum_18_w = x_13_r * FIR_C18;
      sum_19_w = x_12_r * FIR_C19;
      sum_20_w = x_11_r * FIR_C20;
      sum_21_w = x_10_r * FIR_C21;
      sum_22_w = x_9_r  * FIR_C22;
      sum_23_w = x_8_r  * FIR_C23;
      sum_24_w = x_7_r  * FIR_C24;
      sum_25_w = x_6_r  * FIR_C25;
      sum_26_w = x_5_r  * FIR_C26;
      sum_27_w = x_4_r  * FIR_C27;
      sum_28_w = x_3_r  * FIR_C28;
      sum_29_w = x_2_r  * FIR_C29;
      sum_30_w = x_1_r  * FIR_C30;
      sum_31_w = x_0_r  * FIR_C31;

    end else begin 
      fir_cnt_w = 0;
    end
  end

  always@ (posedge clk or posedge rst) begin 
    if (rst) begin
      x_0_r     <= 15'b0;
      x_1_r     <= 15'b0;
      x_2_r     <= 15'b0;
      x_3_r     <= 15'b0;
      x_4_r     <= 15'b0;
      x_5_r     <= 15'b0;
      x_6_r     <= 15'b0;
      x_7_r     <= 15'b0;
      x_8_r     <= 15'b0;
      x_9_r     <= 15'b0;
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
      sum_0_r   <= 66'b0;
      sum_1_r   <= 66'b0;
      sum_2_r   <= 66'b0;
      sum_3_r   <= 66'b0;
      sum_4_r   <= 66'b0;
      sum_5_r   <= 66'b0;
      sum_6_r   <= 66'b0;
      sum_7_r   <= 66'b0;
      sum_8_r   <= 66'b0;
      sum_9_r   <= 66'b0;
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
    end else begin
      x_0_r     <= x_0_w;   
      x_1_r     <= x_1_w;   
      x_2_r     <= x_2_w;   
      x_3_r     <= x_3_w;   
      x_4_r     <= x_4_w;   
      x_5_r     <= x_5_w;   
      x_6_r     <= x_6_w;   
      x_7_r     <= x_7_w;   
      x_8_r     <= x_8_w;   
      x_9_r     <= x_9_w;   
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
      sum_0_r   <= sum_0_w; 
      sum_1_r   <= sum_1_w; 
      sum_2_r   <= sum_2_w; 
      sum_3_r   <= sum_3_w; 
      sum_4_r   <= sum_4_w; 
      sum_5_r   <= sum_5_w; 
      sum_6_r   <= sum_6_w; 
      sum_7_r   <= sum_7_w; 
      sum_8_r   <= sum_8_w; 
      sum_9_r   <= sum_9_w; 
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

