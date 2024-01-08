//CU
`include "define.v"
module cu(
    input wire          clk,
    input wire          rst,
    input wire  [`InstBus]      inst,
    input wire  [`ADDR_BUS]     pcadd,//当前PC地址
    
    
    //读取得Regfile的值
    input wire[`RegBus]         reg1_data,
    input wire[`RegBus]         reg2_data,
    //输出到Regfile的信息
    output reg                  reg1_read,
    output reg                  reg2_read,
    output reg[`RegAddr]        reg1_addr,
    output reg[`RegAddr]        reg2_addr,
    //到HDU
    output reg                  instvalid_o,
    output reg[14:0]            use_vdb,//要使用的寄存器地址，用于记分牌功能
    
    //到banch
    output reg     banch,
    //到IF/ID寄存器组
        //分支指令暂停
    output reg                 branch_stall,//名为branch,实际上是条件/无条件转移均使用的IF冲刷信号
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
    
    reg[`OPcode] operate;//7位指令操作码,操作码类型
    //保存指令执行需要的立即数
    //32宽度，按照需要裁剪
    reg[`RegBus]   imm12;//I立即数
    reg[`RegBus]   imm20;//U立即数

    
    initial begin
        instvalid_o   <=  `InstInvalid;//指示指令是否有效
        banch <= 1'b1;//默认跳转
    end
    
    always @(*) begin
        if(rst == `RstEnable)begin
                        //复位
                        operate <= 7'b0000000;
                        aluop_o <= 7'b0000000;
                        wreg_o  <=  `WriteDisable;
                        reg1_read <= `ReadDisable;
                        reg2_read <= `ReadDisable;
                        funct7=7'b0000000;
                        reg1_addr=`NOPRegAddr;
                        reg2_addr=`NOPRegAddr;
                        wd_o   =  `NOPRegAddr;
//                        source_regs = 10'b00000_00000;
                        instvalid_o   =  `InstValid;
                        
                        
        end
        else begin
            imm12   <= { {21{inst[31]}}, inst[31:20] };//12位I立即数,符号扩展
            imm20   <= { inst[31:12] , {12'b0000_0000_0000} };//20位U立即数,低位扩展
            funct3  <= inst[14:12];//3位funct
            operate <= inst[6:0];
            case(inst[6:0])
                `OP:    begin//所有操作都是读取rs1和rs2寄存器作为源操作数，并把结果写入到寄存器rd中
                        //指令执行要读写的目的寄存器
                        reg1_addr=inst[19:15];
                        reg2_addr=inst[24:20];
                        wd_o   =  inst[11:7];
                        //在所有格式中，RISC-V ISA将源寄存器（rs1和rs2）和目标寄存器（rd）固定在同样的位置，以简化指令译码
                        aluop_o <= operate;
                        shift <= 32'b0;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadEnable;
                        reg2_read <= `ReadEnable;
                        funct7=inst[31:25];
                        instvalid_o   =  `InstValid;//指令有效
                        banch <= 1'b0; 
                        branch_stall <= 1'b0;
                    end
                 `OP_IMM:begin
                        reg1_addr=inst[19:15];
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                        aluop_o <= operate;
                        shift <= 32'b0;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadEnable;
                        reg2_read <= `ReadDisable;
                        funct7=inst[31:25];//立即数高7位，供alu用
                        instvalid_o   =  `InstValid;
                        banch <= 1'b0; 
                        branch_stall <= 1'b0;
                    end
                 `LUI:begin
                        reg1_addr=inst[11:7];
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                        aluop_o <= operate;
                        shift <= 32'b0;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadEnable;
                        reg2_read <= `ReadDisable;
                        instvalid_o   =  `InstValid;
                        banch <= 1'b0; 
                        branch_stall <= 1'b0;
                    end
                    `AUIPC:begin
                        reg1_addr=5'b00000;
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                        aluop_o <= operate;
                        shift <= 32'b0;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadDisable;//通过rs1读取PC当前的地址
                        reg2_read <= `ReadDisable;
                        instvalid_o   =  `InstValid;
                        banch <= 1'b0; 
                        branch_stall <= 1'b0;
                    end
                    `JAL:begin//处理上可以类似U类指令，对其中的imm20进行分割截取
                        reg1_addr=5'b00000;
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                            j_type <= 1'b0;//目标地址计算的基址来源：PC
                            aluop_o <= operate;
                            shift <= {{13{inst[31]}},{inst[19:12]},{inst[20]},{inst[30:21]}};//对偏移量符号拓展
                            wreg_o  <=  `WriteEnable;//跳转指令将PC+1写回寄存器
                            reg1_read <= `ReadDisable;//通过rs1读取PC当前的地址
                            reg2_read <= `ReadDisable;
                            funct7=7'b0000000;
                            instvalid_o   =  `InstValid;
                            banch <= 1'b1; //是否是控制转移指令
                            branch_stall <= 1'b1;
                            
                    end
                    `JALR:begin
                        reg1_addr=inst[19:15];
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                            j_type <= 1'b1;//目标地址计算的基址来源：基址寄存器
                            aluop_o <= operate;
                            shift <= imm12;//inst[31:20]
                            wreg_o  <=  `WriteEnable;//跳转指令将PC+1写回寄存器
                            rs1_o <= reg1_addr;//通过rs1间接跳转
                            reg1_read <= `ReadDisable;
                            reg2_read <= `ReadDisable;
                            instvalid_o   =  `InstValid;
                            banch <= 1'b1;
                            branch_stall <= 1'b1;
                    end
                    `BRANCH:begin
                            reg1_addr=inst[19:15];
                            reg2_addr=inst[24:20];
                            wd_o   =  5'b00000;
                            j_type <= 1'b0;
                            aluop_o <= operate;
                            shift = {{21{inst[31]}},{inst[7]},{inst[30:25]},{inst[11:8]}};
                            wreg_o  <=  `WriteDisable;//分支指令不写回寄存器
                            reg1_read <= `ReadEnable;
                            reg2_read <= `ReadEnable;
                            instvalid_o   =  `InstValid;
                            banch <= 1'b1;
                            branch_stall <= 1'b1;
                    end
                default:begin
                    branch_stall <= 1'b0;
                    instvalid_o   <=  `InstInvalid;
                end
            endcase
        end
    end
    //******
    //确定运算源操作数1
    always @ (*) begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if(reg1_read == `ReadEnable) begin
            reg1_o <= reg1_data;  //Regfile读端口1的输出值
        end else if(reg1_read == `ReadDisable) begin
            if(operate == `AUIPC)begin
                reg1_o <= pcadd;end
            else if(operate == `JAL)begin
                reg1_o <= pcadd;end
            else if(operate == `JALR)begin
                reg1_o <= pcadd;end
            else begin
                reg1_o <= `ZeroWord;end          //立即数
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
    
    //确定运算源操作数2
    always @ (*) begin
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if(reg2_read == `ReadEnable) begin
            reg2_o <= reg2_data;  //Regfile读端口1的输出值
        end else if(reg2_read == `ReadDisable) begin
            if(operate == `OP_IMM)begin
                reg2_o <= imm12;end          //立即数
            else if(operate == `LUI)begin
                reg2_o <= imm20;end
            else if(operate == `AUIPC)begin
                reg2_o <= imm20;end
            else if(operate == `JAL)begin
                reg2_o <= 32'b000000_000000_000000_000000_000000_01;end
            else if(operate == `JALR)begin
                reg2_o <= 32'b000000_000000_000000_000000_000000_01;end
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
    //维护记分牌
    always @(*)begin
        pcadd_o  <= pcadd;
        if(~instvalid_o)begin
            use_vdb <= {{reg2_addr},{reg1_addr},{wd_o}};
        end
    end
    //ifflush唤醒
    always@(posedge clk)begin
        branch_stall <= 1'b0;
    end

endmodule