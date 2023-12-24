 //WBU
 //Load & Store
module wbu(
    input wire rst,
    input wire clk,
    //来自EX
    input wire [9:0] ex_chvdb,
    input wire ex_wreg, //使能**
    input wire [`RegAddr] ex_addr, //5位指令地址,用于选择寄存器
    input wire [`RegBus] data_in,  //从执行EX部分，获得的32位输入数据
    
    //送到RegFile
    output reg [9:0] wb_chvdb,
    output reg wb_wreg, 
    output reg [`RegAddr] wb_addr, //5位指令地址,用于选择寄存器
    output reg [`RegBus] data_out, //32位输出数据
    //记分牌维护
    output reg [14:0] unuse_vdb//使用完毕
);

    always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_addr = `NOPRegAddr;
			wb_wreg = `WriteDisable;
		end 
		else begin
			wb_addr = ex_addr;
			wb_wreg = ex_wreg;
		end    
		unuse_vdb = {{wb_chvdb},{wb_addr}};
	end
	always @(*)begin //弥补EXU计算得出结果花费的一个周期
        if(rst == `RstEnable) data_out <= `ZeroWord;
		else data_out <= data_in;
    end
//	always @(rst)begin
//	   if(rst == `RstEnable) begin
//	       data_out <= `ZeroWord;
//			wb_addr = `NOPRegAddr;
//			wb_wreg = `WriteDisable;
//	   end
//	end

endmodule

