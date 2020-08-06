module data_memory(input          clk, write,
            input   [31:0] address, write_data,
            output  [31:0] Read_data);

// **PUT YOUR CODE HERE**
  reg [31:0] RAM[63:0];
  
  assign Read_data = RAM[address[31:2]]; //word aligned
  
  always @(posedge clk) begin
    if (write) RAM[address[31:2]] <= write_data;
  end
endmodule


// Instruction memory (already implemented)
module inst_memory(input   [31:0]  address,
            output  [31:0] Read_data);

  reg [31:0] RAM[63:0];

  initial
    begin
      $readmemh("richfile.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  assign Read_data = RAM[address[31:2]]; // word aligned
endmodule
