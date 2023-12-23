//CU
`include "define.v"
module cu(
    input wire          clk,
    input wire          rst,
    input wire[`RegBus]         inst,
    input wire [`ADDR_BUS]      pcadd,//��ǰPC��ַ
    input wire [`RegBus]        valid_bit,//��ȡ�Ƿ��Ƶ�ǰ��Чλ
    
    //��ȡ��Regfile��ֵ
    input wire[`RegBus]         reg1_data,
    input wire[`RegBus]         reg2_data,
    //�����Regfile����Ϣ
    output reg                  reg1_read,
    output reg                  reg2_read,
    output reg[`RegAddr]        reg1_addr,
    output reg[`RegAddr]        reg2_addr,
    output reg[4:0]             id_chvdb,//Ŀ�ļĴ�����ַ�����ڼǷ��ƹ���
    
    
    //�����EX�׶�
        //��Add
    output wire [`ADDR_BUS]      pcadd_o,
        //��ALU
    output reg                  stop, //ͣ���ź�
    output reg [9:0]            source_regs, //Դ�Ĵ�����ַ�����ڼǷ��ƹ���
    output reg[`AluOpBus]       aluop_o,//
    output reg[6:0]             funct7,
    output reg[`AluSelBus]      funct3,//funct//
    output reg[`RegBus]         reg1_o,//
    output reg[`RegBus]         reg2_o,//
    output reg[`RegAddr]        wd_o,//
    output reg                  wreg_o//
);

    
    wire[`OPcode] operate = inst[6:0];//7λָ�������,����������
    
    //����ָ��ִ����Ҫ��������
    //32��ȣ�������Ҫ�ü�
    reg[`RegBus]   imm12;//I������
    reg[`RegBus]   imm20;//U������
    
    
    
    //ָʾָ���Ƿ���Ч
    reg instvalid;
    //����λ
    reg imm_signed;//��RISC-V �У������������ķ���λ������ָ��� 31 λ
    
    
    initial begin
        stop = 0;
    end
    
    always @(posedge clk) begin
        if(rst == `RstEnable)begin
                        //��λ
                        aluop_o <= 7'b0000000;
                        wreg_o  <=  `WriteDisable;
                        reg1_read <= `ReadDisable;
                        reg2_read <= `ReadDisable;
                        funct7=7'b0000000;
                        reg1_addr=`NOPRegAddr;
                        reg2_addr=`NOPRegAddr;
                        wd_o   =  `NOPRegAddr;
                        source_regs = 10'b00000_00000;
                        
        end
        else begin
            imm12 <= { {20{inst[31]}}, inst[31:20] };//12λI������,������չ
            imm20 <= { inst[31:12] , {12'b0000_0000_0000} };//20λU������,��λ��չ
            funct3 = inst[14:12];//3λfunct
            case(operate)
                `OP:    begin//���в������Ƕ�ȡrs1��rs2�Ĵ�����ΪԴ�����������ѽ��д�뵽�Ĵ���rd��
                        //ָ��ִ��Ҫ��д��Ŀ�ļĴ���
                        reg1_addr=inst[19:15];
                        reg2_addr=inst[24:20];
                        wd_o   =  inst[11:7];
                            //�����и�ʽ�У�RISC-V ISA��Դ�Ĵ�����rs1��rs2����Ŀ��Ĵ�����rd���̶���ͬ����λ�ã��Լ�ָ������
                            if(valid_bit[reg1_addr] && valid_bit[reg2_addr] && valid_bit[wd_o]) begin//���Ƿ���
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadEnable;
                                funct7=inst[31:25];
                                source_regs = {reg2_addr,reg1_addr};
                                instvalid   =  `InstValid;//ָ����Ч
                            end
                            else begin
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadDisable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                reg2_addr=`NOPRegAddr;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end//����Ƿ�����Ч����ȫ����䣬ԭָ��״̬ͨ������PC��IR���¶�ȡ
                    end
                 `OP_IMM:begin
                        reg1_addr=inst[19:15];
                        wd_o   =  inst[11:7];
                            if(valid_bit[reg1_addr] && valid_bit[wd_o]) begin//���Ƿ���
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=inst[31:25];//��������7λ����alu��
                                source_regs = {5'b00000,reg1_addr};
                                instvalid   =  `InstValid;
                            end 
                            else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end
                    end
                 `LUI:begin
                        reg1_addr=inst[11:7];
                        wd_o   =  inst[11:7];
                        if(valid_bit[reg1_addr] && valid_bit[wd_o]) begin//���Ƿ���
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                        end
                        else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                        end
                    end
                    `AUIPC:begin
                            wd_o   =  inst[11:7];
                            if(valid_bit[wd_o]) begin//���Ƿ���
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                            end
                            else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end
                    end
                    `JAL:begin//�����Ͽ�������U��ָ������е�imm20���зָ��ȡ
                            wd_o   =  inst[11:7];
                            if(valid_bit[wd_o]) begin//���Ƿ���,Ҫ�ݴ�pc�ļĴ���δ��ռ��
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                            end
                            else begin
                                
                            end
                    end
                    `JALR:begin
                    end
                    `BRANCH:begin
                    end
                default:begin
                end
            endcase
        end
    end
    //******
    //ȷ������Դ������1
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if(reg1_read == `ReadEnable) begin
            reg1_o <= reg1_data;  //Regfile���˿�1�����ֵ
        end else if(reg1_read == `ReadDisable) begin
            if(operate == `AUIPC)begin
                reg1_o <= pcadd;end
            else begin
                reg1_o <= `ZeroWord;end          //������
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
    
    //ȷ������Դ������2
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if(reg2_read == `ReadEnable) begin
            reg2_o <= reg2_data;  //Regfile���˿�1�����ֵ
        end else if(reg2_read == `ReadDisable) begin
            if(operate == `OP_IMM)begin
                reg2_o <= imm12;end          //������
            else if(operate == `LUI)begin
                reg2_o <= imm20;end
            else if(operate == `AUIPC)begin
                reg2_o <= imm20;end
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
    //ά���Ƿ���
    always @(*)begin
        id_chvdb <=  wd_o;
    end
    //******
//    always @(*) begin
//      case(funct)
//        3'b000: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100000;   //1,����ۼ���CLA
//        3'b001: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100001;   //2,�ۼ���ȡ��COM    
//        3'b010: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100010;   //3,��������һλSHR
//        3'b011: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100011;   //4,ѭ������һλCSL
//        3'b100: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100100;   //5,�ӷ�ָ��ADD
//        3'b101: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00010101;   //6,����STA
//        3'b110: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100110;   //7,ȡ��ָLDA
//        3'b111: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b01000111;   //8,������ת��JMP
////        4'b1000: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00001000;   //9,������ת��BAN
////        4'b1001: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b10000000;   //10,ͣ��STOP
//        endcase
//    end

endmodule