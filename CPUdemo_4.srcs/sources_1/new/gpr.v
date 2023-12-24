`include "define.v"
module regfile(
    input   wire    clk,
    input   wire    rst,
    //IDU和WBU修改记分牌入口
    input wire [4:0] id_chvdb,
    input wire [9:0] wb_chvdb,
    //读寄存器 reg1
    input wire                    re1,     // read enable
    input   wire    [`RegAddr]   rs1_addr,
    output   reg    [`RegBus]    rs1_data,
    //读寄存器 reg2
    input wire                    re2,     // read enable
    input   wire    [`RegAddr]   rs2_addr,
    output   reg    [`RegBus]    rs2_data,
    //写寄存器 reg
    input wire                    we,     // write enable
    input   wire    [`RegAddr]   wd_addr,
    input   wire   [`RegBus]    wd_wdata,
    //送到七段数码管显示
    output reg [11:0] disp_dat
    
    );
    
    reg[`RegBus] regs[0:31];//32个通用寄存器

    initial begin
        
        regs[0] = 32'b0000000000000000;//寄存器x0是硬件连线的常数0。没有硬件连线的子程序返回地址连接寄存器，但是
                                       //在一个过程调用中，标准软件调用约定使用寄存器x1来保存返回地址。
        regs[1] = 32'b0000000000000001;
        regs[2] = 32'b0000000000000011;
        regs[3] = 32'b0000000000001000;
    end
    always @(clk)begin//数码管显示
        disp_dat <= regs[3][11:0];//低16位
    end
    
    
    /* 写操作 */
    always @ (negedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (wd_addr != 5'b00000)) begin
                regs[wd_addr] <= wd_wdata;
            end
        end
    end
        
	/* 读端口1操作 */
    always @ (*) begin
        if(rst == `RstEnable) begin
            rs1_data <= `ZeroWord;
        end else if(rs1_addr == 5'b00000) begin
            rs1_data <= `ZeroWord;  
        end else if(re1 == `ReadEnable) begin
            rs1_data <= regs[rs1_addr];
        end else begin
            rs1_data <= `ZeroWord;
        end
    end

    /* 读端口2操作 */
    always @ (*) begin
        if(rst == `RstEnable) begin
            rs2_data <= `ZeroWord;
        end else if(rs2_addr == 5'b00000) begin
            rs2_data <= `ZeroWord;  
        end else if(re2 == `ReadEnable) begin
            rs2_data <= regs[rs2_addr];
        end else begin
            rs2_data <= `ZeroWord;
        end
    end
endmodule