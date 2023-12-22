`define ADDR_SIZE   32
`define PC_SIZE     32

`define ADDR_BUS 31:0
`define InstBus 31:0

`define RegAddr 4:0 //Regfile模块的地址线宽度
`define RegBus  31:0
`define NOPRegAddr 5'b00000     //空操作使用的寄存器地址
`define DataBus 15:0
`define OPcode 6:0
`define OPcode_SIZE 7

`define FUNCT3_SIZE 3

`define IMM_I_BUS 11:0
`define IMM_I_SIZE 12
`define IMM_U_BUS 31:12
`define IMM_U_SIZE 20


`define RstEnable 1'b1          //复位使能
`define RstDisable 1'b0         //复位除能
`define WriteEnable 1'b1        //写使能
`define WriteDisable 1'b0       //写除能
`define ReadEnable 1'b1         //读使能
`define ReadDisable 1'b0        //读除能
`define InstValid 1'b0          //指令有效
`define InstInvalid 1'b1        //指令无效
`define ZeroWord 32'h00000000
`define NOPRegAddr 5'b00000     //空操作使用的寄存器地址

//指令opcode
`define OP_IMM  7'b0000000
`define LUI     7'b0000001
`define AUIPC   7'b0000010
`define OP      7'b0000011
`define JAL     7'b0000100
`define JALR    7'b0000101
`define BRANCH  7'b0000110
`define LOAD    7'b0000111
`define STORE   7'b0001000

//******非指令集内容，具体未确定
`define AluOpBus 7:0            //译码阶段输出操作子类型数据宽度
`define AluSelBus 2:0           //译码阶段输出操作类型数据宽度
//******

`define SEG 32'hFFFF_F020