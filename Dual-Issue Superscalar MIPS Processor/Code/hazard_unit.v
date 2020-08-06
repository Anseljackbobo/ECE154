module hazard_unit(input isready, /*input [11:0] opfunc,*/input ismflomfhi,
		input [4:0] RsD,  RtD,  RsE, RtE,
		input BranchD, input [4:0] WriteRegE, input MemtoRegE, RegWriteE,
		input [4:0] WriteRegM, input MemtoRegM, RegWriteM,
		input [4:0] WriteRegW, input RegWriteW,
		output StallF, StallD, ForwardAD, ForwardBD, FlushE, 
		output reg [1:0] ForwardAE, ForwardBE);
	
	wire lwstallD, branchstallD;
	// forwarding sources to D stage (branch equality)
	assign ForwardAD = (RsD != 0 & RsD == WriteRegM & RegWriteM) ;
	assign ForwardBD = (RtD != 0 & RtD == WriteRegM & RegWriteM);
	// forwarding sources to E stage (ALU)

	//wire ismflomfhi;
	//assign ismflomfhi = ((opfunc[11:1] == 11'b00000001001)) /*| (opfunc[11:1] == 11'b00000001100)*/;
	always @* begin
		
		 
		if (RsE != 0) begin
			if (RsE == WriteRegM & RegWriteM) begin
				ForwardAE <= 2'b10;
			end
			else if (RsE == WriteRegW & RegWriteW) begin
				ForwardAE <= 2'b01;
			end
			else ForwardAE <= 2'b00; 
		end

		if (RtE != 0) begin
			if (RtE == WriteRegM & RegWriteM) begin
				ForwardBE <= 2'b10;
			end
			else if (RtE == WriteRegW & RegWriteW) begin
				ForwardBE <= 2'b01; 
			end
			else ForwardBE <= 2'b00;
		end
	end
	// stalls
	assign  lwstallD = MemtoRegE & (RtE == RsD | RtE == RtD);
	
	assign branchstallD = BranchD & 
		(RegWriteE & 
		(WriteRegE == RsD | WriteRegE == RtD) |
		MemtoRegM &
		(WriteRegM == RsD | WriteRegM == RtD));

	assign StallD = lwstallD | branchstallD | ((~isready) & ismflomfhi);
	assign StallF = StallD;
	// stalling D stalls all previous stages
	assign FlushE = StallD;
	// stalling D flushes next stage
	
endmodule
