`include "define.v"
module mux2(
    input wire [`RegBus]    in1,
    input wire [`RegBus]    in2,
    input wire sel,
    
    output wire [`RegBus]    out
);
    assign out = sel?in2:in1;
endmodule