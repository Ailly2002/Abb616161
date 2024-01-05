//alu2
`include "define.v"
module alu(
    input wire clk,
    input wire rst,
    input wire [9:0] source_regs, //源寄存器地址，用于记分牌功能
    input wire [`AluOpBus] aluop_i,//opcode,使用那一组操作
    input wire [6:0] funct7,//指令的高7位，在I类位移指令和R类指令、乘除法指令和STORE指令当中起到辅助作用
    input wire[`AluSelBus] funct,  //操作选择信号alu_op/funct//
    input wire[`AluSelBus]          alusel_i,
    input wire[`RegAddr]           wd_i,
    input wire                     wreg_i,
    input wire [`RegBus] in1, 
    input wire [`RegBus] in2,   //操作数in1和in2
    
    output reg ct, //条件转移ct，用于BANCH类指令 跳转(1)/不跳转(0)
    output reg [9:0] ex_chvdb, //源寄存器地址，用于记分牌功能
    output reg[`RegAddr]         wd_o,
    output reg                   wreg_o,
    output reg [`RegBus] z   //wdata_o
);
    //保存逻辑运算的结果 
    reg[`RegBus] logicout;
    
    initial begin
      ct = 1;
      z = 0;  //初始化结果z为0
    end
    
    always@(posedge clk) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end 
        else if(aluop_i==`OP) begin//************ opcode == OP begin************
                if(funct7==7'b0000000)begin
                    case(funct)
                        3'b000: z = in1+in2;//ADD
                        3'b001: z = in1<in2?in1:`ZeroWord;//SLT
                        3'b010: begin
                            if($signed(in1)<$signed(in2))z = in1;
                            else z = `ZeroWord;
                        end                 //SLTU
                        3'b011: z = in1&in2;//AND
                        3'b100: z = in1|in2;//OR
                        3'b101: z = in1^in2;//XOR
                        3'b110: z = in1<<in2[4:0];//SLL逻辑左移
                        3'b111: z = in1>>in2[4:0];//SRL
                    endcase
                end
                else begin
                     case(funct)
                        3'b000: z = in1-in2;//SUB
                        3'b001: z = in1>>>in2[4:0];//SRA算术右移
                     endcase
                    end
                end//************ opcode == OP end************
         else if(aluop_i==`OP_IMM)begin//************ opcode==OP_IMM begin************
                case(funct)
                    3'b000: z = in1+in2;//ADDI
                    3'b001: begin
                            if($signed(in1)<$signed(in2))       z = in1;
                            else z = `ZeroWord;
                        end             //SLTI
                    3'b010: begin
                            if($unsigned(in1)<$unsigned(in2))   z = in1;
                            else z = `ZeroWord;
                        end             //SLTIU
                    3'b011: z = in1&in2;//ANDI
                    3'b100: z = in1|in2;//ORI
                    3'b101:begin
                            if(in2 == -1) z = ~in1;
                            else z = in1^in2;
                    end                 //XORI
                    //以下三条指令偏移为imm低5位
                    3'b110: z = in1<<in2[4:0];//SLLI
                    3'b111:begin
                        if(funct7==7'b0000000)z = in1>>in2[4:0];//SRLI
                        else z = in1>>>in2;//SRAI
                    end
                endcase
            end//************ opcode==OP_IMM end************
         else if(aluop_i==`LUI)begin
                z = {{20'b0000_0000_0000_0000_0000},in1[11:0]}+{{in2[31:12]},{12'b0000_0000_0000}};//in1是目的寄存器的原内容
                ct = 1'b1;
            end//************ opcode==LUI end************
         else if(aluop_i==`AUIPC)begin
                z = in1 + in2;//rd = pc+extend'IMM_U
            end
         else if(aluop_i==`JAL)begin
                z = in1 + 32'b000000_000000_000000_000001;//rd = pc+1
                ct = 1'b1;
            end
         else if(aluop_i==`JALR)begin
                z = in1 + 32'b000000_000000_000000_000001;//rd = pc+1
                ct = 1'b1;
            end
         else if(aluop_i==`BRANCH)begin
                case(funct)
                    3'b000:begin
                        z=0;ct = (in1==in2);
                        end
                    3'b001:begin
                        z=0;ct = (in1!=in2);
                        end
                    3'b010:begin
                        z=0;ct = ($signed(in1)<$signed(in2));//BLT
                        end
                    3'b011:begin;
                        z=0;ct = (in1<in2);//BLTU
                        end
                    3'b100:begin
                        z=0;ct = ($signed(in1)>$signed(in2));//BGE
                        end
                    3'b101:begin;
                        z=0;ct = (in1>in2);//BGEU
                        end
                endcase
                //z = in1 ;//rd =
                
            end
         else begin
                ct = 1'b1;
         end
      end
    always @ (posedge clk) begin
         wd_o = wd_i;       //要写的目的寄存器地址
         wreg_o = wreg_i;
         ex_chvdb = source_regs;
    end
endmodule

