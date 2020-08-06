
module MipsBob (input clk, reset);
	wire [15:0] immF;


	// hazard related
	wire noop;
	wire RegWriteD_1, RegWriteD_2;
	wire [4:0] WriteRegD_1, WriteRegD_2;


	// fetch stage
	wire [31:0] PCNext, PCF, PCPlus4F, PCPlus8F, PCBranchE, jumpAdrD;
	assign PCPlus4F = PCF+4;
	assign PCPlus8F = PCF+8;
	//if jump, do jump; if branchis not Correct, do PCBranchE, if PredictF: do predicted pc, if noop, do pc+4, default + 8
	wire jumpD;
	wire branchIsNotCorrectE;
	wire predictF;
	wire [31:0] PCIfTaken;
	assign PCNext = jumpD ? jumpAdrD : ((branchIsNotCorrectE) ? PCBranchE : (predictF ? PCIfTaken : (noop ? PCPlus4F : PCPlus8F)));
	
	// pcreg
	wire stallF;
	flopr #(32) pcreg(clk, reset, (~stallF), PCNext, PCF);
	wire [31:0] PCD, PCE;
	//branch predictor
	wire [1:0] branchHistoryF,branchHistoryE;
	PCBranchBufForStep3 branchPredictor(clk, reset, branchF_1, branchE_1, (~branchIsNotCorrectE),PCF, PCE,immF, branchHistoryE, BranchIsTakenE_1, predictF, PCIfTaken, branchHistoryF);

	// instrmen
	
	wire [31:0] instrf_1, instrf_2_before_mux, instrf_2;
	wire [31:0] instrd_1, instrd_2;
	inst_memory_2_output instr_mem_out (PCF, instrf_1, instrf_2_before_mux);
	assign instrf_2 = noop ? 32'b0 : instrf_2_before_mux;
	assign immF = instrd_1[15:0];

	
	// otherthing to do in fetch stage: e.g. Hazard
	wire RegWriteF_1, RegWriteF_2;
	wire RegDstF_1, RegDstF_2;
	wire BranchF_1, BranchF_2; // BranchF2 may not be used/Branch could not be in slot2
	wire MemEnableF_1, MemEnableF_2;
	wire JumpF_1,JumpF_2;
	MainDec fetch_decoder_1(instrf_1[31:26], reset, RegWriteF_1, RegDstF_1, BranchF_1, MemEnableF_1, JumpF_1);
	MainDec fetch_decoder_2(instrf_2_before_mux[31:26], reset, RegWriteF_2, RegDstF_2, BranchF_2, MemEnableF_2, JumpF_2);

	// f2d register
	
	
	wire predictD;

	wire [1:0] branchHistoryD;
	wire flushD;
	wire flushe,stalle, flushm,stallm,flushw,stallw;


	assign stalle = 0;
	assign flushm = 0;
	assign stallm = 0;
	assign flushw = 0;
	assign stallw = 0;
	wire stallD;
	assign stallD = 0;
	wire [31:0] PCPlus4D;
	resetclearenablereg #(131) f2d(clk, reset, flushD, (~stallD),
		 {instrf_1, instrf_2, PCPlus4F, PCF, predictF, branchHistoryF},
		 {instrd_1, instrd_2, PCPlus4D, PCD, predictD, branchHistoryD});
	resetclearenablereg #(34) d2e_for_PC_only(clk, reset, flushe,(~stalle),
						  {PCD, branchHistoryD}, 
						  {PCE, branchHistoryE});
	
	// datapath 1 prototal
	wire [4:0] a1_1, a2_1, a3_1;
	wire [4:0] a1_2, a2_2, a3_2;
	wire [31:0] rd1_1, rd2_1, wd3_1;
	wire [31:0] rd1_2, rd2_2, wd3_2;
	wire we3_1;
	wire we3_2;
	wire [31:0] memadr_1;
	wire [31:0] memadr_2;
	wire [31:0] memwd_1;
	wire [31:0] memwd_2;
	wire [31:0] memoryrd_1;
	wire [31:0] memoryrd_2;
	wire memenable_1;
	wire memenable_2;
	wire [31:0] resultw_1;
	wire [31:0] resultw_2;
	wire IsLoadWordD_1, IsLoadWordD_2;
	// hazard
	wire [1:0] ForwardAD_1, ForwardBD_1;
	wire [2:0] ForwardAE_1, ForwardBE_1;
	wire [1:0] ForwardAD_2, ForwardBD_2;
	wire [2:0] ForwardAE_2, ForwardBE_2;

	// shared hazard command
	
	wire [4:0] RsD_1, RtD_1, RsD_2, RtD_2, RsE_1, RtE_1, RsE_2, RtE_2;
	wire regwritee_1,regwritee_2, memtorege_1, memtorege_2, RegWriteM_1, MemtoRegM_1, RegWriteM_2, MemtoRegM_2;
	wire [4:0] WriteRegM_1, WriteRegW_1, WriteRegM_2, WriteRegW_2;
	wire RegWriteW_1, RegWriteW_2, memwritem_1, memwritem_2;

	subdatapath sub_data_path_1(clk,reset,instrd_1,a1_1, a2_1, rd1_1, rd2_1, a3_1, wd3_1, we3_1, memadr_1, memwd_1, memoryrd_1, memenable_1, memwritem_1, // memory enable
				PCPlus4D,memadr_2, ForwardAD_1, ForwardBD_1, predictD, BranchIsTakenE_1, branchIsNotCorrectE, PCBranchE,
				ForwardAE_1, ForwardBE_1,resultw_1,resultw_2, jumpD, jumpAdrD, flushe,stalle, flushm,stallm,flushw,stallw,IsLoadWordD_1,
				RsD_1, RtD_1, RsE_1, RtE_1,
				regwritee_1,memtorege_1,
				RegWriteM_1, MemtoRegM_1,
				WriteRegM_1, WriteRegW_1,
				RegWriteW_1, WriteRegD_1, RegWriteD_1);
	
	//useless trash
	wire [31:0] PCPlus4D_2, PCBranchE_2, jumpAdrD_2;
	wire predictD_2, branchIsNotCorrectE_2, BranchIsTakenE_2;
	wire jumpD_2;
	subdatapath sub_data_path_2(clk,reset,instrd_2, a1_2, a2_2, rd1_2, rd2_2, a3_2, wd3_2, we3_2, memadr_2, memwd_2, memoryrd_2, memenable_2, memwritem_2,// memory enable
				PCPlus4D_2,memadr_1, ForwardAD_2, ForwardBD_2, predictD_2, BranchIsTakenE_2, branchIsNotCorrectE_2, PCBranchE_2,
				ForwardAE_2, ForwardBE_2,resultw_2,resultw_1, jumpD_2, jumpAdrD_2, flushe,stalle, flushm,stallm,flushw,stallw,IsLoadWordD_2,
				RsD_2, RtD_2, RsE_2, RtE_2,
				regwritee_2,memtorege_2,
				RegWriteM_2, MemtoRegM_2,
				WriteRegM_2, WriteRegW_2,
				RegWriteW_2, WriteRegD_2, RegWriteD_2);


	// regfile
	regfile_especially_for_lab4 regfileLab4(clk, we3_1, we3_2, reset, a1_1, a2_1, a3_1, wd3_1, rd1_1, rd2_1,
							      a1_2, a2_2, a3_2, wd3_2, rd1_2, rd2_2);

	// memory
	wire dmem_write;
	wire [31:0] dmem_address, dmem_write_data, demem_read_data;
	data_memory dmem(clk, dmem_write, dmem_address, dmem_write_data,demem_read_data);

	assign dmem_write = memwritem_1 | memwritem_2;	
	assign dmem_address =  memenable_1 ? memadr_1 : memadr_2;
	assign dmem_write_data = memenable_1 ? memwd_1 : memwd_2;
	assign memoryrd_1 = demem_read_data;
	assign memoryrd_2 = demem_read_data;
	
	
	
	 
	hazard	hazardunit
		(
		WriteRegD_1, WriteRegD_2,
		RegWriteD_1, RegWriteD_2,
		reset,
		//dp1
		ForwardAD_1, ForwardBD_1,
		ForwardAE_1, ForwardBE_1,
		RsD_1, RtD_1,
		RsE_1, RtE_1,
		RegWriteE_1, MemtoRegE_1,
		RegWriteM_1, MemtoRegM_1,
		WriteRegM_1, WriteRegW_1,
		RegWriteW_1,

		//dp2
		ForwardAD_2, ForwardBD_2,
		ForwardAE_2, ForwardBE_2,
		RsD_2, RtD_2,
		RsE_2, RtE_2,
		RegWriteE_2, MemtoRegE_2,
		RegWriteM_2, MemtoRegM_2,
		WriteRegM_2, WriteRegW_2,
		RegWriteW_2,

		//fetch stage early noop predict
		RegWriteF_1, RegWriteF_2,
		RegDstF_1, RegDstF_2,
		BranchF_1, BranchF_2, // BranchF2 may not be used/Branch could not be in slot2
		MemEnableF_1, MemEnableF_2,
		instrf_1[25:21], instrf_2_before_mux[25:21],
		instrf_1[20:16], instrf_2_before_mux[20:16],
		instrf_1[15:11], instrf_2_before_mux[15:11],
		JumpF_1, JumpF_2,
		IsLoadWordD_1, IsLoadWordD_2,
		noop,
		
	 
		// stall and flush
		stallF,
		flushD,
		flushe,
		// branch related
		branchIsNotCorrectE
		//input BranchIsNotCorrectE_2 // NOT USED


		);

		


endmodule 