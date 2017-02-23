module requester #(parameter id,WIDTH)
(input clk, input reset, input full, input almost_full, //inputs from noc_req 
 input [WIDTH-1:0] request, //ID (E,W,L) 
 output reg [WIDTH-1:0] dataOut, 
 output reg write //output to noc_req
 );

reg [WIDTH-1:0] pre_request;

always@(posedge clk, posedge reset) begin

	if (reset) begin
		dataOut<=0;
		write <=0;
		pre_request <=0;
	end
	else begin
		if (request[0] == 1 && request != pre_request) begin
			if ((write & almost_full)|(~write & full)) 
				write <=1'b0; 
			else begin //issue a new request 
				write <= 1'b1;
				dataOut <= request; //Request new data
				pre_request <=  request;
			end
		end
		else begin
			write <=1'b0; 
			dataOut <= 0; //Request new data
		end
	end
end

endmodule
