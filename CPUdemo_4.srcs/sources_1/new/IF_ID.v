`include "define.v"
module ifid(
    input wire clk,
    input wire rst,
    input wire ifflush,
    input wire [`InstBus] Ins,  //32Œª÷∏¡Ó
    input wire [`ADDR_BUS] pcaddr,
    input wire ifidWrite,
    input wire branch_j,
    
    output reg[`InstBus]         inst,
    output reg[`ADDR_BUS]      pcadd
);
    always @(posedge clk) begin
        if(rst || ifflush || branch_j)begin
            inst = 32'h000000;
            pcadd = 32'h000000;
        end
        else begin
            if(ifidWrite == `unStall)begin
                inst <= Ins;
                pcadd <= pcaddr;
            end
        end
    end

endmodule