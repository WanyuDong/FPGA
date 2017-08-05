module uart_tx
(
				input 				rst,
				input 				uart_clk,
				input 				tx_pos,
				input 		[7:0]	tx_data,
				output reg 			tx_busy,
				output reg 			txd
);

//========================================================
parameter 	TRANS_IDLE 		= 4'd0, 
				TRANS_START 	= 4'd1, 
				TRANS_TX 		= 4'd2, 
				TRANS_VERIFY 	= 4'd3, 
				TRANS_STOP 		= 4'd4;
reg [3:0]	STATE;

reg [7:0]	tx_data_reg;
reg [7:0]	count;
reg			trans_pos_reg;
//================================s========================
always@(posedge uart_clk)
begin	
trans_pos_reg <= tx_pos;
end

always@(posedge uart_clk)
begin
if(!rst)
	begin
	STATE<=TRANS_IDLE;
	txd<=1'b1;
	end
else
	begin
		case(STATE)
		TRANS_IDLE:
			begin		
			txd<=1'b1;
			if(!trans_pos_reg && tx_pos)
				begin
				tx_data_reg<=tx_data;
				tx_busy<=1'b1;	
				STATE<=TRANS_START;
				end
			else
				begin
				tx_busy<=1'b0;
				end
			end
		TRANS_START:
			begin	
			count<=8'd0;
			STATE<=TRANS_TX;
			txd<=1'b0;
			end
		TRANS_TX:
			begin	
			if(count<8'd8)
				begin
				txd<=tx_data_reg[0];
				tx_data_reg<={1'b0,tx_data_reg[7:1]};
				count<=count+1'b1;
				STATE<=TRANS_TX;
				end
			else
				begin
				txd<=1'b1;
				tx_data_reg<=8'd0;
				count<=8'd0;
				STATE<=TRANS_STOP;
				end
			end
		TRANS_VERIFY:
			begin	
			STATE<=TRANS_STOP;
			txd<=1'b1;
			end
		TRANS_STOP:
			begin	
			STATE<=TRANS_IDLE;
			txd<=1'b1;
			end
		default: STATE<=TRANS_IDLE;
		endcase
	end
end

endmodule
