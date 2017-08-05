//Universal frequency division module
// you can change the parameter DIV_FACTOR to get the fre you want.

module div_fre(
				input clk,rst,
				output reg clk_out
				);


// system clk is 40M
parameter   DIV_FACTOR = 19; // 40M/(39+1)=1M

reg [31:0] cnt ;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		clk_out <= 0;
	end
	else if (cnt == DIV_FACTOR) begin
		cnt <= 0;
		clk_out <= ~clk_out;
	end
	else cnt <= cnt + 1;
end

endmodule
