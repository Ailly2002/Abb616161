//AC
`include "define.v"
module acc(
    input wire clk, acc_wr, //ʱ�ӡ�acc��д����
    input wire [`IMM_I_BUS] data_in,  //16λ��������,11:0
    output wire [`IMM_I_BUS] data_out //16λ�������
);
    reg [15:0] acc; //16λacc

    initial begin
        acc = 1;  //acc��ʼ��1
    end

    assign data_out = acc; 

    always@(negedge clk) begin//ʱ��������д��
      if(acc_wr == 1)
        acc = data_in;
    end

endmodule
