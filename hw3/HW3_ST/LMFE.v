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
  .clk	(clk),
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
  .clk (clk),
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
  clk,
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
input        clk;
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
reg [9:0] A;
reg [7:0] D;
reg       CE;
reg       WE;
reg       SE;
reg [7:0] INS;
reg [7:0] DEL;
reg [7:0] DOUT;
reg       OV;
reg       BZ;
reg [7:0] i;
reg [7:0] n_DOUT;
reg       n_BZ;
reg       n_OV;
reg [9:0] n_A;
reg [7:0] n_D;
reg       n_CE;
reg       n_WE;
reg       n_SE;
reg [7:0] n_INS;
reg [7:0] n_DEL;
reg [3:0] state, n_state;
reg [9:0] wa, n_wa;
reg [9:0] wc, n_wc;
reg [5:0] rc, n_rc;
reg [7:0] lc, n_lc;
reg [13:0] pc, n_pc;
reg [7:0] px, n_px;
reg [7:0] py, n_py;
reg [7:0] mv [0:48];
reg [7:0] n_mv [0:48];
reg [7:0] mx [0:48];
reg [7:0] my [0:48];
reg [7:0] ix [0:48];
reg [7:0] iy [0:48];
reg       noob [0:48];
reg [7:0]	med_buf [0:126];
reg [7:0]	n_med_buf [0:126];

always @(*) begin
  n_state = state;
  case (state)
    ST_IDL: begin
      if (IEN) begin
        n_state = ST_W7L;
      end else begin
        n_state = ST_IDL;
      end
    end
    ST_W7L: begin
      if (wc<895) begin
        n_state = ST_W7L;
      end else begin
        n_state = ST_R49;
      end
    end
    ST_R49: begin
      if (rc<51) begin
        n_state = ST_R49;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_R7R: begin
      if (rc<9) begin
        n_state = ST_R7R;
      end else if (lc==127 && (pc<639 || pc>16000)) begin
        n_state = ST_R7D;
      end else if (lc==127) begin
        n_state = ST_W1L;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_W1L: begin
      if (wc<128) begin
        n_state = ST_W1L;
      end else begin
        n_state = ST_R7D;
      end
    end
    ST_R7D: begin
      if (rc<9) begin
        n_state = ST_R7D;
      end else begin
        n_state = ST_R7L;
      end
    end
    ST_R7L: begin
      if (rc<9) begin
        n_state = ST_R7L;
      end else if (lc==127 && (pc<511 || pc>16000)) begin
        n_state = ST_O1LU;
      end else if (lc==127) begin
        n_state = ST_W1LU;
      end else begin
        n_state = ST_R7L;
      end
    end
    ST_O1LU: begin
      if (lc<128) begin
        n_state = ST_O1LU;
      end else if (pc<16256) begin
        n_state = ST_R7DU;
      end else begin
        n_state = ST_END;
      end
    end
    ST_W1LU: begin
      if (wc<128) begin
        n_state = ST_W1LU;
      end else begin
        n_state = ST_R7DU;
      end
    end
    ST_R7DU: begin
      if (rc<9) begin
        n_state = ST_R7DU;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_END: begin
      n_state = ST_END;
    end
    default: begin
      n_state = ST_IDL;
    end
  endcase
end

always @(posedge clk or posedge RST) begin
  if (RST) begin
    //-- state register
    state <= ST_IDL;
    //-- output register
    DOUT  <= 1'b0;
    BZ    <= 1'b0;
    OV    <= 1'b0;
    A     <= 1'b0;
    D     <= 1'b0;
    CE    <= 1'b1;
    WE    <= 1'b1;
    SE    <= 1'b1;
    INS   <= 8'hff;
    DEL   <= 8'hff;
    //-- internal register
    wa    <= 0;
    wc    <= 0;
    rc    <= 0;
    lc    <= 0;
    pc    <= 0;
    px    <= 3;
    py    <= 3;
    // -- mv
    for (i=0; i<49; i=i+1) begin
      mv[i] <= 0;
    end
    // -- med_buf
    for (i=0; i<127; i=i+1) begin
      med_buf[i] <= 0;
    end

  end else begin
    //-- state register
    state <= n_state;
    //-- output register
    DOUT <= n_DOUT;
    BZ   <= n_BZ;
    OV   <= n_OV;
    A    <= n_A;
    D    <= n_D;
    CE   <= n_CE;
    WE   <= n_WE;
    SE   <= n_SE;
    INS  <= n_INS;
    DEL  <= n_DEL;
    //-- internal register
    wa <= n_wa;
    wc <= n_wc;
    rc <= n_rc;
    lc <= n_lc;
    pc <= n_pc;
    px <= n_px;
    py <= n_py;
    // -- mv
    for (i=0; i<49; i=i+1) begin
      mv[i] <= n_mv[i];
    end
    // -- med_buf
    for (i=0; i<127; i=i+1) begin
      med_buf[i] <= n_med_buf[i];
    end

  end
end


//-- state register
/*
always @ (posedge clk, posedge RST) begin
  if (RST) begin
    state <= ST_IDL;
  end else begin
    state <= n_state;
  end
end
*/

//-- next state logic
always @ * begin
  n_state = state;
  case (state)
    ST_IDL: begin
      if (IEN) begin
        n_state = ST_W7L;
      end else begin
        n_state = ST_IDL;
      end
    end
    ST_W7L: begin
      if (wc<895) begin
        n_state = ST_W7L;
      end else begin
        n_state = ST_R49;
      end
    end
    ST_R49: begin
      if (rc<51) begin
        n_state = ST_R49;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_R7R: begin
      if (rc<9) begin
        n_state = ST_R7R;
      end else if (lc==127 && (pc<639 || pc>16000)) begin
        n_state = ST_R7D;
      end else if (lc==127) begin
        n_state = ST_W1L;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_W1L: begin
      if (wc<128) begin
        n_state = ST_W1L;
      end else begin
        n_state = ST_R7D;
      end
    end
    ST_R7D: begin
      if (rc<9) begin
        n_state = ST_R7D;
      end else begin
        n_state = ST_R7L;
      end
    end
    ST_R7L: begin
      if (rc<9) begin
        n_state = ST_R7L;
      end else if (lc==127 && (pc<511 || pc>16000)) begin
        n_state = ST_O1LU;
      end else if (lc==127) begin
        n_state = ST_W1LU;
      end else begin
        n_state = ST_R7L;
      end
    end
    ST_O1LU: begin
      if (lc<128) begin
        n_state = ST_O1LU;
      end else if (pc<16256) begin
        n_state = ST_R7DU;
      end else begin
        n_state = ST_END;
      end
    end
    ST_W1LU: begin
      if (wc<128) begin
        n_state = ST_W1LU;
      end else begin
        n_state = ST_R7DU;
      end
    end
    ST_R7DU: begin
      if (rc<9) begin
        n_state = ST_R7DU;
      end else begin
        n_state = ST_R7R;
      end
    end
    ST_END: begin
      n_state = ST_END;
    end
    default: begin
      n_state = ST_IDL;
    end
  endcase
end

//-- output register
/*
always @ (posedge clk, posedge RST) begin
  if (RST) begin
    DOUT <= 1'b0;
    BZ   <= 1'b0;
    OV   <= 1'b0;
    A    <= 1'b0;
    D    <= 1'b0;
    CE   <= 1'b1;
    WE   <= 1'b1;
    SE   <= 1'b1;
    INS  <= 8'hff;
    DEL  <= 8'hff;
  end else begin
    DOUT <= n_DOUT;
    BZ   <= n_BZ;
    OV   <= n_OV;
    A    <= n_A;
    D    <= n_D;
    CE   <= n_CE;
    WE   <= n_WE;
    SE   <= n_SE;
    INS  <= n_INS;
    DEL  <= n_DEL;
  end
end
*/

//-- output logic
always @ * begin
  n_DOUT = DOUT;
  n_BZ   = BZ;
  n_OV   = OV;
  n_A    = A;
  n_D    = D;
  n_CE   = CE;
  n_WE   = WE;
  n_SE   = SE;
  n_INS  = INS;
  n_DEL  = DEL;
  case (state)
    ST_IDL: begin
      if (IEN) begin
        // n_state = ST_W7L;
        n_A    = wa;
        n_D    = DIN;
        n_CE   = 1'b0;
        n_WE   = 1'b0;
      end else begin
        // n_state = ST_IDL;
      end
    end
    ST_W7L: begin
      if (wc<895) begin
        // n_state = ST_W7L;
        n_BZ = (wc==894)? 1'b1: 1'b0;
        n_A  = wa;
        n_D  = DIN;
      end else begin
        // n_state = ST_R49;
        n_CE  = 1'b0;
        n_WE  = 1'b1;
      end
    end
    ST_R49: begin
      if (rc<51) begin
        // n_state = ST_R49;
        n_A   = (rc<49)? ((my[rc]-3)<<7) + (mx[rc]-3): 0;				
        n_SE  = (rc>1)? 1'b0: 1'b1;
        n_INS = (rc>1)? (noob[rc-2]>0)? Q: 0: 8'hff;
      end else begin
        // n_state = ST_R7R;
        n_SE = 1'b1;
      end
    end		
    ST_R7R: begin
      if (rc<9) begin
        // n_state = ST_R7R;
        n_OV   = (rc<1)? 1'b1: 0;
        n_DOUT = (rc<1)? MED: 0;
        n_A    = (rc<7)? ((my[6+rc*7]-3)<<7) + (mx[6+rc*7]-3): 0;
        n_SE   = (rc>1)? 1'b0: 1'b1;
        n_INS  = (rc>1)? (noob[6+(rc-2)*7]>0)? Q: 0: 8'hff;
        n_DEL  = (rc>1)? mv[0+(rc-2)*7]: 8'hff;
      end else if (lc==127 && (pc<639 || pc>16000)) begin
        // n_state = ST_R7D;
        n_SE = 1'b1;
      end else if (lc==127) begin
        // n_state = ST_W1L;
        n_BZ = 1'b0;
        n_SE = 1'b1;
      end else begin
        // n_state = ST_R7R;
        n_SE = 1'b1;
      end
    end
    ST_W1L: begin
      if (wc<128) begin
        // n_state = ST_W1L;
        n_BZ   = (wc==127)? 1'b1: 1'b0;
        n_OV   = (rc<1)? 1'b1: 0;
        n_DOUT = (rc<1)? MED: 0;
        n_A    = wa;
        n_D    = DIN;
        n_CE = 0;
        n_WE = 0;
      end else begin
        // n_state = ST_R7D;
        n_CE = 1'b0;
        n_WE = 1'b1;
      end
    end
    ST_R7D: begin
      if (rc<9) begin
        // n_state = ST_R7D;
        n_OV   = (rc<1)? 1'b1: 0;
        n_DOUT = (rc<1)? MED: 0;
        n_A    = (rc<7)? ((my[42+rc]-3)<<7) + (mx[42+rc]-3): 0;
        n_SE   = (rc>1)? 1'b0: 1'b1;
        n_INS  = (rc>1)? (noob[42+(rc-2)]>0)? Q: 0: 8'hff;
        n_DEL  = (rc>1)? mv[0+(rc-2)]: 8'hff;
      end else begin
        // n_state = ST_R7L;
        n_SE = 1'b1;
      end
    end
    ST_R7L: begin
      if (rc<9) begin
        // n_state = ST_R7L;
        n_A    = (rc<7)? ((my[rc*7]-3)<<7) + (mx[rc*7]-3): 0;
        n_SE   = (rc>1)? 1'b0: 1'b1;
        n_INS  = (rc>1)? (noob[(rc-2)*7]>0)? Q: 0: 8'hff;
        n_DEL  = (rc>1)? mv[6+(rc-2)*7]: 8'hff;				
      end else if (lc==127 && (pc<511 || pc>16000)) begin
        // n_state = ST_O1LU;
        n_SE = 1'b1;
      end else if (lc==127) begin
        // n_state = ST_W1LU;
        n_BZ = 1'b0;
        n_SE = 1'b1;
      end else begin
        // n_state = ST_R7L;
        n_SE = 1'b1;
      end
    end
    ST_O1LU: begin
      if (lc<128) begin
        // n_state = ST_O1LU;
        n_OV   = 1'b1;
        n_DOUT = (lc<1)? MED: med_buf[127-lc];
      end else if (pc<16256) begin
        // n_state = ST_R7DU;
        n_OV = 1'b0;
      end else begin
        // n_state = ST_END;
        n_OV = 1'b0;
      end
    end
    ST_W1LU: begin
      if (wc<128) begin
        // n_state = ST_W1LU;
        n_BZ = (wc==127)? 1'b1: 1'b0;
        n_OV   = 1'b1;
        n_DOUT = (lc<1)? MED: med_buf[127-lc];
        n_A  = wa;
        n_D  = DIN;
        n_CE = 1'b0;
        n_WE = 1'b0;
      end else begin
        // n_state = ST_R7DU;
        n_OV = 1'b0;
        n_CE = 1'b0;
        n_WE = 1'b1;
      end
    end
    ST_R7DU: begin
      if (rc<9) begin
        // n_state = ST_R7DU;		
        n_A    = (rc<7)? ((my[42+rc]-3)<<7) + (mx[42+rc]-3): 0;
        n_SE   = (rc>1)? 1'b0: 1'b1;
        n_INS  = (rc>1)? (noob[42+(rc-2)]>0)? Q: 0: 8'hff;
        n_DEL  = (rc>1)? mv[0+(rc-2)]: 8'hff;
      end else begin
        // n_state = ST_R7R;
        n_SE = 1'b1;
      end
    end
    ST_END: begin
      // n_state = ST_END;
    end
  endcase
end

//-- internal register
/*
always @ (posedge clk, posedge RST) begin
  if (RST) begin
    wa <= 0;
    wc <= 0;
    rc <= 0;
    lc <= 0;
    pc <= 0;
    px <= 3;
    py <= 3;
  end else begin
    wa <= n_wa;
    wc <= n_wc;
    rc <= n_rc;
    lc <= n_lc;
    pc <= n_pc;
    px <= n_px;
    py <= n_py;		
  end
end
*/

/*
always @ (posedge clk, posedge RST) begin
  if (RST) begin
    for (i=0; i<49; i=i+1) begin
      mv[i] <= 0;
    end
  end else begin
    for (i=0; i<49; i=i+1) begin
      mv[i] <= n_mv[i];
    end
  end
end
*/

/*
always @ (posedge clk, posedge RST) begin
  if (RST) begin
    for (i=0; i<127; i=i+1) begin
      med_buf[i] <= 0;
    end
  end else begin
    for (i=0; i<127; i=i+1) begin
      med_buf[i] <= n_med_buf[i];
    end
  end
end
*/

//-- internal logic
always @ * begin
  n_wa = wa;
  n_wc = wc;
  n_rc = rc;
  n_lc = lc;
  n_pc = pc;
  n_px = px;
  n_py = py;
  case (state)
    ST_IDL: begin
      if (IEN) begin
        // n_state = ST_W7L;
        n_wa = wa + 1;
        n_wc = 0;
      end else begin
        // n_state = ST_IDL;
      end
    end
    ST_W7L: begin
      if (wc<895) begin
        // n_state = ST_W7L;
        n_wa = wa + 1;
        n_wc = wc + 1;
      end else begin
        // n_state = ST_R49;
        n_rc = 0;
      end
    end
    ST_R49: begin
      if (rc<51) begin
        // n_state = ST_R49;
        n_rc = rc + 1;
        // if (rc>1) n_mv[rc-2] = (noob[rc-2]>0)? Q: 0;
      end else begin
        // n_state = ST_R7R;
        n_rc = 0;
        n_lc = lc + 1;
        n_pc = pc + 1;
        n_px = px + 1;
      end
    end
    ST_R7R: begin	
      if (rc<9) begin
        // n_state = ST_R7R;
        n_rc = rc + 1;
        // if (rc>1) begin
          // n_mv[6+(rc-2)*7] = (noob[6+(rc-2)*7]>0)? Q: 0;
          // for (i=0; i<6; i=i+1) begin
            // n_mv[i+(rc-2)*7] = mv[(i+1)+(rc-2)*7];
          // end
        // end
      end else if (lc==127 && (pc<639 || pc>16000)) begin
        // n_state = ST_R7D;
        n_rc = 0;
        n_lc = 0;
        n_pc = pc + 1;
        n_py = py + 1;
      end else if (lc==127) begin
        // n_state = ST_W1L;
        // n_wa = wa + 1;
        n_wc = 0;
        n_lc = 0;
        n_pc = pc + 1;
        n_py = py + 1;
      end else begin
        // n_state = ST_R7R;
        n_rc = 0;
        n_lc = lc + 1;
        n_pc = pc + 1;
        n_px = px + 1;
      end
    end
    ST_W1L: begin
      if (wc<128) begin
        // n_state = ST_W1L;
        n_lc = lc + 1;
        n_wa = wa + 1;
        n_wc = wc + 1;
      end else begin
        // n_state = ST_R7D;
        n_lc = 0;
        n_rc = 0;
      end
    end
    ST_R7D: begin
      if (rc<9) begin
        // n_state = ST_R7D;
        n_rc = rc + 1;
        // if (rc>1) begin
          // n_mv[42+(rc-2)] = (noob[42+(rc-2)]>0)? Q: 0;
          // for (i=0; i<6; i=i+1) begin
            // n_mv[i*7+(rc-2)] = mv[(i+1)*7+(rc-2)];
          // end
        // end
      end else begin
        // n_state = ST_R7L;
        n_rc = 0;
        n_lc = lc + 1;
        n_pc = pc + 1;
        n_px = px - 1;
      end
    end
    ST_R7L: begin
      if (rc<9) begin
        // n_state = ST_R7L;
        n_rc = rc + 1;
        // if (rc>1) begin
          // n_mv[(rc-2)*7] = (noob[(rc-2)*7]>0)? Q: 0;
          // for (i=0; i<6; i=i+1) begin
            // n_mv[(i+1)+(rc-2)*7] = mv[i+(rc-2)*7];
          // end
        // end
        // n_med_buf[lc-1] = (rc<1)? MED: med_buf[lc-1];
      end else if (lc==127 && (pc<511 || pc>16000)) begin
        // n_state = ST_O1LU;
        n_rc = 0;
        n_lc = 0;
        n_pc = pc + 1;
        n_py = py + 1;
      end else if (lc==127) begin
        // n_state = ST_W1LU;
        n_wc = 0;
        n_lc = 0;
        n_pc = pc + 1;
        n_py = py + 1;
      end else begin
        // n_state = ST_R7L;
        n_rc = 0;
        n_lc = lc + 1;
        n_pc = pc + 1;
        n_px = px - 1;
      end
    end
    ST_O1LU: begin
      if (lc<128) begin
        // n_state = ST_O1LU;
        n_lc = lc + 1;
      end else if (pc<16256) begin
        // n_state = ST_R7DU;
        n_lc = 0;
      end else begin
        // n_state = ST_END;
      end
    end
    ST_W1LU: begin
      if (wc<128) begin
        // n_state = ST_W1LU;
        n_lc = lc + 1;
        n_wa = wa + 1;
        n_wc = wc + 1;
      end else begin
        // n_state = ST_R7DU;
        n_lc = 0;
        n_rc = 0;
      end
    end
    ST_R7DU: begin
      if (rc<9) begin
        // n_state = ST_R7DU;
        n_rc = rc + 1;
      end else begin
        // n_state = ST_R7R;
        n_rc = 0;
        n_lc = lc + 1;
        n_pc = pc + 1;
        n_px = px + 1;
      end
    end
    ST_END: begin
      // n_state = ST_END;
    end
  endcase
end
// mv[i]
always @ * begin
  for (i=0; i<49; i=i+1) begin
    n_mv[i] = mv[i];
  end
  if (state==ST_R49 && rc<51 && rc>1) begin
    n_mv[rc-2] = (noob[rc-2]>0)? Q: 0;
  end else if (state==ST_R7R && rc<9 && rc >1) begin
    n_mv[6+(rc-2)*7] = (noob[6+(rc-2)*7]>0)? Q: 0;
    for (i=0; i<6; i=i+1) begin
      n_mv[i+(rc-2)*7] = mv[(i+1)+(rc-2)*7];
    end
  end else if (state==ST_R7D && rc<9 && rc >1) begin
    n_mv[42+(rc-2)] = (noob[42+(rc-2)]>0)? Q: 0;
    for (i=0; i<6; i=i+1) begin
      n_mv[i*7+(rc-2)] = mv[(i+1)*7+(rc-2)];
    end
  end else if (state==ST_R7L && rc<9 && rc >1) begin
    n_mv[(rc-2)*7] = (noob[(rc-2)*7]>0)? Q: 0;
    for (i=0; i<6; i=i+1) begin
      n_mv[(i+1)+(rc-2)*7] = mv[i+(rc-2)*7];
    end
  end else if (state==ST_R7DU && rc<9 && rc >1) begin
    n_mv[42+(rc-2)] = (noob[42+(rc-2)]>0)? Q: 0;
    for (i=0; i<6; i=i+1) begin
      n_mv[i*7+(rc-2)] = mv[(i+1)*7+(rc-2)];
    end
  end
end

// mx[i]
always @ * begin
  for (i=0; i<7; i=i+1) begin
    mx[7*i+0] = px-3;
    mx[7*i+1] = px-2;
    mx[7*i+2] = px-1;
    mx[7*i+3] = px;
    mx[7*i+4] = px+1;
    mx[7*i+5] = px+2;
    mx[7*i+6] = px+3;
    my[i+0]   = py-3;
    my[i+7]   = py-2;
    my[i+14]  = py-1;
    my[i+21]  = py;
    my[i+28]  = py+1;
    my[i+35]  = py+2;
    my[i+42]  = py+3;
  end
  // noob[i]
  for (i=0; i<49; i=i+1) begin
    noob[i] = (mx[i]>2 && mx[i]<131 && my[i]>2 && my[i]<131)? 1'b1: 1'b0;
  end
  // med_buf[i]
  for (i=0; i<127; i=i+1) begin
    n_med_buf[i] = med_buf[i];
  end
  if (state==ST_R7L && rc<1) begin
    n_med_buf[lc-1] = MED;
  end
end

endmodule

/****************************************************************
  Median
*****************************************************************/
module sorter (
  clk,
  RST,
  SEN,
  INS,
  DEL,
  MED
);

//-- I/O declaration
input  clk;
input  RST;
input  SEN;
input  [7:0] INS;
input  [7:0] DEL;
output [7:0] MED;

//--- reg and wire
wire [7:0] out00, out01, out02, out03, out04, out05, out06, out07, out08, out09,
  out10, out11, out12, out13, out14, out15, out16, out17, out18, out19,
  out20, out21, out22, out23, out24, out25, out26, out27, out28, out29,
  out30, out31, out32, out33, out34, out35, out36, out37, out38, out39,
  out40, out41, out42, out43, out44, out45, out46, out47, out48;
wire [7:0] w_INS, w_DEL, w_min, w_max;

assign MED = out24;
assign w_INS = (SEN)? 255: INS;
assign w_DEL = (SEN)? 255: DEL;
assign w_min = 8'h00;
assign w_max = 8'hff;

COMPARE C00 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(w_min), .NXT(out01), .OUT(out00));
COMPARE C01 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out00), .NXT(out02), .OUT(out01));
COMPARE C02 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out01), .NXT(out03), .OUT(out02));
COMPARE C03 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out02), .NXT(out04), .OUT(out03));
COMPARE C04 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out03), .NXT(out05), .OUT(out04));
COMPARE C05 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out04), .NXT(out06), .OUT(out05));
COMPARE C06 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out05), .NXT(out07), .OUT(out06));
COMPARE C07 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out06), .NXT(out08), .OUT(out07));
COMPARE C08 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out07), .NXT(out09), .OUT(out08));
COMPARE C09 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out08), .NXT(out10), .OUT(out09));
COMPARE C10 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out09), .NXT(out11), .OUT(out10));
COMPARE C11 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out10), .NXT(out12), .OUT(out11));
COMPARE C12 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out11), .NXT(out13), .OUT(out12));
COMPARE C13 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out12), .NXT(out14), .OUT(out13));
COMPARE C14 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out13), .NXT(out15), .OUT(out14));
COMPARE C15 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out14), .NXT(out16), .OUT(out15));
COMPARE C16 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out15), .NXT(out17), .OUT(out16));
COMPARE C17 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out16), .NXT(out18), .OUT(out17));
COMPARE C18 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out17), .NXT(out19), .OUT(out18));
COMPARE C19 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out18), .NXT(out20), .OUT(out19));
COMPARE C20 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out19), .NXT(out21), .OUT(out20));
COMPARE C21 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out20), .NXT(out22), .OUT(out21));
COMPARE C22 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out21), .NXT(out23), .OUT(out22));
COMPARE C23 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out22), .NXT(out24), .OUT(out23));
COMPARE C24 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out23), .NXT(out25), .OUT(out24));
COMPARE C25 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out24), .NXT(out26), .OUT(out25));
COMPARE C26 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out25), .NXT(out27), .OUT(out26));
COMPARE C27 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out26), .NXT(out28), .OUT(out27));
COMPARE C28 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out27), .NXT(out29), .OUT(out28));
COMPARE C29 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out28), .NXT(out30), .OUT(out29));
COMPARE C30 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out29), .NXT(out31), .OUT(out30));
COMPARE C31 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out30), .NXT(out32), .OUT(out31));
COMPARE C32 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out31), .NXT(out33), .OUT(out32));
COMPARE C33 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out32), .NXT(out34), .OUT(out33));
COMPARE C34 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out33), .NXT(out35), .OUT(out34));
COMPARE C35 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out34), .NXT(out36), .OUT(out35));
COMPARE C36 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out35), .NXT(out37), .OUT(out36));
COMPARE C37 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out36), .NXT(out38), .OUT(out37));
COMPARE C38 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out37), .NXT(out39), .OUT(out38));
COMPARE C39 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out38), .NXT(out40), .OUT(out39));
COMPARE C40 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out39), .NXT(out41), .OUT(out40));
COMPARE C41 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out40), .NXT(out42), .OUT(out41));
COMPARE C42 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out41), .NXT(out43), .OUT(out42));
COMPARE C43 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out42), .NXT(out44), .OUT(out43));
COMPARE C44 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out43), .NXT(out45), .OUT(out44));
COMPARE C45 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out44), .NXT(out46), .OUT(out45));
COMPARE C46 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out45), .NXT(out47), .OUT(out46));
COMPARE C47 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out46), .NXT(out48), .OUT(out47));
COMPARE C48 (.clk(clk), .RST(RST), .INS(w_INS), .DEL(w_DEL), .PRE(out47), .NXT(w_max), .OUT(out48));

endmodule

module COMPARE (clk, RST, INS, DEL, PRE, NXT, OUT);
input clk;
input RST;
input [7:0] INS;
input [7:0] DEL;
input [7:0] PRE;
input [7:0] NXT;
output reg [7:0] OUT;

reg [7:0] n_OUT;

always @ (posedge clk, posedge RST) begin
  if (RST) begin
    OUT <= 8'hff;
  end else begin
    OUT <= n_OUT;
  end
end

always @ * begin
  n_OUT = OUT;
  if (INS<DEL) begin
    if (OUT>INS && OUT<=DEL && PRE>INS) begin
      n_OUT = PRE;
    end else if (OUT>INS && OUT<=DEL && PRE<=INS) begin
      n_OUT = INS;
    end
  end else if (INS>DEL) begin
    if (OUT<INS && OUT>=DEL && NXT<INS) begin
      n_OUT = NXT;
    end else if (OUT<INS && OUT>=DEL && NXT>=INS) begin
      n_OUT = INS;
    end
  end
end

endmodule
