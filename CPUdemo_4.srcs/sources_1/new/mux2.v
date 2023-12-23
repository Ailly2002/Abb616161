`include "define.v"
module mux2(
    input wire [`ADDR_BUS]      in1,
    input wire [`RegBus]        in2,
    input wire sel,
    
    output reg [`RegBus] out
);
    always @(*)begin
        if(sel == 1'b1)begin
            out = in1;
        end 
        else begin
            out = in2;
        end 
    end
endmodule