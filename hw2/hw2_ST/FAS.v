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

  always@ (posedge clk or negedge rst) begin 
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

  always@ (*) begin


  end

  always@ (posedge clk or posedge rst) begin 
    if (rst) begin

    end else begin
    
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

