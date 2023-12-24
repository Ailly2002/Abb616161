`include "define.v"
module idex(
    input wire clk,
    input wire rst,
    input wire idexWrite,
    //从ID
        //到Add
    input wire [`ADDR_BUS]      pcadd_i,
    input wire [`RegBus]        shift_i,//立即数偏移量，EX_ADD的另一个操作数
        //到Add_MUX
    input wire[`RegBus]         rs1_i,
    input wire                  j_type_i,//跳转指令的类型：JAL/JALR
        //到ALU/EX
    input wire[`AluOpBus]       aluop_i,//
    input wire[6:0]             funct7_i,
    input wire[`AluSelBus]      funct3_i,//funct//
    input wire[`RegBus]         reg1_i,//
    input wire[`RegBus]         reg2_i,//
    input wire[`RegAddr]        wd_i,//
    input wire                  wreg_i,//
    
    //输出到EX阶段(下一个阶段)
        //到Add
    output reg [`ADDR_BUS]      pcadd_o,
    output reg [`RegBus]        shift,//立即数偏移量，EX_ADD的另一个操作数
        //到Add_MUX
    output reg[`RegBus]         rs1_o,
    output reg                  j_type,//跳转指令的类型：JAL/JALR
        //到ALU/EX
    output reg[`AluOpBus]       aluop_o,//
    output reg[6:0]             funct7,
    output reg[`AluSelBus]      funct3,//funct//
    output reg[`RegBus]         reg1_o,//
    output reg[`RegBus]         reg2_o,//
    output reg[`RegAddr]        wd_o,//
    output reg                  wreg_o//
);
    always @(posedge clk) begin
            if(rst)begin
                pcadd_o = 32'h000000;
                shift = 32'h000000;//立即数偏移量，EX_ADD的另一个操作数
            //到Add_MUX
                rs1_o = 32'h000000;
                j_type = 1'b0;//跳转指令的类型：JAL/JALR
            //到ALU/EX
                aluop_o = 7'b0000000;
                funct7 = 7'b0000000;
                funct3 = 3'b000;
                reg1_o = 5'b00000;
                reg2_o = 5'b00000;
                wd_o = 5'b00000;
                wreg_o = 1'b0;
            end 
            else begin
                if(idexWrite == `unStall)begin
                    pcadd_o <= pcadd_i;
                    shift   <= shift_i;//立即数偏移量，EX_ADD的另一个操作数
                //到Add_MUX
                    rs1_o   <= rs1_i;
                    j_type  <= j_type_i;//跳转指令的类型：JAL/JALR
                //到ALU/EX
                    aluop_o <= aluop_i;
                    funct7  <= funct7_i;
                    funct3  <= funct3_i;
                    reg1_o  <= reg1_i;
                    reg2_o  <= reg2_i;
                    wd_o    <= wd_i;
                    wreg_o  <= wreg_i;
                end
            end
        end
endmodule