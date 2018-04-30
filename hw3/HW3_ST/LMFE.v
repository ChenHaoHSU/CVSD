/****************************************************************
  Top Module
*****************************************************************/
module LMFE (
  clk,
  reset,
  Din,
  in_en,
  busy,
  out_valid,
  Dout
);

input         clk;
input         reset;
input  [7:0]	Din;
input         in_en;
output        busy;
output        out_valid;
output [7:0]	Dout;

wire [9:0] sram_addr;
wire [7:0] sram_d;
wire [7:0] sram_q;
wire       sram_cen;
wire       sram_wen;

wire [7:0] sort_insert;
wire [7:0] sort_delete;
wire [7:0] sort_median;
wire       sort_enable;

controller lmfe_controller (
  .CLK	(clk),
  .RST	(reset),
  .IEN	(in_en),
  .DIN	(Din),
  .Q		(sram_q),
  .MED	(sort_median),
  .A    (sram_addr),
  .D    (sram_d),	
  .CE   (sram_cen),
  .WE   (sram_wen),
  .SE   (sort_enable),
  .INS  (sort_insert),
  .DEL  (sort_delete),
  .DOUT	(Dout),
  .OV   (out_valid),
  .BZ   (busy)
);

sorter lmfe_sorter (
  .CLK (clk),
  .RST (reset),
  .SEN (sort_enable),
  .INS (sort_insert),
  .DEL (sort_delete),
  .MED (sort_median)
);

sram_1024x8_t13 lmfe_sram (
  .CLK (clk),
  .CEN (sram_cen),
  .WEN (sram_wen),
  .A   (sram_addr),
  .D   (sram_d),
  .Q   (sram_q)
);

endmodule

/****************************************************************
  Controller
*****************************************************************/
module controller (
  CLK,
  RST,
  IEN,
  DIN,
  Q,
  MED,
  A,
  D,
  CE,
  WE,
  SE,
  INS,
  DEL,
  DOUT,
  OV,
  BZ
);

//-- I/O declaration
input        CLK;
input        RST;
input        IEN;
input  [7:0] DIN;
input  [7:0] Q;
input  [7:0] MED;
output [9:0] A;
output [7:0] D;
output       CE;
output       WE;
output       SE;
output [7:0] INS;
output [7:0] DEL;
output [7:0] DOUT;
output       OV;
output       BZ;

//-- parameters
parameter ST_IDL = 4'h0;
parameter ST_W7L = 4'h1;
parameter ST_R49 = 4'h2;
parameter ST_R7R = 4'h3;
parameter ST_W1L = 4'h4;
parameter ST_R7D = 4'h5;
parameter ST_R7L = 4'h6;
parameter ST_O1LU = 4'h7;
parameter ST_W1LU = 4'h8;
parameter ST_R7DU = 4'h9;
parameter ST_END = 4'ha;

//-- reg and wire
reg [9:0] a_r;
reg [7:0] d_r;
reg       ce_r;
reg       we_r;
reg       se_r;
reg [7:0] ins_r;
reg [7:0] del_r;
reg [7:0] dout_r;
reg       ov_r;
reg       bz_r;
reg [7:0] i;

reg [7:0] dout_w;
reg       bz_w;
reg       ov_w;
reg [9:0] a_w;
reg [7:0] d_w;
reg       ce_w;
reg       we_w;
reg       se_w;
reg [7:0] ins_w;
reg [7:0] del_w;

reg [3:0] state_r, state_w;
reg [9:0] wa_r, wa_w;
reg [9:0] wc_r, wc_w;
reg [5:0] rc_r, rc_w;
reg [7:0] lc_r, lc_w;
reg [13:0] pc_r, pc_w;
reg [7:0] px_r, px_w;
reg [7:0] py_r, py_w;
reg [7:0] mv_r [0:48];
reg [7:0] mv_w [0:48];
reg [7:0] mx [0:48];
reg [7:0] my [0:48];
reg [7:0] ix [0:48];
reg [7:0] iy [0:48];
reg       noob [0:48];
reg [7:0]	med_buf_r [0:126];
reg [7:0]	med_buf_w [0:126];

assign DOUT = dout_r;
assign BZ   = bz_r;
assign OV   = ov_r;
assign A    = a_r;
assign D    = d_r;
assign CE   = ce_r;
assign WE   = we_r;
assign SE   = se_r;
assign INS  = ins_r;
assign DEL  = del_r;

always @(*) begin
  state_w = state_r;//
  dout_w  = dout_r;
  bz_w    = bz_r;
  ov_w    = ov_r;
  a_w     = a_r;
  d_w     = d_r;
  ce_w    = ce_r;
  we_w    = we_r;
  se_w    = se_r;
  ins_w   = ins_r;
  del_w   = del_r;//
  wa_w    = wa_r;
  wc_w    = wc_r;
  rc_w    = rc_r;
  lc_w    = lc_r;
  pc_w    = pc_r;
  px_w    = px_r;
  py_w    = py_r;//
  for (i = 0; i < 49; i = i + 1) begin
    mv_w[i] = mv_r[i];
  end
  case (state_r)
    ST_IDL: begin
      if (IEN) begin
        state_w = ST_W7L;
        a_w     = wa_r;
        d_w     = DIN;
        ce_w    = 0;
        we_w    = 0;
        wa_w    = wa_r + 1;
        wc_w    = 0;
      end else begin
        state_w = ST_IDL;
      end
    end
    ST_W7L: begin
      if (wc_r < 895) begin
        state_w = ST_W7L;
        bz_w    = (wc_r == 894) ? 1 : 0;
        a_w     = wa_r;
        d_w     = DIN;
        wa_w    = wa_r + 1;
        wc_w    = wc_r + 1;
      end else begin
        state_w = ST_R49;
        ce_w    = 0;
        we_w    = 1;
        rc_w    = 0;
      end
    end
    ST_R49: begin
      if (rc_r < 51) begin
        state_w = ST_R49;
        a_w     = (rc_r < 49) ? ((my[rc_r] - 3) << 7) + (mx[rc_r] - 3) : 0;				
        se_w    = (rc_r > 1) ? 0 : 1;
        ins_w   = (rc_r > 1) ? (noob[rc_r - 2] >0 )? Q : 0 : 8'hff;
        rc_w    = rc_r + 1;
        if (rc_r>1) begin 
          mv_w[rc_r-2] = (noob[rc_r-2]>0)? Q: 0;
        end
      end else begin
        state_w = ST_R7R;
        se_w    = 1;
        rc_w    = 0;
        lc_w    = lc_r + 1;
        pc_w    = pc_r + 1;
        px_w    = px_r + 1;
      end
    end
    ST_R7R: begin
      if (rc_r<9) begin
        state_w = ST_R7R;
        ov_w   = (rc_r<1)? 1: 0;
        dout_w = (rc_r<1)? MED: 0;
        a_w    = (rc_r<7)? ((my[6+rc_r*7]-3)<<7) + (mx[6+rc_r*7]-3): 0;
        se_w   = (rc_r>1)? 1'b0: 1'b1;
        ins_w  = (rc_r>1)? (noob[6+(rc_r-2)*7]>0)? Q: 0: 8'hff;
        del_w  = (rc_r>1)? mv_r[0+(rc_r-2)*7]: 8'hff;
        rc_w = rc_r + 1;
        if (rc_r > 1) begin
          mv_w[6+(rc_r-2)*7] = (noob[6+(rc_r-2)*7]>0)? Q: 0;
          for (i=0; i<6; i=i+1) begin
            mv_w[i+(rc_r-2)*7] = mv_r[(i+1)+(rc_r-2)*7];
          end
        end
      end else if (lc_r==127 && (pc_r<639 || pc_r>16000)) begin
        state_w = ST_R7D;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = 0;
        pc_w = pc_r + 1;
        py_w = py_r + 1;
      end else if (lc_r==127) begin
        state_w = ST_W1L;
        bz_w = 1'b0;
        se_w = 1'b1;
        wc_w = 0;
        lc_w = 0;
        pc_w = pc_r + 1;
        py_w = py_r + 1;
      end else begin
        state_w = ST_R7R;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = lc_r + 1;
        pc_w = pc_r + 1;
        px_w = px_r + 1;
      end
    end
    ST_W1L: begin
      if (wc_r<128) begin
        state_w = ST_W1L;
        bz_w   = (wc_r==127)? 1'b1: 1'b0;
        ov_w   = (rc_r<1)? 1'b1: 0;
        dout_w = (rc_r<1)? MED: 0;
        a_w    = wa_r;
        d_w    = DIN;
        ce_w = 0;
        we_w = 0;
        lc_w = lc_r + 1;
        wa_w = wa_r + 1;
        wc_w = wc_r + 1;
      end else begin
        state_w = ST_R7D;
        ce_w = 1'b0;
        we_w = 1'b1;
        lc_w = 0;
        rc_w = 0;
      end
    end
    ST_R7D: begin
      if (rc_r<9) begin
        state_w = ST_R7D;
        ov_w   = (rc_r<1)? 1'b1: 0;
        dout_w = (rc_r<1)? MED: 0;
        a_w    = (rc_r<7)? ((my[42+rc_r]-3)<<7) + (mx[42+rc_r]-3): 0;
        se_w   = (rc_r>1)? 1'b0: 1'b1;
        ins_w  = (rc_r>1)? (noob[42+(rc_r-2)]>0)? Q: 0: 8'hff;
        del_w  = (rc_r>1)? mv_r[0+(rc_r-2)]: 8'hff;
        rc_w = rc_r + 1;
        if (rc_r > 1) begin
          mv_w[42+(rc_r-2)] = (noob[42+(rc_r-2)]>0)? Q: 0;
          for (i=0; i<6; i=i+1) begin
            mv_w[i*7+(rc_r-2)] = mv_r[(i+1)*7+(rc_r-2)];
          end
        end
      end else begin
        state_w = ST_R7L;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = lc_r + 1;
        pc_w = pc_r + 1;
        px_w = px_r - 1;
      end
    end
    ST_R7L: begin
      if (rc_r<9) begin
        state_w = ST_R7L;
        a_w    = (rc_r<7)? ((my[rc_r*7]-3)<<7) + (mx[rc_r*7]-3): 0;
        se_w   = (rc_r>1)? 1'b0: 1'b1;
        ins_w  = (rc_r>1)? (noob[(rc_r-2)*7]>0)? Q: 0: 8'hff;
        del_w  = (rc_r>1)? mv_r[6+(rc_r-2)*7]: 8'hff;				
        rc_w = rc_r + 1;
        if (rc_r >1) begin
          mv_w[(rc_r-2)*7] = (noob[(rc_r-2)*7]>0)? Q: 0;
          for (i=0; i<6; i=i+1) begin
            mv_w[(i+1)+(rc_r-2)*7] = mv_r[i+(rc_r-2)*7];
          end
        end
      end else if (lc_r==127 && (pc_r<511 || pc_r>16000)) begin
        state_w = ST_O1LU;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = 0;
        pc_w = pc_r + 1;
        py_w = py_r + 1;
      end else if (lc_r==127) begin
        state_w = ST_W1LU;
        bz_w = 1'b0;
        se_w = 1'b1;
        wc_w = 0;
        lc_w = 0;
        pc_w = pc_r + 1;
        py_w = py_r + 1;
      end else begin
        state_w = ST_R7L;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = lc_r + 1;
        pc_w = pc_r + 1;
        px_w = px_r - 1;
      end
    end
    ST_O1LU: begin
      if (lc_r<128) begin
        state_w = ST_O1LU;
        ov_w   = 1'b1;
        dout_w = (lc_r<1)? MED: med_buf_r[127-lc_r];
        lc_w = lc_r + 1;
      end else if (pc_r<16256) begin
        state_w = ST_R7DU;
        ov_w = 1'b0;
        lc_w = 0;
      end else begin
        state_w = ST_END;
        ov_w = 1'b0;
      end
    end
    ST_W1LU: begin
      if (wc_r<128) begin
        state_w = ST_W1LU;
        bz_w = (wc_r==127)? 1'b1: 1'b0;
        ov_w   = 1'b1;
        dout_w = (lc_r<1)? MED: med_buf_r[127-lc_r];
        a_w  = wa_r;
        d_w  = DIN;
        ce_w = 1'b0;
        we_w = 1'b0;
        lc_w = lc_r + 1;
        wa_w = wa_r + 1;
        wc_w = wc_r + 1;
      end else begin
        state_w = ST_R7DU;
        ov_w = 1'b0;
        ce_w = 1'b0;
        we_w = 1'b1;
        lc_w = 0;
        rc_w = 0;
      end
    end
    ST_R7DU: begin
      if (rc_r<9) begin
        state_w = ST_R7DU;	
        a_w    = (rc_r<7)? ((my[42+rc_r]-3)<<7) + (mx[42+rc_r]-3): 0;
        se_w   = (rc_r>1)? 1'b0: 1'b1;
        ins_w  = (rc_r>1)? (noob[42+(rc_r-2)]>0)? Q: 0: 8'hff;
        del_w  = (rc_r>1)? mv_r[0+(rc_r-2)]: 8'hff;
        rc_w = rc_r + 1;
        if (rc_r > 1) begin
          mv_w[42+(rc_r-2)] = (noob[42+(rc_r-2)]>0)? Q: 0;
          for (i=0; i<6; i=i+1) begin
            mv_w[i*7+(rc_r-2)] = mv_r[(i+1)*7+(rc_r-2)];
          end
        end
      end else begin
        state_w = ST_R7R;
        se_w = 1'b1;
        rc_w = 0;
        lc_w = lc_r + 1;
        pc_w = pc_r + 1;
        px_w = px_r + 1;
      end

       
    end
    ST_END: begin
      state_w = ST_END;
    end
    default: begin
      state_w = ST_IDL;
    end
  endcase
end

always @(posedge CLK or posedge RST) begin
  if (RST) begin
    //-- state_r register
    state_r <= ST_IDL;
    //-- output register
    dout_r  <= 0;
    bz_r    <= 0;
    ov_r    <= 0;
    a_r     <= 0;
    d_r     <= 0;
    ce_r    <= 1;
    we_r    <= 1;
    se_r    <= 1;
    ins_r   <= 255;
    del_r   <= 255;
    //-- internal register
    wa_r    <= 0;
    wc_r    <= 0;
    rc_r    <= 0;
    lc_r    <= 0;
    pc_r    <= 0;
    px_r    <= 3;
    py_r    <= 3;
    // -- mv
    for (i=0; i<49; i=i+1) begin
      mv_r[i] <= 0;
    end
    // -- med_buf
    for (i=0; i<127; i=i+1) begin
      med_buf_r[i] <= 0;
    end
  end else begin
    //-- state_r register
    state_r <= state_w;
    //-- output register
    dout_r  <= dout_w;
    bz_r    <= bz_w;
    ov_r    <= ov_w;
    a_r     <= a_w;
    d_r     <= d_w;
    ce_r    <= ce_w;
    we_r    <= we_w;
    se_r    <= se_w;
    ins_r   <= ins_w;
    del_r   <= del_w;
    //-- internal register
    wa_r <= wa_w;
    wc_r <= wc_w;
    rc_r <= rc_w;
    lc_r <= lc_w;
    pc_r <= pc_w;
    px_r <= px_w;
    py_r <= py_w;
    // -- mv
    for (i=0; i<49; i=i+1) begin
      mv_r[i] <= mv_w[i];
    end
    // -- med_buf
    for (i=0; i<127; i=i+1) begin
      med_buf_r[i] <= med_buf_w[i];
    end

  end
end

// mx[i]
always @ * begin
  for (i=0; i<7; i=i+1) begin
    mx[7*i+0] = px_r-3;
    mx[7*i+1] = px_r-2;
    mx[7*i+2] = px_r-1;
    mx[7*i+3] = px_r;
    mx[7*i+4] = px_r+1;
    mx[7*i+5] = px_r+2;
    mx[7*i+6] = px_r+3;
    my[i+0]   = py_r-3;
    my[i+7]   = py_r-2;
    my[i+14]  = py_r-1;
    my[i+21]  = py_r;
    my[i+28]  = py_r+1;
    my[i+35]  = py_r+2;
    my[i+42]  = py_r+3;
  end
  // noob[i]
  for (i=0; i<49; i=i+1) begin
    noob[i] = (mx[i]>2 && mx[i]<131 && my[i]>2 && my[i]<131) ? 1 : 0;
  end
  // med_buf[i]
  for (i=0; i<127; i=i+1) begin
    med_buf_w[i] = med_buf_r[i];
  end
  if (state_r == ST_R7L && rc_r < 1) begin
    med_buf_w[lc_r-1] = MED;
  end
end

endmodule

/****************************************************************
  Median
*****************************************************************/
module sorter (
  CLK,
  RST,
  SEN,
  INS,
  DEL,
  MED
);

//-- I/O declaration
input        CLK;
input        RST;
input        SEN;
input  [7:0] INS;
input  [7:0] DEL;
output [7:0] MED;

wire [7:0] out00, out01, out02, out03, out04, out05, out06, out07, out08, out09,
           out10, out11, out12, out13, out14, out15, out16, out17, out18, out19,
           out20, out21, out22, out23, out24, out25, out26, out27, out28, out29,
           out30, out31, out32, out33, out34, out35, out36, out37, out38, out39,
           out40, out41, out42, out43, out44, out45, out46, out47, out48;
wire [7:0] w_INS, w_DEL, w_min, w_max;

parameter MIN_VALUE = 8'h00;
parameter MAX_VALUE = 8'hff;

assign MED   = out24;
assign w_INS = SEN ? 255 : INS;
assign w_DEL = SEN ? 255 : DEL;
assign w_min = MIN_VALUE;
assign w_max = MAX_VALUE;

COMPARE C00 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(w_min), .NXT(out01), .OUT(out00));
COMPARE C01 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out00), .NXT(out02), .OUT(out01));
COMPARE C02 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out01), .NXT(out03), .OUT(out02));
COMPARE C03 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out02), .NXT(out04), .OUT(out03));
COMPARE C04 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out03), .NXT(out05), .OUT(out04));
COMPARE C05 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out04), .NXT(out06), .OUT(out05));
COMPARE C06 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out05), .NXT(out07), .OUT(out06));
COMPARE C07 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out06), .NXT(out08), .OUT(out07));
COMPARE C08 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out07), .NXT(out09), .OUT(out08));
COMPARE C09 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out08), .NXT(out10), .OUT(out09));
COMPARE C10 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out09), .NXT(out11), .OUT(out10));
COMPARE C11 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out10), .NXT(out12), .OUT(out11));
COMPARE C12 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out11), .NXT(out13), .OUT(out12));
COMPARE C13 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out12), .NXT(out14), .OUT(out13));
COMPARE C14 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out13), .NXT(out15), .OUT(out14));
COMPARE C15 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out14), .NXT(out16), .OUT(out15));
COMPARE C16 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out15), .NXT(out17), .OUT(out16));
COMPARE C17 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out16), .NXT(out18), .OUT(out17));
COMPARE C18 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out17), .NXT(out19), .OUT(out18));
COMPARE C19 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out18), .NXT(out20), .OUT(out19));
COMPARE C20 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out19), .NXT(out21), .OUT(out20));
COMPARE C21 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out20), .NXT(out22), .OUT(out21));
COMPARE C22 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out21), .NXT(out23), .OUT(out22));
COMPARE C23 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out22), .NXT(out24), .OUT(out23));
COMPARE C24 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out23), .NXT(out25), .OUT(out24));
COMPARE C25 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out24), .NXT(out26), .OUT(out25));
COMPARE C26 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out25), .NXT(out27), .OUT(out26));
COMPARE C27 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out26), .NXT(out28), .OUT(out27));
COMPARE C28 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out27), .NXT(out29), .OUT(out28));
COMPARE C29 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out28), .NXT(out30), .OUT(out29));
COMPARE C30 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out29), .NXT(out31), .OUT(out30));
COMPARE C31 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out30), .NXT(out32), .OUT(out31));
COMPARE C32 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out31), .NXT(out33), .OUT(out32));
COMPARE C33 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out32), .NXT(out34), .OUT(out33));
COMPARE C34 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out33), .NXT(out35), .OUT(out34));
COMPARE C35 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out34), .NXT(out36), .OUT(out35));
COMPARE C36 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out35), .NXT(out37), .OUT(out36));
COMPARE C37 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out36), .NXT(out38), .OUT(out37));
COMPARE C38 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out37), .NXT(out39), .OUT(out38));
COMPARE C39 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out38), .NXT(out40), .OUT(out39));
COMPARE C40 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out39), .NXT(out41), .OUT(out40));
COMPARE C41 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out40), .NXT(out42), .OUT(out41));
COMPARE C42 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out41), .NXT(out43), .OUT(out42));
COMPARE C43 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out42), .NXT(out44), .OUT(out43));
COMPARE C44 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out43), .NXT(out45), .OUT(out44));
COMPARE C45 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out44), .NXT(out46), .OUT(out45));
COMPARE C46 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out45), .NXT(out47), .OUT(out46));
COMPARE C47 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out46), .NXT(out48), .OUT(out47));
COMPARE C48 (.CLK(CLK), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out47), .NXT(w_max), .OUT(out48));

endmodule

module COMPARE (
  CLK, 
  RST, 
  INS, 
  DEL, 
  PRE, 
  NXT, 
  OUT
);

input        CLK;
input        RST;
input  [7:0] INS;
input  [7:0] DEL;
input  [7:0] PRE;
input  [7:0] NXT;
output [7:0] OUT;

reg [7:0] out_r, out_w;

assign OUT = out_r;

always @(posedge CLK or posedge RST) begin
  if (RST) begin
    out_r <= 8'hff;
  end else begin
    out_r <= out_w;
  end
end

always @(*)begin
  out_w = out_r;
  if (INS<DEL) begin
    if (out_r>INS && out_r<=DEL) begin 
      out_w = (PRE > INS) ? PRE : INS; 
    end 
  end else if (INS>DEL) begin
    if (out_r<INS && out_r>=DEL) begin 
      out_w = (NXT < INS) ? NXT : INS; 
    end 
  end
end

endmodule
