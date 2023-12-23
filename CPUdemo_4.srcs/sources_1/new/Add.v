//专用计算机构，用于JAL等控制转移指令的地址计算
//专门划分的原因是与ALU的output方向不同，Add将结果送到PC而非WBU
`include "define.v"
module add(
    input wire [`RegBus]      in1,//当前PC地址
    input wire [`RegBus]      shift,
    
    output reg [`RegBus]   add_result//输出计算结果到PC
);
    always @(*) begin
        add_result = in1 + shift;
    end
endmodule