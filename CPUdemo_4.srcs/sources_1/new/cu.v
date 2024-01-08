//CU
`include "define.v"
module cu(
    input wire          clk,
    input wire          rst,
    input wire  [`InstBus]      inst,
    input wire  [`ADDR_BUS]     pcadd,//��ǰPC��ַ
    
    
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
    output reg[14:0]            use_vdb,//Ҫʹ�õļĴ�����ַ�����ڼǷ��ƹ���
    
    //��banch
    output reg     banch,
    //��IF/ID�Ĵ�����
        //��ָ֧����ͣ
    output reg                 branch_stall,//��Ϊbranch,ʵ����������/������ת�ƾ�ʹ�õ�IF��ˢ�ź�
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

    
    initial begin
        instvalid_o   <=  `InstInvalid;//ָʾָ���Ƿ���Ч
        banch <= 1'b1;//Ĭ����ת
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
            imm12   <= { {21{inst[31]}}, inst[31:20] };//12λI������,������չ
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
                        shift <= 32'b0;
                        wreg_o  <=  `WriteEnable;
                        reg1_read <= `ReadEnable;
                        reg2_read <= `ReadEnable;
                        funct7=inst[31:25];
                        instvalid_o   =  `InstValid;//ָ����Ч
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
                        funct7=inst[31:25];//��������7λ����alu��
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
                        reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                        reg2_read <= `ReadDisable;
                        instvalid_o   =  `InstValid;
                        banch <= 1'b0; 
                        branch_stall <= 1'b0;
                    end
                    `JAL:begin//�����Ͽ�������U��ָ������е�imm20���зָ��ȡ
                        reg1_addr=5'b00000;
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                            j_type <= 1'b0;//Ŀ���ַ����Ļ�ַ��Դ��PC
                            aluop_o <= operate;
                            shift <= {{13{inst[31]}},{inst[19:12]},{inst[20]},{inst[30:21]}};//��ƫ����������չ
                            wreg_o  <=  `WriteEnable;//��תָ�PC+1д�ؼĴ���
                            reg1_read <= `ReadDisable;//ͨ��rs1��ȡPC��ǰ�ĵ�ַ
                            reg2_read <= `ReadDisable;
                            funct7=7'b0000000;
                            instvalid_o   =  `InstValid;
                            banch <= 1'b1; //�Ƿ��ǿ���ת��ָ��
                            branch_stall <= 1'b1;
                            
                    end
                    `JALR:begin
                        reg1_addr=inst[19:15];
                        reg2_addr=5'b00000;
                        wd_o   =  inst[11:7];
                            j_type <= 1'b1;//Ŀ���ַ����Ļ�ַ��Դ����ַ�Ĵ���
                            aluop_o <= operate;
                            shift <= imm12;//inst[31:20]
                            wreg_o  <=  `WriteEnable;//��תָ�PC+1д�ؼĴ���
                            rs1_o <= reg1_addr;//ͨ��rs1�����ת
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
                            wreg_o  <=  `WriteDisable;//��ָ֧�д�ؼĴ���
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
    //ȷ������Դ������1
    always @ (*) begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if(reg1_read == `ReadEnable) begin
            reg1_o <= reg1_data;  //Regfile���˿�1�����ֵ
        end else if(reg1_read == `ReadDisable) begin
            if(operate == `AUIPC)begin
                reg1_o <= pcadd;end
            else if(operate == `JAL)begin
                reg1_o <= pcadd;end
            else if(operate == `JALR)begin
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
            else if(operate == `JAL)begin
                reg2_o <= 32'b000000_000000_000000_000000_000000_01;end
            else if(operate == `JALR)begin
                reg2_o <= 32'b000000_000000_000000_000000_000000_01;end
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
    //ifflush����
    always@(posedge clk)begin
        branch_stall <= 1'b0;
    end

endmodule