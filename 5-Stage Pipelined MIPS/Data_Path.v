module data_path(input [1:0] pcsrcd, input clk, input rfreset, input se_ze, input eq_ne, input branchd,
		 input mul_signd, startmuld,
		 input [1:0] outseld,
		 input regwrited, memtoregd, memwrited,
		 input [3:0] alucontrold,
		 input alusrcd, regdstd,
		 output [5:0] opd, output [5:0] functd, output equald);
	// fetch
	wire [31:0] pcplus4f, pcbranchd, jumpadr, pcnext, pcf, instrf;
	//dec
	wire [31:0] instrd, pcplus4d, rd1, rd2, immext;
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
	assign ismflomfhi = ({instrd[31:26], instrd[5:1]} == 11'b00000001001);
	//fetch
	mux3 #(32) pcmux(pcplus4f, pcbranchd,jumpadr, pcsrcd, pcnext);
	
	//enablereg #(32) pcreg(clk, ~stallf, pcnext, pcf);
	flopr #(32) pcreg(clk, rfreset, ~stallf, pcnext, pcf);
	inst_memory i_mem(pcf, instrf); //instruction memory
	assign pcplus4f = pcf + 32'b100; // PC+4

	fetchtodec f2d(clk, (pcsrcd[0] | pcsrcd[1]), ~stalld,instrf,pcplus4f,instrd,pcplus4d); // fetch to decode stage register
	//dec
	assign jumpadr = {pcplus4d[31:28],instrd[25:0],2'b00}; // s25l2
	assign opd = instrd[31:26]; // op-code
	assign functd = instrd[5:0]; //func for control unit
	regfile rf(~clk, regwritew, rfreset, instrd[25:21], instrd[20:16], writeregw, resultw, rd1, rd2); //reister file unit
	extend ext(instrd[15:0], se_ze, immext); // extent mudoule output as SignImmD labled in the diagram
	assign pcbranchd = {immext[29:0], 2'b00} + pcplus4d; // PCBranchD
	
	assign equaldin1 = forwardad ? A : rd1; //2to1 mux for equalD
	assign equaldin2 = forwardbd ? A : rd2; //2to1 mux for equalD
	assign equald = eq_ne ? (equaldin1 == equaldin2) : (equaldin1 != equaldin2); // the equal compare module
	// Decode to excuted stage register
	clearreg #(124) d2e(clk, flushe, 	{mul_signd,startmuld,outseld,regwrited, memtoregd, memwrited,alucontrold,alusrcd,regdstd,rd1,rd2,instrd[25:21],instrd[20:16],instrd[15:11],immext},
						{mul_signe,startmule,outsele,regwritee, memtorege, memwritee,alucontrole,alusrce,regdste,rd1e,rd2e,rse,rte,rde,immexte});
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
	normalreg #(106) e2m(clk, {outsele, regwritee,memtorege,memwritee,aluoute,writedatae,writerege,immexte[15:0],16'b0},
				  {outselm, regwritem,memtoregm,memwritem,aluoutm,writedatam,writeregm,immextm});
	//4-1 Mux for Data Memory input A
	mux4 #(32) aluoutmmux(mulregout[63:32],mulregout[31:0],aluoutm,immextm,outselm,A);
	data_memory dmem(clk, memwritem, A, writedatam, rdm);// Data Memory module
	//Memory to WriteBack stage register 
	normalreg #(71) m2w(clk,{regwritem,memtoregm,rdm,A,writeregm},{regwritew,memtoregw,readdataw,aluoutw,writeregw});
	assign resultw = memtoregw ? readdataw : aluoutw;
	// Hazard Unit
	hazard_unit hazardmodule((isready & ~startmule), ismflomfhi, instrd[25:21],instrd[20:16],rse,rte,branchd,writerege,memtorege,regwritee,writeregm,memtoregm,regwritem,writeregw,regwritew,stallf,stalld,forwardad,forwardbd,flushe,forwardae,forwardbe);


endmodule