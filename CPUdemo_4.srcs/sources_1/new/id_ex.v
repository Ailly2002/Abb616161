`include "define.v"
module idex(
    input wire clk,
    input wire rst,
    input wire idexWrite,
    //从ID
        //到ALU/EX
    input wire[`AluOpBus]       aluop_i,//
    input wire[6:0]             funct7_i,
    input wire[`AluSelBus]      funct3_i,//funct//
    input wire[`RegBus]         reg1_i,//
    input wire[`RegBus]         reg2_i,//
    input wire[`RegAddr]        wd_i,//
    input wire                  wreg_i,//
    //HDU间接
    input wire [9:0]            source_regs_i,
    
    
    //输出到EX阶段(下一个阶段)
        //到ALU/EX
    output reg[`AluOpBus]       aluop_o,//
    output reg[6:0]             funct7,
    output reg[`AluSelBus]      funct3,//funct//
    output reg[`RegBus]         reg1_o,//
    output reg[`RegBus]         reg2_o,//
    output reg[`RegAddr]        wd_o,//
    output reg                  wreg_o,//
    output reg [9:0]            source_regs_o
);
    always @(posedge clk) begin
            if(rst)begin
            //到ALU/EX
                aluop_o = 7'b0000000;
                funct7 = 7'b0000000;
                funct3 = 3'b000;
                reg1_o = 5'b00000;
                reg2_o = 5'b00000;
                wd_o = 5'b00000;
                wreg_o = 1'b0;
                source_regs_o = 10'b00000_00000;
            end 
            else begin
                if(idexWrite == `unStall)begin
                //到ALU/EX
                    aluop_o <= aluop_i;
                    funct7  <= funct7_i;
                    funct3  <= funct3_i;
                    reg1_o  <= reg1_i;
                    reg2_o  <= reg2_i;
                    wd_o    <= wd_i;
                    wreg_o  <= wreg_i;
                    source_regs_o <= source_regs_i;
                end
            end
        end
endmodule