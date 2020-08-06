module ALU (input [31:0] In1, In2, input [3:0] Func, 
		output reg [31:0] ALUout) ;
  	//wire [31:0] BB ;
	wire [31:0] S ;
  	wire [31:0] Sub ;
	wire y2;
	wire y;
  	wire cout ;
  	wire [31:0] US;
  	

  	//assign BB = (Func[3]) ? ~In2 : In2 ;
  	assign {cout, S} = In1 + In2; //was bb signed
  	assign {cout, Sub} = In1 + ~In2 + 1; 
	assign y =(In1[31:31]> In2[31:31]||(In1[31:31]==0&&In2[31:31]==0&&In1[30:0]<In2[30:0])||(In1[31:31]==1 && In2[31:31]==1 && In1[30:0] > In2[30:0])) ? 32'b1:32'b0;
  	assign y2 = (In1 < In2 )? 32'b1 : 32'b0;
	always @ * begin
   	case (Func[3:0]) 
    		4'b0000 : ALUout <= In1 & In2 ; //and / andi
    		4'b0001 : ALUout <= In1 | In2 ; //or and ori
    		4'b0010 : ALUout <= S; //add and addi
    		4'b0011 : ALUout <= S;
    		4'b0100 : ALUout <= Sub; // sub
    		4'b0101 : ALUout <= Sub; // subu
		4'b0110 : ALUout <= In1 ^ In2; // Xor ,Xori
		4'b0111 : ALUout <= In1 ^~ In2; // Xnor ,Xnori
		4'b1000 : ALUout <= y; //SLT, SLTi
		4'b1001 : ALUout <= y2; //SLTU, SLTiU
	endcase
	end
endmodule

