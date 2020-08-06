module posedgedetector(input data, input clk, output out);
	reg delayeddata;
	reg data_sync;
	//wire data_sync2;
	//reg [2:0] tog;
	//assign {delayeddata, data_sync, data_sync2} = tog;
	always@(posedge clk) begin
		delayeddata <= data;
		data_sync <= delayeddata;
		//if(data) tog <= 3'b111;
		//else tog <= 0;
	end
	assign out = data & ~data_sync;
endmodule
module changedetector(input [3:0] state, input clk, output out);
	reg [3:0] delayeddata;
	reg [3:0] data_sync;
	always@(posedge clk) begin
		delayeddata <= state;
		data_sync <= delayeddata;
	end
	assign out = (data_sync != state);


endmodule
module memory(input clk, input reset,input enable, input rdwr,
		input [31:0] address,
		input [31:0] mem_input,
		output reg [31:0] outputdata,
		//change add reg
		output mem_ready); 
	
	reg internalready;
	reg [4:0] counter;	
	//reg [1023:0] ram [127:0];
	reg [31:0] ram [1048576:0];
	


	//new change
	reg tmpenable;
	//assign mem_ready = (~tmpenable) & internalready;
	wire enableedge;
	posedgedetector detectenable(enable,clk,enableedge);
	assign mem_ready = (~enableedge) & internalready;

	always @(posedge clk) begin
		if(reset) begin 
			internalready <=1;
			//mem_ready <= (~enable) & internalready;
		end
		else if(counter > 2) begin
			counter <= counter -1;
		end else if(counter ==2) begin
			if(rdwr) ram[address[31:2]] <= mem_input;
			outputdata <= ram[address[31:2]];
			counter <= 1;
			internalready <= 1;
			tmpenable <= 0;
			//mem_ready <= 1;
			
			
		end else if(counter==1)begin
			counter <=0;
		end
		else if(enable) begin
			counter <= 21; //changed from 21
			internalready <= 0;
			tmpenable <= enable;
//			mem_ready <= (~enable) & internalready;		
		end
	end
endmodule
