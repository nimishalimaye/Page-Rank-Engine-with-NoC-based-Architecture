//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module pagerank #(parameter id,start, finish, WIDTH=16, N=64)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*WIDTH-1:0] weights,
input [WIDTH+4:0] received_packet,
//input received,
output reg [8:0]request,
output reg [20:0] my_data,
output reg [16*WIDTH+95:0] nodeValue,
output reg [WIDTH-1:0] noofcycles);


//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam d = 16'h2666;   //d = 0.15
localparam dn = 16'h0099; // d/N : NOTE --- please update based on N N=16, dn=0266, N=4 dn=099a
localparam db = 16'hd99a; //1-d: NOTE: --- please update based on d 

reg [WIDTH-1:0] nodeVal [finish-1:start]; //value of each node
reg [WIDTH+4:0] nodeVal_temp [finish-1:start]; //value of each node
//reg [WIDTH-1:0] nodevalue [finish-1:start];
reg [WIDTH-1:0] nodeVal_next [finish-1:start]; //next state node value
reg [WIDTH-1:0] nodeWeight [N-1:0]; //weight of each node
reg [N-1:0] adj [N-1:0]; //adjacency matrix
reg request_sent;
reg [WIDTH-1:0] node1Val, node2Val, node3Val, node0Val, node4Val, node5Val, node6Val, node7Val, node8Val, node9Val, node10Val, node11Val, node12Val, node13Val, node14Val, node15Val;


reg [WIDTH-1:0] i,j=start,s,b,offset_respond;
reg [WIDTH-1:0] p,q,r,k;
reg [WIDTH-1:0] c,g;
reg [WIDTH-1:0] t [N-17:0];
reg [WIDTH-1:0] m,l,offset_value_m,offset_value_s;
//reg [WIDTH-1:0] m [6:0];
//reg [WIDTH-1:0] l [6:0];
//reg [WIDTH-1:0] t [6:0];
reg [WIDTH-1:0] count,a;

reg [3*WIDTH-1:0] temp; //16bit*16bit*16bit

//Convert adj from 1D to 2D array
always @ (*) begin
	count = 0;
	for (p=0; p<N; p=p+1) begin
		for (q=0; q<N; q=q+1) begin
			adj[p][q] = adjacency[count];
			count = count+1;
		end
	end
end

//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight[r] = weights[r*WIDTH+:WIDTH];
	end
end


//Combinational logic
always @ (posedge clk,posedge reset) begin
	if (reset) begin
		for (i=start; i<finish; i=i+1) begin
			nodeVal[i] <= 16'h4000; // reset to (1/N) = 0.25. Note --- Please update based on N.
			nodeVal_next[i] <= dn;
			m<=0;
			j<=start;
			l<=0;
			request<=0;
			my_data <=0;
			noofcycles<=0;
			request_sent<=0;
		end
   	end
   	else begin
	  if (j<finish) begin
		//initialize next state node val
		
		//Go through adjacency matrix to find node's neighbours
	  if (m ==0 && request_sent == 0) begin
		for (k=0; k<N; k=k+1) begin
			if((adj[j][k]==1'b1)&&(k>=start && k<finish)) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp = db * nodeWeight[k] * nodeVal[k];
				nodeVal_next[j] = nodeVal_next[j] + temp[47:32]; 
				
			end
			else if (adj[j][k]==1'b1) begin
				l=l+1;
				t[l]=k;
				m=1;
			end
	  	end
				
	   end
		
		if(m >0 && m<=l)begin
		request_sent=1;
		offset_value_m = t[m]-finish;
		offset_value_s = start-t[m];
		$display("m",m);
		$display("t",t[m]);
		
		if (t[m]>finish-1) begin 
				request[0] =1; 
			      	request[4:3]=id;	
				
				if(offset_value_m<16) begin//if((k<=32) && id==1)
			      		request[2:1]=id+1;
					request[8:5]=offset_value_m;
				end
				if((offset_value_m<32)&&(offset_value_m>=16)) begin//if((k>=32)&&(k<=47) && id==1)
			      		request[2:1]=id+2;
					request[8:5]=offset_value_m-16;
				end
				if((offset_value_m<48)&&(offset_value_m>=32)) begin//if((k>=48)&&(k<=63) && id==1)
			      		request[2:1]=id+3;
					request[8:5]=offset_value_m-32;
				end
				$display("idp", id);
				$display("requestp",request[4:3]);
		end

		if (t[m]<start)begin 
				request[0]=1;
				request[4:3]=id;

				if(offset_value_s<=16) begin
					request[2:1]=id-1;
					request[8:5]=16-offset_value_s;
				end
				if((offset_value_s<=32)&&(offset_value_s>16)) begin
					request[2:1]=id-2;
					request[8:5]=32-offset_value_s;
				end
				if((offset_value_s<=48)&&(offset_value_s>32)) begin
					request[2:1]=id-3;
					request[8:5]=48-offset_value_s;
				end
				

		end

		if(received_packet[0] == 1)begin
			request_sent=0;
			temp = db * nodeWeight[t[m]] * received_packet[20:5];
			nodeVal_next[j] = nodeVal_next[j] + temp[47:32]; 
			m=m+1;
		end

	end
	if(l==0 || m>l) begin
		nodeVal[j] <= nodeVal_next[j]; //Next state = current state
			if (1'b1) offset_respond = j-start;
		my_data <= {nodeVal_next[j],offset_respond[3:0],1'b1};
		j<=j+1;noofcycles<=noofcycles+1;nodeVal_next[j] <= dn;
			if (j==finish-1) j<=start;
		m<=0;l<=0;
	end
end	
end
end
		


always@(posedge clk)
begin

if(reset) 
nodeValue <= 0;


if (noofcycles > 624) begin
a=0;
   for (b=start; b<finish; b=b+1) begin
			nodeVal_temp [b] <={nodeVal[b],b[5:0]};
			if(start==0) $display("nodevaltemp",nodeVal_temp [b]);
   end

	   for (g=start; g<finish; g=g+1) begin
			for (c=0; c<21; c=c+1) begin
			nodeValue [a] <= nodeVal_temp [g][c];
			a=a+1;
			end
	   end
end


end

always @ (*) begin
	node0Val = nodeVal[0+start];
	node1Val = nodeVal[1+start];
	node2Val = nodeVal[2+start];
	node3Val = nodeVal[3+start];
	node4Val = nodeVal[4+start];
	node5Val = nodeVal[5+start];
	node6Val = nodeVal[6+start];
	node7Val = nodeVal[7+start];
	node8Val = nodeVal[8+start];
	node9Val = nodeVal[9+start];
	node10Val = nodeVal[10+start];
	node11Val = nodeVal[11+start];
	node12Val = nodeVal[12+start];
	node13Val = nodeVal[13+start];
	node14Val = nodeVal[14+start];
	node15Val = nodeVal[15+start];
end
//assign concat[start:finish-1]={nodevalue[start]:nodevalue[finish-1]};
endmodule

