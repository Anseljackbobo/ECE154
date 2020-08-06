module data_path(input [1:0] pcsrcd, input clk, input rfreset, input se_ze, input eq_ne, input branchd,
		 input mul_signd, startmuld,
		 input [1:0] outseld,
		 input regwrited, memtoregd, memwrited,
		 input [3:0] alucontrold,
		 input memenabled,
		 input alusrcd, regdstd,
		 output [5:0] opd, output [5:0] functd, output equald);
	// fetch
	wire [31:0] pcplus4f, pcTakeD, pcTakeE, pcbranche, jumpadr, pcnext, pcf, instrf;
	//dec
	wire [31:0] instrd, pcplus4d, pcplus4e, rd1, rd2, immext;
	wire [31:0] equaldin1, equaldin2; // for equald input

	//exe
	wire mul_signe,startmule;
	wire [1:0] outsele;
	wire regwriree, memtorege,memwritee;
	wire [3:0] alucontrole;
	wire alusrce, regdste;
	wire [31:0] rd1e, rd2e, immexte;
	wire [4:0] rse, rte, rde;

	wire [31:0] srcae, srcbe, writedatae;
	wire [4:0] writerege;
	wire [31:0] immsl16;
	wire [31:0] aluoute;
	wire [63:0] muloute;
	wire [63:0] mulregout;
	wire memenableE;

	//mem
	wire [31:0] aluoutm;
	wire [1:0] outselm;
	wire regwritem;
	wire memtoregm;
	wire memwritem;
	wire [31:0] writedatam;
	wire [4:0] writeregm;
	wire [31:0] immextm;
	wire [31:0] A;// also called slected aluoutm
	wire [31:0] rdm;//readdatam
	wire memenablem;
	//wb
	wire regwritew;
	wire [4:0] writeregw;
	wire [31:0] resultw;
	wire memtoregw;
	wire [31:0] readdataw, aluoutw;
	//hazard use
	wire stallf, stalld, forwardad,flushe;
	wire forwardbd;
	wire[1:0] forwardae, forwardbe;
	wire isready;
	wire ismflomfhi;
	wire memstall; //mem enable when lw and sw
	assign ismflomfhi = ({instrd[31:26], instrd[5:1]} == 11'b00000001001);

	//pulse
	wire memenablem_pulse;
	posedgedetector ruozhi_edgedetector(memenablem, clk, memenablem_pulse);
	reg pig;
	always@* begin
		case(memenablem_pulse) 
			1'b1: pig <= 1;
			default: pig<=0;
		endcase
	end
	wire pig2;
	assign pig2 = pig|memstall;
	
	wire [31:0] PCIfTaken,pcd,pce;
	wire branchF, branchE, branchIsCorrectE, predictF, predictD;
	wire [15:0] immF;
	assign immF = instrf[15:0];
	assign branchF = (instrf[31:26] == 4) | (instrf[31:26] == 5);
	wire pcsrce;

	wire [31:0] pcSourcePredicted;
	assign pcSourcePredicted = predictF ? PCIfTaken : pcplus4f;

	wire [1:0] branchHistoryE;
	wire [1:0] branchHistoryF;
	wire [1:0] branchHistoryD;
	PCBranchBufForStep3 branchPredictor(clk, rfreset, branchF, branchE, branchIsCorrectE,pcf, pce,immF, branchHistoryE, pcsrce, predictF,PCIfTaken,branchHistoryF);
	//fetch
	mux3 #(32) pcmux(pcSourcePredicted, pcbranche,jumpadr, {pcsrcd[1], ~branchIsCorrectE}, pcnext);
	
	//enablereg #(32) pcreg(clk, ~stallf, pcnext, pcf);
	flopr #(32) pcreg(clk, rfreset, ~(stallf | pig2), pcnext, pcf);
	inst_memory i_mem(pcf, instrf); //instruction memory
	assign pcplus4f = pcf + 32'b100; // PC+4

	fetchtodec f2d(clk, ((~branchIsCorrectE) | pcsrcd[1]|rfreset), ~(stalld | pig2),instrf,pcplus4f, predictF, pcf, branchHistoryF, instrd,pcplus4d, predictD,pcd,branchHistoryD); // fetch to decode stage register
	//dec
	assign jumpadr = {pcplus4d[31:28],instrd[25:0],2'b00}; // s25l2
	assign opd = instrd[31:26]; // op-code
	assign functd = instrd[5:0]; //func for control unit
	regfile rf(~clk, regwritew, rfreset, instrd[25:21], instrd[20:16], writeregw, resultw, rd1, rd2); //register file unit
	extend ext(instrd[15:0], se_ze, immext); // extent mudoule output as SignImmD labled in the diagram
	assign pcTakeD = {immext[29:0], 2'b00} + pcplus4d; // PCBranchD
	
	assign equaldin1 = forwardad ? A : rd1; //2to1 mux for equalD
	assign equaldin2 = forwardbd ? A : rd2; //2to1 mux for equalD
	assign equald = eq_ne ? (equaldin1 == equaldin2) : (equaldin1 != equaldin2); // the equal compare module
	// Decode to excuted stage register
	wire [31:0] instre;// for debug
	resetclearenablereg #(125+32+67+32+2) d2e(clk,rfreset, (flushe| ~branchIsCorrectE),~pig2, {instrd,branchHistoryD,pcd,pcsrcd[0],pcplus4d, pcTakeD, predictD, branchd, mul_signd,startmuld,outseld,regwrited, memtoregd, memwrited,alucontrold,alusrcd,regdstd,rd1,rd2,instrd[25:21],instrd[20:16],instrd[15:11],immext,memenabled},
						{instre,branchHistoryE,pce, pcsrce,pcplus4e,pcTakeE, predictE,branchE,mul_signe,startmule,outsele,regwritee, memtorege, memwritee,alucontrole,alusrce,regdste,rd1e,rd2e,rse,rte,rde,immexte,memenableE});
	assign pcbranche = (pcsrce) ? pcTakeE : pcplus4e;
	assign branchIsCorrectE = (pcsrce == predictE);
	
	assign writerege = regdste ? rde : rte;// 2to1 mux for writeRegE
	assign srcae = forwardae[1] ? A : (forwardae[0] ? resultw : rd1e);// 3to1 mux for srcAE
	assign writedatae = forwardbe[1] ? A : (forwardbe[0] ? resultw : rd2e);// 3to1 mux for WriteDataE
	assign srcbe = alusrce ? immexte : writedatae;// 2to1 mux for SrcBE
	ALU alumodule(srcae, srcbe,alucontrole,aluoute);// ALU moudle
	//multiplier multmodule(srcae, srcbe, clk, startmule,mul_signe,muloute);// Multiplier module
	laji_mult multmodule(srcae, srcbe, clk, rfreset, startmule, mul_signe, muloute, isready);
	assign mulregout = muloute; // Multiplier register
	//multreg multregmodule(clk, muloute, mulregout);
	// excution to memory stage register
	wire [31:0] instrm;
	clearenablereg #(107+32) e2m(clk, rfreset,~pig2, {instre,outsele, regwritee,memtorege,memwritee,aluoute,writedatae,writerege,immexte[15:0],16'b0,memenableE},
				  {instrm,outselm, regwritem,memtoregm,memwritem,aluoutm,writedatam,writeregm,immextm,memenablem});
	//4-1 Mux for Data Memory input A
	mux4 #(32) aluoutmmux(mulregout[63:32],mulregout[31:0],aluoutm,immextm,outselm,A);
	//wire memstall; //mem enable when lw and sw
	cachesystem cs(clk, rfreset, A, writedatam, memwritem, memenablem, rdm, memstall);// coment out to test the performance
	wire mem_ready; //mei yong de	
	/*memory mem (clk, reset, memenablem, memwritem,
		A,
		writedatam,
		rdm,
		mem_ready);*/
	//data_memory dmem(clk, memwritem, A, writedatam, rdm);// Data Memory module
	//Memory to WriteBack stage register 
	clearenablereg #(71) m2w(clk, (rfreset), ~pig2,{regwritem,memtoregm,rdm,A,writeregm},{regwritew,memtoregw,readdataw,aluoutw,writeregw});
	assign resultw = memtoregw ? readdataw : aluoutw;
	// Hazard Unit
	hazard_unit hazardmodule((isready & ~startmule), ismflomfhi, instrd[25:21],instrd[20:16],rse,rte,branchd,writerege,memtorege,regwritee,writeregm,memtoregm,regwritem,writeregw,regwritew,stallf,stalld,forwardad,forwardbd,flushe,forwardae,forwardbe);

	

endmodule