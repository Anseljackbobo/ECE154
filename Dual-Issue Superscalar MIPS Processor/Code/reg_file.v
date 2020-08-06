
module regfile(input clk,
               input Write,
	       input Reset,	
               input [4:0] PR1, PR2, WR,
               input [31:0] WD,
               output [31:0] RD1, RD2);
               
  reg [31:0] rf[31:0];
  
  always @(posedge clk) begin
    
    if ( Write && ~Reset) rf[WR] <= WD;
  
	
	if(Reset) begin
		
		rf[0] = 32'b0;
		rf[1] = 32'b0;
		rf[2] = 32'b0;
		rf[3] = 32'b0;
		rf[4] = 32'b0;
		rf[5] = 32'b0;
		rf[6] = 32'b0;
		rf[7] = 32'b0;
		rf[8] = 32'b0;
		rf[9] = 32'b0;
		rf[10] = 32'b0;
		rf[11] = 32'b0;
		rf[12] = 32'b0;
		rf[13] = 32'b0;
		rf[14] = 32'b0;
		rf[15] = 32'b0;
		rf[16] = 32'b0;
		rf[17] = 32'b0;
		rf[18] = 32'b0;
		rf[19] = 32'b0;
		rf[20] = 32'b0;
		rf[21] = 32'b0;
		rf[22] = 32'b0;
		rf[23] = 32'b0;
		rf[24] = 32'b0;
		rf[25] = 32'b0;
		rf[26] = 32'b0;
		rf[27] = 32'b0;
		rf[28] = 32'b0;
		rf[29] = 32'b11111100;
		rf[30] = 32'b0;
		rf[31] = 32'b0;
		

	end
     end

  assign RD1 = (PR1 != 0) ? rf[PR1] : 0;
  assign RD2 = (PR2 != 0) ? rf[PR2] : 0;
endmodule






module regfile_especially_for_lab4(input clk,
               input Write_1, Write_2,
	       input Reset,	
               input [4:0] PR1_1, PR2_1, WR_1,
               input [31:0] WD_1,
               output [31:0] RD1_1, RD2_1,
	       input [4:0] PR1_2, PR2_2, WR_2,
               input [31:0] WD_2,
               output [31:0] RD1_2, RD2_2);
               
  reg [31:0] rf[31:0];
  
  always @(posedge clk) begin
    
    if ( Write_1 && ~Reset) rf[WR_1] <= WD_1;
    if ( Write_2 && ~Reset) rf[WR_2] <= WD_2;
	
	if(Reset) begin
		
		rf[0] = 32'b0;
		rf[1] = 32'b0;
		rf[2] = 32'b0;
		rf[3] = 32'b0;
		rf[4] = 32'b0;
		rf[5] = 32'b0;
		rf[6] = 32'b0;
		rf[7] = 32'b0;
		rf[8] = 32'b0;
		rf[9] = 32'b0;
		rf[10] = 32'b0;
		rf[11] = 32'b0;
		rf[12] = 32'b0;
		rf[13] = 32'b0;
		rf[14] = 32'b0;
		rf[15] = 32'b0;
		rf[16] = 32'b0;
		rf[17] = 32'b0;
		rf[18] = 32'b0;
		rf[19] = 32'b0;
		rf[20] = 32'b0;
		rf[21] = 32'b0;
		rf[22] = 32'b0;
		rf[23] = 32'b0;
		rf[24] = 32'b0;
		rf[25] = 32'b0;
		rf[26] = 32'b0;
		rf[27] = 32'b0;
		rf[28] = 32'b0;
		rf[29] = 32'b11111100;
		rf[30] = 32'b0;
		rf[31] = 32'b0;
		

	end
     end

  assign RD1_1 = (PR1_1 == 0) ? 0 : 
		 (( Write_2 && ~Reset) && (WR_2 == PR1_1)) ? WD_2 : 
		 (( Write_1 && ~Reset) && (WR_1 == PR1_1)) ? WD_1 : 
		 rf[PR1_1];
  assign RD2_1 = (PR2_1 == 0) ? 0 : 
		 (( Write_2 && ~Reset) && (WR_2 == PR2_1)) ? WD_2 : 
		 (( Write_1 && ~Reset) && (WR_1 == PR2_1)) ? WD_1 : 
		 rf[PR2_1];

  assign RD1_2 = (PR1_2 == 0) ? 0 : 
		 (( Write_2 && ~Reset) && (WR_2 == PR1_2)) ? WD_2 : 
		 (( Write_1 && ~Reset) && (WR_1 == PR1_2)) ? WD_1 : 
		 rf[PR1_2];
  assign RD2_2 = (PR2_2 == 0) ? 0 : 
		 (( Write_2 && ~Reset) && (WR_2 == PR2_2)) ? WD_2 : 
		 (( Write_1 && ~Reset) && (WR_1 == PR2_2)) ? WD_1 : 
		 rf[PR2_2];
endmodule
