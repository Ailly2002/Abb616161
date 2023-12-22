//专用计算机构，用于JAL等控制转移指令的地址计算
//专门划分的原因是与ALU的output方向不同，Add将结果送到PC而非WBU
module add(
    input wire [`ADDR_BUS]      pcadd,//当前PC地址
    input wire [`RegBus] shift,
    
    output wire [`RegBus] offset//输出计算结果到PC
);

endmodule