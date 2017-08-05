// 处理scan 命令

module key(
					input clk,rst,
					input key1,key2,
					output reg [7:0]trig,
				);
//=======================================================================
reg [1:0] key_rst;
always @(posedge clk or negedge rst)
begin
 if(!rst)
  key_rst <= 2'b11;
 else
  key_rst <= {key2,key1}; // 读取当前时刻的按键值
end
 
reg [2:0] key_rst_r;
 
always @(posedge clk or negedge rst)
begin
 if(!rst)
  key_rst_r <= 2'b11;
 else
  key_rst_r <= key_rst;  // 将上一时刻的按键值进行存储
end
 
wire [1:0]key_an = key_rst_r & (~key_rst); // 当键值从0到1时key_an改变
//wire [2:0]key_an = key_rst_r ^ key_rst;  // 注：也可以这样写
 
reg [19:0] cnt;  // 延时用计数器
 
always @(posedge clk or negedge rst)
begin
 if(!rst)
  cnt <= 20'd0;
 else if(key_an)
   cnt <= 20'd0;
  else
   cnt <= cnt + 20'd1;
end
 
reg [1:0] key_value;
 
always @(posedge clk or negedge rst)
begin
 if(!rst)
  key_value <= 2'b11;
 else if(cnt == 20'hfffff) // 2^20*1/(50MHZ)=20ms
   key_value <= {key2,key1}; // 去抖20ms后读取当前时刻的按键值
end
 
reg [1:0] key_value_r;
 
always @(posedge clk or negedge rst)
begin
 if(!rst)
  key_value_r <= 2'b11;
 else
  key_value_r <= key_value; // 将去抖前一时刻的按键值进行存储
end
 
wire [1:0] key_ctrl = key_value_r & (~key_value); // 当键值从0到1时key_ctrl改变
 

always @(posedge  clk or negedge rst)
begin
 if(!rst)
 begin  // 一个if内有多条语句时不要忘了begin end
	trig <= 8'd128;
 end
 else
 begin
  if(key_ctrl[0]) 
   begin 
		if(trig <255) trig <= trig + 8'd1;	
		else trig <= trig;
   end
  if(key_ctrl[1])
   begin
		if(trig >0) trig <= trig - 8'd1;
		else trig <= trig;
	end
 end
end

endmodule

