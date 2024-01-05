`include "define.v"
module idmux(
    input wire [`RegBus]    in1,
    input wire [`RegBus]    in2,
    input wire sel,
    
    output reg [`RegBus]  out //��� 
);
    //���selΪ1����out����in2������out����in1
    always@(*)begin
        out = sel?in2:in1;
    end
endmodule