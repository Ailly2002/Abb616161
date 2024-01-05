module banch(
    input wire in1,//控制信号入
    input wire in2,//ALU结果入
    output wire banch
);
    assign banch = in1&in2;
endmodule