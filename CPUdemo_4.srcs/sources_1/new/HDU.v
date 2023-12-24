`include "define.v"
//Hazard detection unit

module hdu(
    //IDU��WBU�޸ļǷ������
    input wire [14:0] use_vdb,
    input wire [14:0] unuse_vdb,
    //�͵�IDU�����ڶ�ȡ�Ƿ���
    output reg [`RegBus] valid_bit,
    output reg           stop //��ˮ����ͣ�ź�
);
    //�Ƿ��ƣ����ڼ�����
    reg[`InstBus] reg_valid;//Ϊÿ���Ĵ���������Чλ
    initial begin
        reg_valid = 32'b0000_0000_0000_0000_0000_0000;
        stop = 0;
        end
    always @(*)begin//����������
        if(valid_bit[use_vdb[14:10]] && valid_bit[use_vdb[9:5]] && valid_bit[use_vdb[4:0]])begin
            stop = `unStall;//0
        end
        else stop = `Stall;//1
    end
    always @(*)begin//���ԣ��޸Ķ�Ӧλ
        if(use_vdb[4:0] != 5'b00000)reg_valid[use_vdb[4:0]]=1'b1;
        else if(use_vdb[9:5] != 5'b00000)reg_valid[use_vdb[9:5]]=1'b1;
        else if(use_vdb[14:10] != 5'b00000)reg_valid[use_vdb[14:10]]=1'b1;
    end
    always @(*)begin//ʹ�ý������޸Ķ�Ӧλ
        if(unuse_vdb[4:0] != 5'b00000)      reg_valid[unuse_vdb[4:0]]=reg_valid[unuse_vdb[4:0]]&&0;
        else if(unuse_vdb[9:5] != 5'b00000) reg_valid[unuse_vdb[9:5]]=reg_valid[unuse_vdb[9:5]]&&0;
        else if(unuse_vdb[14:10] != 5'b00000)reg_valid[unuse_vdb[14:10]]=reg_valid[unuse_vdb[14:10]]&&0;
    end
    always @(*)begin
        valid_bit <= ~reg_valid;
    end
    
endmodule