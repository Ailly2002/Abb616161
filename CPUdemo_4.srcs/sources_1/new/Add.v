//ר�ü������������JAL�ȿ���ת��ָ��ĵ�ַ����
//ר�Ż��ֵ�ԭ������ALU��output����ͬ��Add������͵�PC����WBU
`include "define.v"
module add(
    input wire [`RegBus]      in1,//��ǰPC��ַ
    input wire [`RegBus]      shift,
    
    output reg [`RegBus]   add_result//�����������PC
);
    always @(*) begin
        add_result = in1 + shift;
    end
endmodule