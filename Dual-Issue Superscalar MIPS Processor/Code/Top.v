
module top(input clk, reset);
	wire [31:0] pc, instr, readdata;
  	wire [31:0] aluout, writedata;
  	wire        memWrite;
  
  	// processor and memories are instantiated here 
  	mips mip(clk, reset, pc,/*instr,*/memWrite,
		aluout, writedata, readdata);  	
endmodule
