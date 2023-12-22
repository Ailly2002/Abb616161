`define ADDR_SIZE   32
`define PC_SIZE     32

`define ADDR_BUS 31:0
`define InstBus 31:0

`define RegAddr 4:0 //Regfileģ��ĵ�ַ�߿��
`define RegBus  31:0
`define NOPRegAddr 5'b00000     //�ղ���ʹ�õļĴ�����ַ
`define DataBus 15:0
`define OPcode 6:0
`define OPcode_SIZE 7

`define FUNCT3_SIZE 3

`define IMM_I_BUS 11:0
`define IMM_I_SIZE 12
`define IMM_U_BUS 31:12
`define IMM_U_SIZE 20


`define RstEnable 1'b1          //��λʹ��
`define RstDisable 1'b0         //��λ����
`define WriteEnable 1'b1        //дʹ��
`define WriteDisable 1'b0       //д����
`define ReadEnable 1'b1         //��ʹ��
`define ReadDisable 1'b0        //������
`define InstValid 1'b0          //ָ����Ч
`define InstInvalid 1'b1        //ָ����Ч
`define ZeroWord 32'h00000000
`define NOPRegAddr 5'b00000     //�ղ���ʹ�õļĴ�����ַ

//ָ��opcode
`define OP_IMM  7'b0000000
`define LUI     7'b0000001
`define AUIPC   7'b0000010
`define OP      7'b0000011
`define JAL     7'b0000100
`define JALR    7'b0000101
`define BRANCH  7'b0000110
`define LOAD    7'b0000111
`define STORE   7'b0001000

//******��ָ����ݣ�����δȷ��
`define AluOpBus 7:0            //����׶�����������������ݿ��
`define AluSelBus 2:0           //����׶���������������ݿ��
//******

`define SEG 32'hFFFF_F020