//PC
`include "define.v"
module pc(
    input wire clk, rst, //时钟、重置、停机
    input wire ct, //条件转移
    input wire pc_Write,
    input wire [`ADDR_BUS] pc_set,
//    input wire [4:0] offset,  //12位转移指令偏移量 5bit
    output wire [`ADDR_BUS] pc_bus_o  //12位指令地址码  32bit
);
    
    reg [`ADDR_BUS] pc;
    assign pc_bus_o = pc;
    
    always@(posedge clk) begin
      if(rst == 1)begin
        pc = 32'h00000000;
        end      
      else if(pc_Write == 1'b0)begin
            pc = pc_set;
        end
      else pc <= pc;
    end

//    always@(negedge clk) begin
//      if(uct == 1)  //无条件转移
//        pc = offset-4;
//      if(ct == 1)  //条件转移
//        pc = pc+offset-4;
//    end

endmodule

