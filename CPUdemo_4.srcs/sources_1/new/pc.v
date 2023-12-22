//PC
`include "define.v"
module pc(
    input wire clk, rst, stop, //ʱ�ӡ����á�ͣ��
    input wire ct, uct, //����ת�ơ�������ת��
//    input wire [4:0] offset,  //12λת��ָ��ƫ���� 5bit
    output reg [`ADDR_BUS] pc  //12λָ���ַ��  32bit
);
    reg halt;//��������ͣ��־λ
    initial halt = 1'b0;//��ʼʱ��־λΪ����ͣ״̬
    
    always@(posedge clk) begin
      if(rst == 1)begin
        pc = 32'h00000000;
        halt <= 1'b0;
        end
      else if(stop == 1)begin//ID�μ�⵽���ܴ�����أ��Ƿ��ƣ���Ҫ����ˮ����ͣ
            if(halt == 1'b0)begin//haltλΪ1��������ͣ�ĵ�һ������
                pc = pc-1;
                halt <= 1'b1;
                end
            else if(halt)begin 
            pc = pc;end
            end      
      else begin
            pc = pc+1;
            halt <= 1'b0;
        end
    end

//    always@(negedge clk) begin
//      if(uct == 1)  //������ת��
//        pc = offset-4;
//      if(ct == 1)  //����ת��
//        pc = pc+offset-4;
//    end

endmodule

