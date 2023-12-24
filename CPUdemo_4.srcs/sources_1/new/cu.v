//CU
`include "define.v"
module cu(
//    input wire          clk,
    input wire          rst,
    input wire  [`InstBus]      inst,
    input wire  [`ADDR_BUS]     pcadd,//��ǰPC��ַ
    
    input wire [`RegBus]        valid_bit,//��ȡ�Ƿ��Ƶ�ǰ��Чλ
    
    //��ȡ��Regfile��ֵ
    input wire[`RegBus]         reg1_data,
    input wire[`RegBus]         reg2_data,
    //�����Regfile����Ϣ
    output reg                  reg1_read,
    output reg                  reg2_read,
    output reg[`RegAddr]        reg1_addr,
    output reg[`RegAddr]        reg2_addr,
    //��HDU
    output reg                  instvalid_o,
    output reg[14:0]            use_vdb,//Ŀ�ļĴ�����ַ�����ڼǷ��ƹ���
    
    
    //�����EX�׶�(��һ���׶�)
        //��Add
    output reg [`ADDR_BUS]      pcadd_o,
    output reg [`RegBus]        shift,//������ƫ������EX_ADD����һ��������
        //��Add_MUX
    output reg[`RegBus]         rs1_o,
    output reg                  j_type,//��תָ������ͣ�JAL/JALR
        //��ALU/EX
    output reg[`AluOpBus]       aluop_o,//
    output reg[6:0]             funct7,
    output reg[`AluSelBus]      funct3,//funct//
    output reg[`RegBus]         reg1_o,//
    output reg[`RegBus]         reg2_o,//
    output reg[`RegAddr]        wd_o,//
    output reg                  wreg_o//
);
    
    reg[`OPcode] operate;//7λָ�������,����������
    //����ָ��ִ����Ҫ��������
    //32��ȣ�������Ҫ�ü�
    reg[`RegBus]   imm12;//I������
    reg[`RegBus]   imm20;//U������

    //ָʾָ���Ƿ���Ч
    initial begin
        instvalid_o   <=  `InstInvalid;
    end
    
    always @(*) begin
        if(rst == `RstEnable)begin
                        //��λ
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
            imm12   <= { {20{inst[31]}}, inst[31:20] };//12λI������,������չ
            imm20   <= { inst[31:12] , {12'b0000_0000_0000} };//20λU������,��λ��չ
            funct3  <= inst[14:12];//3λfunct
            operate <= inst[6:0];
            case(inst[6:0])
                `OP:    begin//���в������Ƕ�ȡrs1��rs2�Ĵ�����ΪԴ�����������ѽ��д�뵽�Ĵ���rd��
                        //ָ��ִ��Ҫ��д��Ŀ�ļĴ���
                        reg1_addr=inst[19:15];
                        reg2_addr=inst[24:20];
                        wd_o   =  inst[11:7];
                        //�����и�ʽ�У�RISC-V ISA��Դ�Ĵ�����rs1��rs2����Ŀ��Ĵ�����rd���̶���ͬ����λ�ã��Լ�ָ������
                        aluop_o <= operate;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadEnable;
                        reg2_read <= `ReadEnable;
                        funct7=inst[31:25];
//                        source_regs = {reg2_addr,reg1_addr};
                        instvalid_o   =  `InstValid;//ָ����Ч
                    end
                 `OP_IMM:begin
                        reg1_addr=inst[19:15];
                        wd_o   =  inst[11:7];

                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=inst[31:25];//��������7λ����alu��
//                                source_regs = {5'b00000,reg1_addr};
                                instvalid_o   =  `InstValid;

                    end
                 `LUI:begin
                        reg1_addr=inst[11:7];
                        wd_o   =  inst[11:7];

                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;
                                reg2_read <= `ReadDisable;
                                instvalid_o   =  `InstValid;
                    end
                    `AUIPC:begin
                            wd_o   =  inst[11:7];
                            
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                                reg2_read <= `ReadDisable;
                                instvalid_o   =  `InstValid;
                    end
                    `JAL:begin//�����Ͽ�������U��ָ������е�imm20���зָ��ȡ
                            wd_o   =  inst[11:7];
                            
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                                reg2_read <= `ReadDisable;
                                instvalid_o   =  `InstValid;
                    end
                    `JALR:begin
                    end
                    `BRANCH:begin
                    end
                default:begin
                    instvalid_o   <=  `InstInvalid;
                end
            endcase
        end
    end
    //******
    //ȷ������Դ������1
    always @ (*) begin
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
    always @ (*) begin
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
        pcadd_o  <= pcadd;
        if(~instvalid_o)begin
            use_vdb <= {{reg2_addr},{reg1_addr},{wd_o}};
        end
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