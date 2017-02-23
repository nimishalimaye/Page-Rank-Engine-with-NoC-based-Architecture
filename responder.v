module responder  #(parameter WIDTH=16,ADDWIDTH=4)
(input clk,
 input reset,
 input full,
 input almost_full, //From responder NoC 
 input [WIDTH+4:0] dataScore, //From pagerank
 input [8:0]dataIn, //From requester
 output reg [WIDTH+4:0] dataOut,//To responder NoC
 output reg write //To responder NoC
 );

localparam DEPTH=2**ADDWIDTH;
reg [WIDTH-1:0] i;
reg [WIDTH-1:0] myData [DEPTH-1:0]; //8 16-bit registers
reg [3:0] pointer;


always @ (posedge clk, posedge reset) begin 
	if (reset) begin
		for (i=0; i<DEPTH; i=i+1) begin
			pointer = i[3:0];
			myData[pointer] <= 16'h4000; // reset to (1/N) = 0.25. Note --- Please update based on N.
		end
   	end
   	else begin
		if(dataScore[0] == 1'b1)
			myData[dataScore[4:1]] <= dataScore[20:5];
   	end
end


always @ (posedge clk, posedge reset) begin

	pointer = dataIn[8:5];

	if(reset || dataIn[0] == 0) begin
		write <=0;
		dataOut <=0;
	end
	else begin
		if (dataIn[0] == 1 ) begin
			if ((write & almost_full)|(~write & full)) 
				write <=1'b0; 
			else begin //issue a new request data 
				write <= 1'b1;
				dataOut <= {myData[pointer],dataIn[2:1],dataIn[4:3],1'b1}; //Request new data
			end
		end
	end
end


endmodule
