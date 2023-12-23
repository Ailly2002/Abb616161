//PC
`include "define.v"
module pc(
    input wire clk, rst, //ʱ�ӡ����á�ͣ��
    input wire ct, //����ת�ơ�������ת��
    input wire [`ADDR_BUS] pc_set,
//    input wire [4:0] offset,  //12λת��ָ��ƫ���� 5bit
    output wire [`ADDR_BUS] pc_bus_o  //12λָ���ַ��  32bit
);
    
    reg [`ADDR_BUS] pc;
    assign pc_bus_o = pc;
    
    always@(posedge clk) begin
      if(rst == 1)begin
        pc = 32'h00000000;
        end      
      else begin
            pc = pc_set;
        end
    end

//    always@(negedge clk) begin
//      if(uct == 1)  //������ת��
//        pc = offset-4;
//      if(ct == 1)  //����ת��
//        pc = pc+offset-4;
//    end

endmodule

