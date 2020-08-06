module PCBranchBufForStep3(input clk, reset, enableF, branchE, branchIsCorrectE,
			   input [31:0] PC, PCE,
			   input [15:0] immF,
			   input [1:0] branchHistoryE,
			   input pcsrce0,
			   output predictF,
			   output [31:0] PCIfTaken,
			   output [1:0] branchHistoryOut);

	reg valid[3:0][127:0];
	reg [31:0] PCRam[127:0];
	reg [31:0] PCTake[127:0];



	reg [1:0] state[3:0][127:0];
	reg [1:0] branchHistoryF;
	assign branchHistoryOut = branchHistoryF;
	
	integer i;
	
	wire hit;
	assign hit = valid[branchHistoryF][PC[8:2]] & (PC == PCRam[PC[8:2]]);

	assign predictF = state[branchHistoryF][PC[8:2]][1] & hit;
	//assign PCIfTaken = valid[PC[8:2]] ? 0 : PCTake[PC[8:2]];
	assign PCIfTaken = PCTake[PC[8:2]];
	always @(posedge clk, reset) begin
		if(reset) begin
			for(i = 0;i <128 ;i = i + 1) begin
				valid[0][i] <= 0;
				valid[1][i] <= 0;
				valid[2][i] <= 0;
				valid[3][i] <= 0;

				state[0][i] <= 0;
				state[1][i] <= 0;
				state[2][i] <= 0;
				state[3][i] <= 0;
				PCRam[i] <= 0;
				PCTake[i] <= 0;
				branchHistoryF <= 0;
			end
		end
		if(enableF) begin
			if(~hit) begin // if miss
				PCRam[PC[8:2]] <= PC;
				PCTake[PC[8:2]] <= PC + 4 + {{14{immF[15]}},immF,2'b00};
				valid[branchHistoryF][PC[8:2]] <= 1;
				state[branchHistoryF][PC[8:2]] <= 0;
			end
			
		end
		if(branchE) begin // update state
			branchHistoryF <= {pcsrce0, branchHistoryF[1]};
			case({state[branchHistoryE][PCE[8:2]], branchIsCorrectE})
				3'b000: state[branchHistoryE][PCE[8:2]] <= 2'b01; // Strong NotTake & incorrect
				3'b001: state[branchHistoryE][PCE[8:2]] <= 2'b00; // Strong NotTake & correct
				3'b010: state[branchHistoryE][PCE[8:2]] <= 2'b10; // Weak NotTake & incorrect
				3'b011: state[branchHistoryE][PCE[8:2]] <= 2'b00; // Weak NotTake & correct
				3'b100: state[branchHistoryE][PCE[8:2]] <= 2'b01; // Weak Take & incorrect
				3'b101: state[branchHistoryE][PCE[8:2]] <= 2'b11; // Weak Take & correct
				3'b110: state[branchHistoryE][PCE[8:2]] <= 2'b10; // Strong Take & incrrect
				3'b111: state[branchHistoryE][PCE[8:2]] <= 2'b11; // Strong take & correct
				default: state[branchHistoryE][PCE[8:2]] <= 2'b00; 
			endcase

		end
	end


endmodule



/*
module DynamicPredicBuffer();

	reg [127:0] bht [65:0];
	wire [6:0] index;
	

	
	
endmodule

module takenFSM (input [1:0] state, input taken, clk, reset, output [1:0] nextstate, output predictTaken);

reg [3:0] out;
assign {nextstate,predictTaken} = out;

//state 00 is strong not taken, state 01 is weak not taken, state 10 is weak taken, state 11 is strong taken.

	always @* begin
		case (state)
			2'b00:
				out <= taken ? 3'b010 : 3'b000;
			2'b01:
				out <= taken ? 3'b101 : 3'b000;
			2'b10: 
				out <= taken ? 3'b111 : 3'b010;
			2'b11:
				out <= taken ? 3'b111 : 3'b101;
		endcase
	 end
endmodule 
*/
