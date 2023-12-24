`include "define.v"
module idex(
    input wire clk,
    input wire [`InstBus] Ins,  //32Œª÷∏¡Ó
    input wire [`ADDR_BUS] pcaddr,
    input wire ifidWrite,
    
    output reg[`InstBus]         inst,
    output reg[`ADDR_BUS]      pcadd
);
    always @(posedge clk) begin
        
        end
endmodule