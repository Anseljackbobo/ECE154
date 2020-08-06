module hazard(	// branch related
		input [4:0] WriteRegD_1, WriteRegD_2,
		input RegWriteD_1, RegWriteD_2,

		input reset,
		//dp1
		output [1:0] ForwardAD_1, ForwardBD_1,
		output reg [2:0] ForwardAE_1, ForwardBE_1,
		input [4:0] RsD_1, RtD_1,
		input [4:0] RsE_1, RtE_1,
		input RegWriteE_1, MemtoRegE_1,
		input RegWriteM_1, MemtoRegM_1,
		input [4:0] WriteRegM_1, WriteRegW_1,
		input RegWriteW_1,

		//dp2
		output [1:0] ForwardAD_2, ForwardBD_2,
		output reg [2:0] ForwardAE_2, ForwardBE_2,
		input [4:0] RsD_2, RtD_2,
		input [4:0] RsE_2, RtE_2,
		input RegWriteE_2, MemtoRegE_2,
		input RegWriteM_2, MemtoRegM_2,
		input [4:0] WriteRegM_2, WriteRegW_2,
		input RegWriteW_2,

		//fetch stage early noop predict
		input RegWriteF_1, RegWriteF_2,
		input RegDstF_1, RegDstF_2,
		input BranchF_1, BranchF_2, // BranchF2 may not be used/Branch could not be in slot2
		input MemEnableF_1, MemEnableF_2,
		input [4:0] RsF_1, RsF_2,
		input [4:0] RtF_1, RtF_2,
		input [4:0] RdF_1, RdF_2,
		input JumpF_1, JumpF_2,
		input IsLoadWordD_1, IsLoadWordD_2,
		output NoopSlotF2,
		
	 
		// stall and flush
		output stallF,
		output flushD,
		output flushE,
		// branch related
		input BranchIsNotCorrectE_1
		//input BranchIsNotCorrectE_2 // NOT USED


		);

		wire lwstall;
		reg lwstall_helper;
		assign lwstall = lwstall_helper;
		always @(*) begin
			lwstall_helper <= 0;
			if(reset) lwstall_helper <= 0;
			else if(IsLoadWordD_1 && ((RsF_1 == RtD_1) || (RsF_2 == RtD_1) || (RtF_1 == RtD_1) || (RtF_2 == RtD_1))) lwstall_helper <= 1;
			else if(IsLoadWordD_2 && ((RsF_1 == RtD_2) || (RsF_2 == RtD_2) || (RtF_1 == RtD_2) || (RtF_2 == RtD_2))) lwstall_helper <= 1;

		end

		wire branchStall;
		assign branchStall = BranchIsNotCorrectE_1;


		reg branchStall_original;// handle branch that use last instructions
		always @(*) begin
			branchStall_original <= 0;

			if(BranchF_1) begin
				if((RsF_1==WriteRegD_1) & RegWriteD_1) branchStall_original <= 1;
				else if((RtF_1==WriteRegD_1) & RegWriteD_1) branchStall_original <= 1;
				else if((RsF_1==WriteRegD_2) & RegWriteD_2) branchStall_original <= 1;
				else if((RtF_1==WriteRegD_2) & RegWriteD_2) branchStall_original <= 1;
			end
		end

		assign stallF = lwstall | branchStall | branchStall_original;
		assign flushD = lwstall | branchStall | branchStall_original;
		assign flushE = branchStall;



		wire [4:0] WriteRegF_1, WriteRegF_2;
		assign WriteRegF_1 = RegDstF_1 ? RdF_1 : RtF_1;
		assign WriteRegF_2 = RegDstF_2 ? RdF_2 : RtF_2;

		reg noop_helper;
		assign NoopSlotF2 = noop_helper;
		always @(*) begin
			noop_helper <= 0;
			if(reset==1) noop_helper <= 0;
			else if(JumpF_1==1) begin noop_helper <= 1; $display("noop case1 %0t", $time);end
			else if(JumpF_2==1)  begin noop_helper <= 1; $display("noop case2 %0t", $time); end 
			else if(BranchF_1==1) begin noop_helper <= 1; $display("noop case3 %0t", $time);end
			else if(BranchF_2==1) begin noop_helper <= 1; $display("noop case4 %0t", $time);end
			else if(MemEnableF_1 & MemEnableF_2) begin noop_helper <= 1; $display("noop case5 %0t", $time);end
			else if(RegWriteF_1) begin
				if(RegDstF_2) begin
					 
					if((RtF_2 == WriteRegF_1) | (RsF_2 == WriteRegF_1))begin noop_helper <= 1; $display("noop case6 %0t", $time);end
				end
				else begin
					if(RsF_2 == WriteRegF_1) begin noop_helper <= 1; $display("noop case7 %0t", $time);end
				end
			end
			//else begin noop_helper <= 0; $display("noop case8 %0t", $time);end
		end


		reg [1:0] forwardAD_1, forwardBD_1;
		reg [1:0] forwardAD_2, forwardBD_2;

		assign ForwardAD_1 = forwardAD_1;
		assign ForwardAD_2 = forwardAD_2;
		assign ForwardBD_1 = forwardBD_1;
		assign ForwardBD_2 = forwardBD_2;
		//Decode stage forwarding
		always @(*) begin
			forwardAD_1 = 2'b00;
			if(RsD_1 != 0 & (RsD_1 == WriteRegM_1) & RegWriteM_1)  forwardAD_1 = 2'b01;
			else if(RsD_1 != 0 & (RsD_1 == WriteRegM_2) & RegWriteM_2)  forwardAD_1 = 2'b10;
			
			forwardAD_2 = 2'b00;
			if(RsD_2 != 0 & (RsD_2 == WriteRegM_2) & RegWriteM_2)  forwardAD_2 = 2'b01;
			else if(RsD_2 != 0 & (RsD_2 == WriteRegM_1) & RegWriteM_1)  forwardAD_2 = 2'b10;
			
			forwardBD_1 = 2'b00;
			if(RtD_1 != 0 & (RtD_1 == WriteRegM_1) & RegWriteM_1) forwardBD_1 = 2'b01;
			else if (RtD_1 != 0 & (RtD_1 == WriteRegM_2) & RegWriteM_2) forwardBD_1 = 2'b10;
		
			forwardBD_2 = 2'b00;
			if((RtD_2 != 0) & (RtD_2 == WriteRegM_2) & RegWriteM_2) forwardBD_2 = 2'b01;
			else if (RtD_2 != 0 & (RtD_2 == WriteRegM_1) & RegWriteM_1) forwardBD_2 = 2'b10;

		end

		
		// execute stage forwarding
		always @* begin
			// for dp1
			ForwardAE_1 <= 3'b000; 
			ForwardBE_1 <= 3'b000; 
			if (RsE_1 != 0) begin
				if ((RsE_1 == WriteRegM_1) & RegWriteM_1) begin
					ForwardAE_1 <= 3'b010;
				end
				else if ((RsE_1 == WriteRegW_1) & RegWriteW_1) begin
					ForwardAE_1 <= 3'b001;
				end
			end
			
			if (RsE_1 != 0) begin
				if ((RsE_1 == WriteRegM_2) & RegWriteM_2) begin
					ForwardAE_1 <= 3'b100;
				end
				else if ((RsE_1 == WriteRegW_2) & RegWriteW_2) begin
					ForwardAE_1 <= 3'b011;
				end
			end

			if (RtE_1 != 0) begin
				if ((RtE_1 == WriteRegM_1) & RegWriteM_1) begin
					ForwardBE_1 <= 3'b010;
				end
				else if ((RtE_1 == WriteRegW_1) & RegWriteW_1) begin
					ForwardBE_1 <= 3'b001; 
				end
			end

			if (RtE_1 != 0) begin
				if ((RtE_1 == WriteRegM_2) & RegWriteM_2) begin
					ForwardBE_1 <= 3'b100;
				end
				else if ((RtE_1 == WriteRegW_2) & RegWriteW_2) begin
					ForwardBE_1 <= 3'b011;
				end
			end
			// for dp2
			ForwardAE_2 <= 3'b000; 
			ForwardBE_2 <= 3'b000; 
			if (RsE_2 != 0) begin
				if ((RsE_2 == WriteRegM_2) & RegWriteM_2) begin
					ForwardAE_2 <= 3'b010;
				end
				else if ((RsE_2 == WriteRegW_2) & RegWriteW_2) begin
					ForwardAE_2 <= 3'b001;
				end
			end
			
			if (RsE_2 != 0) begin
				if ((RsE_2 == WriteRegM_1) & RegWriteM_1) begin
					ForwardAE_2 <= 3'b100;
				end
				else if ((RsE_2 == WriteRegW_1) & RegWriteW_1) begin
					ForwardAE_2 <= 3'b011;
				end
			end

			if (RtE_2 != 0) begin
				if ((RtE_2 == WriteRegM_2) & RegWriteM_2) begin
					ForwardBE_2 <= 3'b010;
				end
				else if ((RtE_2 == WriteRegW_2) & RegWriteW_2) begin
					ForwardBE_2 <= 3'b001; 
				end
			end

			if (RtE_2 != 0) begin
				if ((RtE_2 == WriteRegM_1) & RegWriteM_1) begin
					ForwardBE_2 <= 3'b100;
				end
				else if ((RtE_2 == WriteRegW_1) & RegWriteW_1) begin
					ForwardBE_2 <= 3'b011;
				end
			end
		end

		

endmodule 