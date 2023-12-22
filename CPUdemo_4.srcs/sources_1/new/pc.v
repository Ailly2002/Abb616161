//PC
`include "define.v"
module pc(
    input wire clk, rst, stop, //时钟、重置、停机
    input wire ct, uct, //条件转移、无条件转移
//    input wire [4:0] offset,  //12位转移指令偏移量 5bit
    output reg [`ADDR_BUS] pc  //12位指令地址码  32bit
);
    reg halt;//多周期暂停标志位
    initial halt = 1'b0;//初始时标志位为非暂停状态
    
    always@(posedge clk) begin
      if(rst == 1)begin
        pc = 32'h00000000;
        halt <= 1'b0;
        end
      else if(stop == 1)begin//ID段检测到可能存在相关（记分牌），要求流水线暂停
            if(halt == 1'b0)begin//halt位为1，进入暂停的第一个周期
                pc = pc-1;
                halt <= 1'b1;
                end
            else if(halt)begin 
            pc = pc;end
            end      
      else begin
            pc = pc+1;
            halt <= 1'b0;
        end
    end

//    always@(negedge clk) begin
//      if(uct == 1)  //无条件转移
//        pc = offset-4;
//      if(ct == 1)  //条件转移
//        pc = pc+offset-4;
//    end

endmodule

