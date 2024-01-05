`include "define.v"
module idmux(
    input wire [`RegBus]    in1,
    input wire [`RegBus]    in2,
    input wire sel,
    
    output reg [`RegBus]  out //输出 
);
    //如果sel为1，则out等于in2；否则out等于in1
    always@(*)begin
        out = sel?in2:in1;
    end
endmodule