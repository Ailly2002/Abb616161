`include "define.v"
module pc_add(
    input wire[`ADDR_BUS]pc_dr,
    input stop,
    output reg pc_next
    );
    reg [`ADDR_BUS] pc;
    reg halt;//��������ͣ��־λ
    initial halt = 1'b0;//��ʼʱ��־λΪ����ͣ״̬

    always@(*) begin
          pc<=pc_dr;
          if(stop == 1)begin//ID�μ�⵽���ܴ�����أ��Ƿ��ƣ���Ҫ����ˮ����ͣ
                if(halt == 1'b0)begin//haltλΪ1��������ͣ�ĵ�һ������
                    pc = pc-1;
                    halt <= 1'b1;
                    end
                else if(halt)begin 
                    pc = pc;
                    end
            end      
          else begin
                pc = pc+1;
                halt <= 1'b0;
          end
    end
endmodule
