//digitron

module digitron(
	input clk,rst,
	input[3:0] num0,
	input[3:0] num1,
	input[3:0] num2,
	input[3:0] num3,
	input[3:0] num4,
	input[3:0] num5,
	input[5:0] dp_in, //小数点选择
	output[5:0] del, //位选
	output[6:0] seg, //值
	output dp //小数点
	);
//==========================================
assign dp=~dp_r;	    //显示小数点
assign del=~del_r[5:0];//显示位选
assign seg=~seg_r; //显示求反后的结果
//==========================================
reg[3:0] num;
reg[2:0] numState;
reg[5:0] del_r;
reg dp_r;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		num <= 4'd0;
		numState <= 3'd0;
	end
	else
	case(numState)
		3'd0:
		begin
			num <= num0;
			del_r <= 6'b100000;  //0
			dp_r <= dp_in[0];
			numState <= numState + 3'd1;
		end
		3'd1:
		begin
			num <= num1;
			del_r <= 6'b000001;  //1
			dp_r <= dp_in[5];
			numState <= numState + 3'd1;	
		end
		3'd2:
		begin
			num <= num2;
			del_r <= 6'b000010;  //2
			dp_r <= dp_in[4];
			numState <= numState + 3'd1;	
		end
		3'd3:
		begin
			num <= num3;
			del_r <= 6'b000100;   //3
			dp_r <= dp_in[3];
			numState <= numState + 3'd1;	
		end
		3'd4:
		begin
			num <= num4;
			del_r <= 6'b001000;  //4
			dp_r <= dp_in[2];
			numState <= numState + 3'd1;
		end
		3'd5:
		begin
			num <= num5;
			del_r <= 6'b010000;  //5
			dp_r <= dp_in[1];
			numState <= 3'd0;	
		end
	endcase
end
//==========================================
reg[6:0] seg_r;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		seg_r <= 7'b0111111;
	end
	else
	begin
		case(num)
			4'h0:seg_r=7'b0111111;
			4'h1:seg_r=7'b0000110;
			4'h2:seg_r=7'b1011011;
			4'h3:seg_r=7'b1001111;
			4'h4:seg_r=7'b1100110;
			4'h5:seg_r=7'b1101101;
			4'h6:seg_r=7'b1111101;
			4'h7:seg_r=7'b0000111;
			4'h8:seg_r=7'b1111111;
			4'h9:seg_r=7'b1101111;
			4'ha:seg_r=7'b1110111;
			4'hb:seg_r=7'b1111100;
			4'hc:seg_r=7'b0111001;
			4'hd:seg_r=7'b1011110;
			4'he:seg_r=7'b1111001;
			4'hf:seg_r=7'b1110001;
			default:seg_r=7'bx;
			endcase
	end	

end

endmodule

