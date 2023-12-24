 //WBU
 //Load & Store
module wbu(
    input wire rst,
    input wire clk,
    //����EX
    input wire [9:0] ex_chvdb,
    input wire ex_wreg, //ʹ��**
    input wire [`RegAddr] ex_addr, //5λָ���ַ,����ѡ��Ĵ���
    input wire [`RegBus] data_in,  //��ִ��EX���֣���õ�32λ��������
    
    //�͵�RegFile
    output reg [9:0] wb_chvdb,
    output reg wb_wreg, 
    output reg [`RegAddr] wb_addr, //5λָ���ַ,����ѡ��Ĵ���
    output reg [`RegBus] data_out, //32λ�������
    //�Ƿ���ά��
    output reg [14:0] unuse_vdb//ʹ�����
);

    always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_addr = `NOPRegAddr;
			wb_wreg = `WriteDisable;
		end 
		else begin
			wb_addr = ex_addr;
			wb_wreg = ex_wreg;
		end    
		unuse_vdb = {{wb_chvdb},{wb_addr}};
	end
	always @(*)begin //�ֲ�EXU����ó�������ѵ�һ������
        if(rst == `RstEnable) data_out <= `ZeroWord;
		else data_out <= data_in;
    end
//	always @(rst)begin
//	   if(rst == `RstEnable) begin
//	       data_out <= `ZeroWord;
//			wb_addr = `NOPRegAddr;
//			wb_wreg = `WriteDisable;
//	   end
//	end

endmodule

