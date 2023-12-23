`include "define.v"
module mux2(
    input wire [`RegBus]    in1,
    input wire [`RegBus]    in2,
    input wire sel,
    
    output wire [`RegBus]    out
);
    //如果sel为1，则out等于in2；否则out等于in1
    assign out = sel?in2:in1;
endmodule