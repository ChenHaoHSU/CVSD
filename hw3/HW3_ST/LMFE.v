/****************************************************************
  Top Module
*****************************************************************/
module LMFE ( clk, reset, Din, in_en, busy, out_valid, Dout );
input   clk;
input   reset;
input   in_en;
output  busy;
output  out_valid;
input   [7:0]  Din;
output  [7:0]  Dout;

/* ============================================ */
wire	[7:0]	sort_insert;
wire	[7:0]	sort_delete;
wire	[7:0]	sort_median;
wire		   	sort_enable;

wire 		   	sram_cen;
wire		   	sram_wen;
wire	[9:0]	sram_addr;
wire	[7:0]	sram_d;
wire	[7:0]	sram_q;

/* ============================================ */
controller lmfe_controller (
  // input
  .CLK	(clk),
  .RST	(reset),
  .IEN  (in_en),
  .DIN	(Din),
  .Q		(sram_q),
  .MED	(sort_median),
  // output
  .ADDR	(sram_addr),
  .D		(sram_d),	
  .CEN	(sram_cen),
  .WEN	(sram_wen),
  .SEN	(sort_enable),
  .INS	(sort_insert),
  .DEL	(sort_delete),
  .DOUT	(Dout),
  .OV		(out_valid),
  .BUSY	(busy)
);

med49 lmfe_med49 (
	//-- input port
	.clk	(clk),
	.RST	(reset),
	.SEN	(sort_enable),
	.INS	(sort_insert),
	.DEL	(sort_delete),
	//-- output port
	.MED	(sort_median)
);

sram_1024x8_t13 lmfe_sram (
  // input
  .CLK	(clk),
  .CEN	(sram_cen),
  .WEN	(sram_wen),
  .A    (sram_addr),
  .D    (sram_d),
  // output
  .Q    (sram_q)
);

endmodule

/****************************************************************
  Controller
*****************************************************************/
module controller (CLK, RST, IEN, DIN, Q, MED, ADDR, D,
  CEN, WEN,	SEN, INS,	DEL, DOUT, OV, BUSY);

input        CLK;
input        RST;
input        IEN;
input  [7:0] DIN;
input  [7:0] Q;
input  [7:0] MED;
output [9:0] ADDR;
output [7:0] D;
output       CEN;
output       WEN;
output       SEN;
output [7:0] INS;
output [7:0] DEL;
output [7:0] DOUT;
output       OV;
output       BUSY;

/* ============================================ */
// states
parameter S_IDLE    = 4'd0;
parameter S_INIT    = 4'd1;
parameter S_MED49   = 4'd2;
parameter S_UPD5    = 4'd3;
parameter S_NXTROW  = 4'd4;
parameter S_END     = 4'd5;


/* ============================================ */
reg [3:0] state_r, state_w;
reg [9:0] addr_r, addr_w;
reg [7:0] dout_r, dout_w;
reg [7:0] d_r, d_w;
reg       cen_r, cen_w;
reg       wen_r, wen_w;
reg       sen_r, sen_w;
reg [7:0] ins_r, ins_w;
reg [7:0] del_r, del_w;
reg       ov_r, ov_w;
reg       busy_r, busy_w;

reg [9:0] rowcnt_r, rowcnt_w;
reg [9:0] colcnt_r, colcnt_w;
reg [9:0] loadcnt_r, loadcnt_w;
  

assign DOUT = dout_r; 
assign ADDR = addr_r;
assign D    = d_r; 
assign CEN  = cen_r;
assign WEN  = wen_r;
assign SEN  = sen_r;
assign INS  = ins_r;
assign DEL  = del_r;
assign OV   = ov_r;
assign BUSY = busy_r;

always @(*) begin    
    state_w      = state_r;
    addr_w       = addr_r;
		dout_w       = dout_r;
		d_w          = d_r;
		cen_w        = cen_r;
		wen_w        = wen_r;
		sen_w        = sen_r;
		ins_w        = ins_r;
		del_w        = del_r;
		ov_w         = ov_r;
		busy_w       = busy_r;
    rowcnt_w     = rowcnt_r;
    colcnt_w     = colcnt_r;
    loadcnt_w    = loadcnt_r;
  
  case (state_r)
    S_IDLE: begin
      if (IEN) begin
        state_w = S_INIT;
        cen_w   = 1;
        wen_w   = 1;
        addr_w  = 0;
        loadcnt_w = 0;
        d_w     = DIN;
      end else begin
        state_w = S_IDLE;
      end
    end
    
    S_INIT: begin 
      // if (loadcnt_r < )
      loadcnt_w = loadcnt_r + 1;
      cen_w = 1;
      wen_w = 1;
      addr_w = addr_r + 1;
    end


    S_END: begin
      state_w = S_END;
    end 
    default: begin
      state_w = S_IDLE;
    end
  endcase
end

always @(posedge CLK or posedge RST) begin
  if (RST) begin
    state_r      <= S_IDLE;
    addr_r       <= 10'b0;
		dout_r       <= 1'b0;
		d_r          <= 1'b0;
		cen_r        <= 1'b1;
		wen_r        <= 1'b1;
		sen_r        <= 1'b0;
		ins_r        <= 8'hff;
		del_r        <= 8'hff;
		ov_r         <= 1'b0;
		busy_r       <= 1'b0;
    rowcnt_r     <= 10'b0;
    colcnt_r     <= 10'b0;
    loadcnt_r    <= 10'b0;
  end else begin    
    state_r      <= state_w;
    addr_r       <= addr_w;
		dout_r       <= dout_w;
		d_r          <= d_w;
		cen_r        <= cen_w;
		wen_r        <= wen_w;
		sen_r        <= sen_w;
		ins_r        <= ins_w;
		del_r        <= del_w;
		ov_r         <= ov_w;
		busy_r       <= busy_w;
    rowcnt_r     <= rowcnt_w;
    colcnt_r     <= colcnt_w;
    loadcnt_r    <= loadcnt_w;
  end 
end 

endmodule

/****************************************************************
  Median
*****************************************************************/
module med49 (
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
assign w_INS = (SEN)? INS : 255;
assign w_DEL = (SEN)? DEL : 255;
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


