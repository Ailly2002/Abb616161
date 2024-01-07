`include "define.v"//Hazard detection unit
module hdu(
    input wire clk,
    //IDU��WBU�޸ļǷ������
    input wire [14:0] use_vdb,
    input wire [14:0] unuse_vdb,
    //ָ����Ч���
    input wire instvalid_i,
    //�͵�EXU�������͵�WBU
    output reg [9:0] source_regs,
    //��ˮ����ͣ�ź�
    output reg           stop 
);
    //�Ƿ��ƣ����ڼ�����
    reg[`InstBus] reg_valid;//Ϊÿ���Ĵ���������Чλ
    initial begin
        reg_valid = 32'b0000_0000_0000_0000_0000_0000;
        stop = 0;
        source_regs <= 10'b00000_00000;
        end
    always @(use_vdb)begin//����������
        if(instvalid_i == `InstValid)begin//���ָ����Ч
            if(((reg_valid[use_vdb[14:10]]==0) || (use_vdb[14:10]==5'b00000))&&((reg_valid[use_vdb[9:5]]==0) || (use_vdb[9:5]==5'b00000)) &&((reg_valid[use_vdb[4:0]]==0) || (use_vdb[4:0]==5'b00000)))begin
                stop <= `unStall;//0
                if(use_vdb[4:0] != 5'b00000)    reg_valid[use_vdb[4:0]]     <=1'b1;//ʹ�ã��޸ļǷ��ƵĶ�Ӧʮ������λ
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

    always @(*)begin//ʹ�ý������Ƿ��ƵĶ�Ӧʮ������λ
        if(unuse_vdb[4:0] != 5'b00000)      reg_valid[unuse_vdb[4:0]]   <=1'b0;
        if(unuse_vdb[9:5] != 5'b00000)      reg_valid[unuse_vdb[9:5]]   <=1'b0;
        if(unuse_vdb[14:10] != 5'b00000)    reg_valid[unuse_vdb[14:10]] <=1'b0;
    end
    always @(posedge clk)begin
        if(stop)begin//���������ˮ����ͣ״̬��ÿ�����ڽ��м���ܷ���
            if((reg_valid[use_vdb[14:10]]==0 || use_vdb[14:10]==5'b00000)&&(reg_valid[use_vdb[9:5]]==0 || use_vdb[9:5]==5'b00000) &&(reg_valid[use_vdb[4:0]]==0 || use_vdb[4:0]==5'b00000))begin
                stop <= `unStall;//0
                if(use_vdb[4:0] != 5'b00000)    reg_valid[use_vdb[4:0]]     <=1'b1;//ʹ�ã��޸ļǷ��ƵĶ�Ӧʮ������λ
                if(use_vdb[9:5] != 5'b00000)    reg_valid[use_vdb[9:5]]     <=1'b1;
                if(use_vdb[14:10] != 5'b00000)  reg_valid[use_vdb[14:10]]   <=1'b1;
                source_regs <= {{use_vdb[14:10]},{use_vdb[9:5]}};
            end
        end
    end
    
endmodule