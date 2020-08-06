module Controller (input EqualD, input [5:0] OP,input [5:0] Func, /*input clk,*/ input reset, output MemWrite, /*output jump,*/
	output [1:0] OutSelect, output RegWrite, output ALUSrcB, output Se_ze, output RegDst,
	output Start_mult, output Mult_sign, output MemtoReg, output Eq_ne, output Branch, output [1:0] PCSrcD, output [3:0] ALU_Op);
	
	reg [16:0] controls;
	wire jump;

	assign {jump,MemWrite, OutSelect, RegWrite, ALUSrcB, Se_ze, RegDst,Start_mult, Mult_sign, MemtoReg, Eq_ne, Branch, ALU_Op} = controls;
	assign PCSrcD = {jump, (Branch&EqualD)};
	
	always @* begin
		if (reset) begin
		controls <= 17'b0;
		end else begin	
		
		case(OP)
			6'b001000: controls <= 17'b00101110000000010; // addi
			6'b001001: controls <= 17'b00101110000000011; // addiu
			6'b001100: controls <= 17'b00101100000000000; // andi
			6'b001101: controls <= 17'b00101100000000001; // ori
			6'b001110: controls <= 17'b00101100000000110; // xori
			6'b001010: controls <= 17'b00101110000001000; // slti
			6'b001011: controls <= 17'b00101110000001001; // sltiu
			6'b100011: controls <= 17'b00101110001000010; // lw
			6'b101011: controls <= 17'b01100110000000010; // sw
			6'b001111: controls <= 17'b00111100000000000; // lui
			6'b000010: controls <= 17'b10000000000000000; // j
			6'b000101: controls <= 17'b00000010000010000; // bne
			6'b000100: controls <= 17'b00000010000110000; // beq
			default:
				case(Func)
					6'b100000: controls <= 17'b00101001000000010; //add
					6'b100001: controls <= 17'b00101001000000011; //addu
					6'b100010: controls <= 17'b00101001000000100; //sub
					6'b100011: controls <= 17'b00101001000000101; //subu
					6'b100100: controls <= 17'b00101001000000000; //and
					6'b100101: controls <= 17'b00101001000000001; //or
					6'b100110: controls <= 17'b00101001000000110; //xor
					6'b101010: controls <= 17'b00101001000001000; //slt
					6'b101011: controls <= 17'b00101001000001001; //sltu
					6'b011000: controls <= 17'b00000000110000000; //mult
					6'b011001: controls <= 17'b00000000100000000; //multu
					6'b010000: controls <= 17'b00001001000000000; //mfhi
					6'b010010: controls <= 17'b00011001000000000; //mflo
					default: controls <= 17'b00101001000000111; //xnor
				endcase
				
		endcase
		end
	end
				
endmodule
