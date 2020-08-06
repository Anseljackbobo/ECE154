
module cache_control (input [31:0]aluout,
	//input  [31:0]writedatam, 
	input  enable, clk, reset, mem_ready, memwrite,
	output [1:0]offset_top, [6:0]index, 
	output which_cache, enable_cache, cache_wr, 
	output [1:0]cache_sel,
	output mem_en, mem_rw,
	output [31:0] address,
	output cachedatainselect, stallm, ruozhiout);
	wire [1:0] offset1;
	
	wire [20:0]tag;
	//wire [6:0] index;
	reg u [127:0];
	reg [21:0] cachectr1 [127:0];
	reg [21:0] cachectr2 [127:0];
	
	assign tag = aluout[31:11];
	assign index = aluout[10:4];
	assign offset1 = aluout[3:2];

	wire available;
	assign available = (~cachectr1[index][21]) || (~cachectr2[index][21]);

	wire encoin1;
	assign encoin1 = (cachectr1[index][20:0] == tag) & cachectr1[index][21]; 
	wire encoin2;
	assign encoin2 = (cachectr2[index][20:0] == tag) & cachectr2[index][21];

	//wire [21:0] tempfordebug1,tempfordebug1;
	

	wire encoderout;
	assign encoderout = encoin1 ? 0 : (encoin2 ? 1 : 0);
	wire hit;
	assign hit = encoin1 | encoin2;

	wire toggle_u, change_tag, memadrsel;
	wire [1:0] offset2;
	wire setv;

	integer i;

	always@(posedge clk) begin

		if(toggle_u)begin
	  		u[index] = ~u[index];
	 	end
		if(setv) begin
			if(which_cache) cachectr2[index][21] <= 1;
			else cachectr1[index][21] <= 1;				
		end
		if(change_tag) begin
			if(which_cache) cachectr2[index][20:0] <= tag;
			else cachectr1[index][20:0]<=tag;
		end
		if(reset) begin
			for(i = 0;i<10'b1111111111;i = i + 1) begin
				u[i] = 0;
				cachectr1[i][21] = 0;
				cachectr2[i][21] = 0;
			end
		end
	end
	
	wire which_offset;
	FSM fsm (clk, reset, enable, encoderout, hit, u[index], mem_ready, memwrite, available, aluout[3:2] ,toggle_u, change_tag, which_cache, enable_cache,
			cache_wr, cache_sel, mem_en, mem_rw, offset2, memadrsel, cachedatainselect, stallm,setv,ruozhiout, which_offset);

	wire [31:0] addrencoin1, addrencoin2;
	assign addrencoin1 = {cachectr1[index][20:0], index, offset2, 2'b00};
	assign addrencoin2 = {cachectr2[index][20:0], index, offset2, 2'b00};
	//assign address = memadrsel ? encoin1 : encoin2;
	assign address = which_cache ? addrencoin2 : addrencoin1;

	assign offset_top = which_offset ? offset2 : offset1;

	
endmodule

//write = 0 is read otherwise write, hit = 0 is mis otherwise read

module FSM (input clk, reset, enable, encoderout, hit, u, mem_ready, write, v,
	input [1:0] aluoffset,
	output toggle_u, change_tag, which_cache, enable_cache, cache_wr, 
	output [1:0] cache_sel,
	output	mem_en, mem_rw, 
	output [1:0] offset, 
	output memadrsel, cachedatainsel,
	output stallm,
	output setv,
	output ruozhiout, which_offset);

	reg [19:0] FSMcontrols;
	reg [3:0] state;
	//reg [3:0] nextstate;

	reg  tmp;
	wire [3:0] nextstate;
	assign {nextstate, setv, stallm, toggle_u, change_tag, which_cache, enable_cache, cache_wr, cache_sel,
		mem_en, mem_rw, offset, memadrsel, cachedatainsel, which_offset} = FSMcontrols;
	changedetector ruozhi2(state, clk, ruozhiout);
	
	
	


	/*always @(posedge reset) begin
			state <= 0;
			stallm <= 0;
		if(!reset)  state = nextstate;

	end*/
	/*always @(posedge clk) begin
		if(enable) stallm <=1;
	end*/
	
	always @(posedge clk, posedge reset)  begin
      		if(reset) begin
        /*		state <= 0;
			stallm <= 0;
			nextstate <=0;
			setv <= 0;*/
		FSMcontrols = 19'b0;
      		end
     		else if(mem_ready) #1 state = nextstate;
    	end


	//always @(posedge (clk&mem_ready)) begin
	always @(*) begin
		//#2;
		
		
		case(state)
			4'h0: FSMcontrols <= (enable) ? (hit? (write? {4'b0001,1'b0,1'b0,2'b00, encoderout, 8'b00000000, encoderout, 2'b0}:
							{4'b0010,1'b0,1'b0,2'b00, encoderout, 8'b00000000, encoderout, 2'b0}) : ( v?  
							{4'b0100,1'b0,1'b1,2'b00, encoderout, 8'b00000000, encoderout, 2'b0}:
							{4'b0011,1'b0,1'b1,2'b00, encoderout, 8'b00000000, encoderout, 2'b0})) : 0;
					
			4'h1: FSMcontrols <= {4'b0000,1'b0,1'b1,(u==which_cache),1'b0, encoderout, 2'b11, aluoffset, 4'b0000,
						encoderout, 2'b0};
	
			
			4'h2: FSMcontrols <= {4'b0000,1'b0,1'b1,(u==which_cache),1'b0, encoderout, 2'b10, aluoffset, 4'b0000,
						encoderout, 2'b0};

			4'h3: FSMcontrols <= {4'b0101,1'b0,1'b1,1'b0,1'b0, u, 2'b10, 3'b001, 3'b100,
						encoderout, 1'b0, 1'b1};

			4'h4: FSMcontrols <= {4'b1000,1'b0,1'b1,1'b0,1'b1, u, 2'b11, 2'b00, 2'b10,2'b00,
						encoderout, 2'b10};
			
			4'h5: FSMcontrols <= {4'b0110,1'b0,1'b1,1'b0,1'b0, u, 2'b10, 2'b01, 2'b11,2'b01,
						encoderout, 1'b0, 1'b1};
			
			4'h6: FSMcontrols <= {4'b0111,1'b0,1'b1,1'b0,1'b0, u, 2'b10, 2'b10, 2'b11,2'b10,
						encoderout, 1'b0, 1'b1};
			
			4'h7: FSMcontrols <= {4'b0100,1'b0,1'b1,1'b0,1'b0, u, 2'b10, 2'b11, 2'b11,2'b11,
						encoderout, 1'b0, 1'b1};
		
			4'h8: FSMcontrols <= {4'b1001,1'b0,1'b1,1'b0,1'b0, u, 2'b11, 2'b01, 2'b10,2'b01,
						encoderout, 1'b1,1'b0};
			
			4'h9: FSMcontrols <= {4'b1010,1'b0,1'b1,1'b0,1'b0, u, 2'b11, 2'b10, 2'b10,2'b10,
						encoderout, 1'b1,1'b0};
			
			4'ha: FSMcontrols <= write ? {4'b0001,1'b1,1'b1,1'b0,1'b0, u, 2'b11, 2'b11, 2'b10,2'b11,
						encoderout, 1'b1,1'b0} :
						{4'b0010,1'b0,1'b1,1'b0,1'b0, encoderout, 2'b11, 2'b11, 2'b10,2'b11,
						encoderout, 1'b1,1'b0};
			

		endcase
		if (state == 4'h3) $display("time is %0t",$time);
	end
endmodule