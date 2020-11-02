// Verilog example
module whisky_registers(
	input 				clk,
	input 				we,
	input		[2:0] 	sel_a,
	input		[2:0] 	sel_b,
	input 		[2:0] 	sel_w,
	input		[15:0]	data_in,
	output reg	[15:0]	data_a,
	output reg	[15:0]	data_b
);	
	reg	[15:0] registers [7:0];
	//Asynchronous
	always @* begin
		// Port A
		if(sel_a==0)//Register 0 always returns 0
			data_a=0;
		else
			data_a=registers[sel_a];
			
		//Port B
		if(sel_b==0)//Register 0 always returns 0
			data_b=0;
		else
			data_b=registers[sel_b];
	end
	//Synchronous proccess(no reset, might need reset)
	always @(posedge clk) begin
		if(we)
			registers[sel_w]<=data_in;
	end
	
endmodule 