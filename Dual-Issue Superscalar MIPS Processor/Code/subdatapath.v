
module subdatapath(
	// global clk, reset
	input clk,
	input reset,
	// decode stage
	input [31:0] instrd,
	// regfile
	output [4:0] a1, // give address of regfile, get rd1
	output [4:0] a2, // give address of regfile, get rd2
	input [31:0] rd1, rd2, // get data from regfile
	output [4:0] a3, // write address
	output [31:0] wd3, // write data 3
	output we3, // regfile write enable

	// datamem
	output [31:0] memadr, // memory address && forward use
	output [31:0] memwd, // memory write data
	input [31:0] memoryrd, // memory read data
	output memenable, // memory enable
	output memwritem,

	// branch
	// stub, implement later
	input [31:0] pcplus4d,
	input [31:0] memadr_another, // memadr from another slot
	input [1:0] forwardad,
	input [1:0] forwardbd,
	input branchPredictedTakenD,
	output BranchIsTakenE,

	output branchIsNotCorrectE,
	output [31:0] PCBranchE,
	
	input [2:0] forwardae, forwardbe,
	output [31:0] resultw,
	input [31:0] resultw_another,

	// jump related
	output jump,
	output [31:0] jumpadr,
	// hazard
	input flushe,
	input stalle,

	input flushm,
	input stallm,

	input flushw,
	input stallw,
	output isLoadWordD,
	//
	output [4:0] rsd, rtd, rse, rte,
	//hazard needs them
	output regwritee,memtorege,
	output regwritem, memtoregm,
	output [4:0] WriteRegM, WriteRegW,
	output regwritew,
	output [4:0] WriteRegD,
	output RegWriteD
);
	// assign regs 
	assign a1 = instrd[25:21];
	assign a2 = instrd[20:16];
	assign a3 = WriteRegW;
	assign isLoadWordD = (instrd[31:26] == 6'b100011);

	// branch related
	wire branchd; // NOT USED
	wire [1:0] PCSrcD; // Only Used Internally
	wire branchistakend; // Only use in decode
	assign {jump, branchistakend} = PCSrcD;


	// controller signal decode
	wire se_ze; // only in decode
	wire memwrited, memwritee;
	wire [1:0] outseld, outsele, outselm; // this is used to select from Hi/Lo/aluoutm/Lui
	wire regwrited;
	wire alusrcbd, alusrcbe;
	wire regdstd, regdste;
	wire memtoregd,memtoregw;
	wire [3:0] aluopd, aluope;
	wire memenabled,memenablee,memenablem; // this is used for cache, MAY NOT USED
	wire [4:0] rdd; // Rs & Rt May need to be output
	assign rsd = instrd[25:21];
	assign rtd = instrd[20:16];
	assign rdd = instrd[15:11];

	// multiplier related: MAY NOT BE IMPLEMENTED
	wire Start_mult;
	wire Mult_sign;
	

	// decode stage
	wire [31:0] branch_check1, branch_check2;
	mux3 #(32) branch_check_mux_1(rd1, memadr, memadr_another, forwardad, branch_check1);
	mux3 #(32) branch_check_mux_2(rd2, memadr, memadr_another, forwardbd, branch_check2);
	wire Eq_ne; // eq == 1, ne ==0
	wire EqualD;
	assign EqualD = Eq_ne ? (branch_check1 == branch_check2) : (branch_check1 != branch_check2);
	wire [31:0] immextd, immexte;
	extend ext(instrd[15:0], se_ze, immextd); // extent mudoule output as SignImmD labled in the diagram
	wire branchIsNotCorrectD;
	assign branchIsNotCorrectD = (branchPredictedTakenD != branchistakend); // check if branch is taken in decode stage
	wire [31:0] PCBranchD;
	wire [31:0] immextdShift2;
	assign immextdShift2 = immextd << 2;
	assign PCBranchD = branchistakend ? (immextdShift2 + pcplus4d) : pcplus4d;
	

	// decode to execute
	wire [31:0] rd1e, rd2e;
	wire [4:0] rde; // Rs & Rt May need to be output
	resetclearenablereg #(157)
		d2e(clk, reset, flushe,(~stalle),
		 {rd1, rd2, immextd, branchIsNotCorrectD, branchistakend, rsd, rtd, rdd, PCBranchD, memwrited, outseld, regwrited, alusrcbd, regdstd, memtoregd, aluopd, memenabled},
		 {rd1e,rd2e,immexte, branchIsNotCorrectE, BranchIsTakenE, rse, rte, rde, PCBranchE, memwritee, outsele, regwritee, alusrcbe, regdste, memtorege, aluope, memenablee});

	// execute stage
	// PCBranchE & branchIsNotCorrectE does not need any operation
	wire [31:0] SrcAE, SrcBE_BeforeMux, SrcBE, WriteDataM; // SrcBE_BeforeMux is same to WriteDataE
	ForwardSpecialMux5 forwardMuxAE(forwardae, rd1e, resultw, memadr, resultw_another, memadr_another, SrcAE);
	ForwardSpecialMux5 forwardMuxBE(forwardbe, rd2e, resultw, memadr, resultw_another, memadr_another, SrcBE_BeforeMux);

	assign SrcBE = alusrcbe ? immexte : SrcBE_BeforeMux;

	wire [31:0] ALUOutE, ALUOutM;
	ALU ourOwnALU(SrcAE, SrcBE, aluope, ALUOutE);
	wire [4:0] WriteRegE; // May need to be output
	assign WriteRegE = regdste ? rde : rte;

	wire [31:0] luiImmE, luiImmM;
	assign luiImmE = {immexte[15:0], 16'b0};

	resetclearenablereg #(107)
		e2m(clk, reset, flushm,(~stallm),
		 {ALUOutE, SrcBE_BeforeMux, WriteRegE, luiImmE, memwritee, outsele, regwritee, memtorege, memenablee},
		 {ALUOutM, WriteDataM     , WriteRegM, luiImmM, memwritem, outselm, regwritem, memtoregm, memenablem});
	assign memenable = memenablem;
	// memory stage
	mux4 #(32) memadrSelect(32'b0, 32'b0, ALUOutM, luiImmM, outselm, memadr); // assign memadr
	assign memwd = WriteDataM;

	wire [31:0] ReadDataW, ALUOutW;
	resetclearenablereg #(71)
		m2w(clk, reset, flushw,(~stallw),
		 {memoryrd , memadr , WriteRegM, regwritem, memtoregm},
		 {ReadDataW, ALUOutW, WriteRegW, regwritew, memtoregw});
	// write back
	assign resultw = memtoregw ? ReadDataW : ALUOutW;
	assign wd3 = resultw;
	assign we3 = regwritew;


	// controller
	Controller supercontroller(EqualD, instrd[31:26], instrd[5:0], reset, memwrited, 
	outseld, regwrited, alusrcbd, se_ze, regdstd,
	Start_mult, Mult_sign, memtoregd, Eq_ne, branchd, PCSrcD, aluopd,
	memenabled);


	assign WriteRegD = regdstd ? rdd : rtd;
	assign RegWriteD = regwrited;

endmodule