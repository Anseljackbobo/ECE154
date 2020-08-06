module mips(input          clk, reset,
            output  [31:0] pc,
            //input   [31:0] instr,
            output         MemWrite,
            output  [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire   jump, RegWrite, ALUSrcB, Se_ze,
	 Start_mult, Mult_sign, MemtoReg, Eq_ne, Branch;
  wire  [1:0] OutSelect;
  wire  [3:0] ALU_Op;
  wire memenable;

  wire  RegDst;

  wire [1:0] PCSrcD;
  wire EqualD;

  wire [1:0] pcsrcd;
  wire [5:0] Op, Funct;

  Controller c(EqualD, /*instr[31:26], instr[5:0],*/Op, Funct, /*clk,*/ reset, MemWrite, /*jump,*/ OutSelect, 
		RegWrite, ALUSrcB, Se_ze, RegDst,Start_mult, 
		Mult_sign, MemtoReg, Eq_ne, Branch, pcsrcd, ALU_Op, memenable);

  data_path genius(pcsrcd, clk, reset, Se_ze, Eq_ne, Branch,
		 Mult_sign, Start_mult,
		 OutSelect,
		 RegWrite, MemtoReg, MemWrite,
		 ALU_Op, memenable,
		 ALUSrcB, RegDst,
		 Op, Funct, EqualD);

endmodule
