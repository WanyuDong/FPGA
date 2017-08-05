// generate the m sequence
module randGen
(
    input   reset_n,
    input   clk,  
    output  randOut
);

//======================================================================//
reg [7:0] rand_num; 
always@(posedge clk or negedge reset_n)
begin
    if(!reset_n)
        rand_num <= 8'd1;
    else
        begin
            rand_num[0] <= rand_num[7];
            rand_num[1] <= rand_num[0];
            rand_num[2] <= rand_num[1];
            rand_num[3] <= rand_num[2];
            rand_num[4] <= rand_num[3]^rand_num[7];
            rand_num[5] <= rand_num[4]^rand_num[7];
            rand_num[6] <= rand_num[5]^rand_num[7];
            rand_num[7] <= rand_num[6];
        end         
end
//======================================================================//
assign randOut = rand_num[7];
endmodule