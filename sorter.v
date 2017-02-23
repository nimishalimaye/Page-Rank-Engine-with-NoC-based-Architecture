module sorter #(parameter N=64, WIDTH=16) (input clk, input reset, input [N*(WIDTH+6)-1:0] scores_in, output reg [10*WIDTH-1:0] top10Vals, output reg [10*6-1:0]top10IDs,output reg done);

reg [WIDTH-1:0]temp,temp1;
reg [WIDTH+5:0]arrayin [N-1:0] ;
reg [WIDTH-1:0]array_in [N-1:0];
reg [WIDTH-1:0] top10Val[9:0];
reg [5:0] top10ID[9:0];
reg [10*(WIDTH+6)-1:0] scores_out;
//reg [9:0] array_out [WIDTH-1+6:0];
integer l,m,n,i,x,y,z,s,t,p,q,a,b,c,p1,q1,a1,b1,c1;
always@(*) begin
l=0;
for (m=0; m<N; m=m+1) begin
for (n=0; n<WIDTH+6; n=n+1)
begin
arrayin[m][n]=scores_in[l];
l=l+1;
end
end
end

always@(*)begin
for(s=0;s<N;s=s+1)begin
   for(t=0;t<16;t=t+1) begin
     array_in[s][t]= arrayin[s][t+6];
	//topId[s][t]=arrayin[s][]
     end
   end
end

always@(posedge clk, posedge reset)
begin
if (reset) begin
top10Vals<=0;
top10IDs<=0;
//scores_out<=0;
//i<=10;
end
else begin
//if (i>=10)
//i<=0;
for (i=0; i<10; i=i+1) begin
   for( s=0;s<N; s=s+1) begin
                         if (array_in[s]>array_in[s+1])
                         begin
                           temp=arrayin[s];
                           arrayin[s]=arrayin[s+1];
                           arrayin[s+1]=temp;
			   temp1=array_in[s];
			   array_in[s]=array_in[s+1];
			   array_in[s+1]=temp1;
                         end
                         end
                      end
//array_out[0:9]<=array_in;
     end
end

always@(*)
begin
x=0;
for (y=63; y>=54; y=y-1) 
	begin
		for (z=0; z<=WIDTH+5; z=z+1)
		begin
			scores_out[x]=arrayin[y][z];
			x=x+1;
		end
	end
	 
end 
//always@(*)begin
//q=0;
//q1=0;
//for(p=63;p>54;p=p-1)begin
//top10Val[q]=arrayin[p][21:6];
//q=q+1;
//
//$display ("top10val",top10ID[q1]);
//end
//
//for(p1=63;p1>54;p1=p1-1)begin
//top10ID[q1]=arrayin[p1][5:0];
//$display ("$display (top10ID[q1])",top10ID[q1]);
//end
//end

always @ (posedge clk) begin
top10Val[0]<=scores_out[21:6];
top10Val[1]<=scores_out[43:28];
top10Val[2]<=scores_out[65:50];
top10Val[3]<=scores_out[87:72];
top10Val[4]<=scores_out[109:94];
top10Val[5]<=scores_out[131:116];
top10Val[6]<=scores_out[153:138];
top10Val[7]<=scores_out[175:160];
top10Val[8]<=scores_out[197:182];
top10Val[9]<=scores_out[219:204];
top10ID[0]<=scores_out[5:0];
top10ID[1]<=scores_out[27:22];
top10ID[2]<=scores_out[49:44];
top10ID[3]<=scores_out[71:66];
top10ID[4]<=scores_out[93:88];
top10ID[5]<=scores_out[115:110];
top10ID[6]<=scores_out[137:132];
top10ID[7]<=scores_out[159:154];
top10ID[8]<=scores_out[181:176];
top10ID[9]<=scores_out[203:198];

top10Vals<={top10Val[0], top10Val[1], top10Val[2], top10Val[3], top10Val[4], top10Val[5], top10Val[6], top10Val[7], top10Val[8], top10Val[9]};
top10IDs<={top10ID[0], top10ID[1], top10ID[2], top10ID[3], top10ID[4], top10ID[5], top10ID[6], top10ID[7], top10ID[8], top10ID[9]};
done<=1;
end



endmodule
