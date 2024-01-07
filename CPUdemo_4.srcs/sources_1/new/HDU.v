`include "define.v"//Hazard detection unit
module hdu(
    input wire clk,
    //IDU和WBU修改记分牌入口
    input wire [14:0] use_vdb,
    input wire [14:0] unuse_vdb,
    //指令有效入口
    input wire instvalid_i,
    //送到EXU，最终送到WBU
    output reg [9:0] source_regs,
    //流水线暂停信号
    output reg           stop 
);
    //记分牌，用于检测相关
    reg[`InstBus] reg_valid;//为每个寄存器设置有效位
    initial begin
        reg_valid = 32'b0000_0000_0000_0000_0000_0000;
        stop = 0;
        source_regs <= 10'b00000_00000;
        end
    always @(use_vdb)begin//检测数据相关
        if(instvalid_i == `InstValid)begin//如果指令有效
            if(((reg_valid[use_vdb[14:10]]==0) || (use_vdb[14:10]==5'b00000))&&((reg_valid[use_vdb[9:5]]==0) || (use_vdb[9:5]==5'b00000)) &&((reg_valid[use_vdb[4:0]]==0) || (use_vdb[4:0]==5'b00000)))begin
                stop <= `unStall;//0
                if(use_vdb[4:0] != 5'b00000)    reg_valid[use_vdb[4:0]]     <=1'b1;//使用，修改记分牌的对应十进制数位
                if(use_vdb[9:5] != 5'b00000)    reg_valid[use_vdb[9:5]]     <=1'b1;
                if(use_vdb[14:10] != 5'b00000)  reg_valid[use_vdb[14:10]]   <=1'b1;
                source_regs <= {{use_vdb[14:10]},{use_vdb[9:5]}};
            end
            else if(use_vdb == 15'b00000_00000_00000)begin
                stop <= `unStall;//0
                source_regs <= {{use_vdb[14:10]},{use_vdb[9:5]}};
            end
            else  begin
                stop <= `Stall;//1
            end
        end
        else stop <= `unStall;
    end

    always @(*)begin//使用结束，记分牌的对应十进制数位
        if(unuse_vdb[4:0] != 5'b00000)      reg_valid[unuse_vdb[4:0]]   <=1'b0;
        if(unuse_vdb[9:5] != 5'b00000)      reg_valid[unuse_vdb[9:5]]   <=1'b0;
        if(unuse_vdb[14:10] != 5'b00000)    reg_valid[unuse_vdb[14:10]] <=1'b0;
    end
    always @(posedge clk)begin
        if(stop)begin//如果处于流水线暂停状态，每个周期进行检查能否唤醒
            if((reg_valid[use_vdb[14:10]]==0 || use_vdb[14:10]==5'b00000)&&(reg_valid[use_vdb[9:5]]==0 || use_vdb[9:5]==5'b00000) &&(reg_valid[use_vdb[4:0]]==0 || use_vdb[4:0]==5'b00000))begin
                stop <= `unStall;//0
                if(use_vdb[4:0] != 5'b00000)    reg_valid[use_vdb[4:0]]     <=1'b1;//使用，修改记分牌的对应十进制数位
                if(use_vdb[9:5] != 5'b00000)    reg_valid[use_vdb[9:5]]     <=1'b1;
                if(use_vdb[14:10] != 5'b00000)  reg_valid[use_vdb[14:10]]   <=1'b1;
                source_regs <= {{use_vdb[14:10]},{use_vdb[9:5]}};
            end
        end
    end
    
endmodule