//uart_rxd

module uart_rx
				(
   				input RSTn,
   			    input BPS_CLK,
   				input RX_Pin_In,
   				output RX_Done_Sig,
   				output[7:0] RX_Data	
				);

 wire RX_En_Sig;
 assign RX_En_Sig = 1'd1;
 assign RX_Data = rData;
 assign RX_Done_Sig = isDone;	 	 		 
/********************************************************/

	 reg [3:0]i;
	 reg [7:0]rData;
	 reg isDone;
	
	 always @ ( posedge BPS_CLK or negedge RSTn )
	     if( !RSTn )
		      begin 
		          i <= 4'd0;
					 rData <= 8'd0;
					 isDone <= 1'b0;	 
				end
		  else if( RX_En_Sig )//RX_En_Sig 置高时，模块开始定时采集
		      case ( i )
//				
			       4'd0 :  //检查到RX_Pin_In由高变低的电平变化，使步骤i进入第 0 位采集
					 if( !RX_Pin_In ) begin i <= i + 1'b1; end
			 
					 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8 ://对八位数据位进行采集，每一位数据位会依低位到最高位储存入 rData 寄存器
					 begin i <= i + 1'b1; rData[ i - 1 ] <= RX_Pin_In; end
			 
					 4'd9 ://对定时采集的停止位
					 if( RX_Pin_In ) begin i <= i + 1'b1; isDone <= 1'b1; end
					 else i <= 4'd0;
					 4'd10 : //一帧数据的采集工作已经结束
					 begin i <= 4'd0; isDone <= 1'b0; end				 
				endcase
				
 /********************************************************/

	 
	 

endmodule
