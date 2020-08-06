module subdatapath_parameter_check();
reg clk, reset, branchPredictedTakenD, flushe, stalle;
reg [31:0] instrd, rd1, rd2, memoryrd, pcplus4d, memadr_another;
wire [4:0] a1, a2, a3;
wire [31:0] wd3,memadr,memwd,PCBranchE,resultw_another;
wire we3, memenable, branchIsCorrectE,resultw,jump;
reg [1:0] forwardad, forwardbd;
reg [2:0] forwardae, forwardbe;

subdatapath pig(
	clk,
	reset,
	instrd,
	a1, // give address of regfile, get rd1
	a2, // give address of regfile, get rd2
	rd1, rd2, // get data from regfile
	a3, // write address
	wd3, // write data 3
	we3, // regfile write enable

	// datamem
	memadr, // memory address && forward use
	memwd, // memory write data
	memoryrd, // memory read data
	memenable, // memory enable

	// branch
	// stub, implement later
	pcplus4d,
	memadr_another, // memadr from another slot
	forwardad,
	forwardbd,
	branchPredictedTakenD,

	branchIsCorrectE,
	PCBranchE,
	
	forwardae, forwardbe,
	resultw,
	resultw_another,

	// jump related
	jump,
	
	// hazard
	flushe,
	stalle);
endmodule
