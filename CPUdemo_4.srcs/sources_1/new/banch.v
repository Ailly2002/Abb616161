module banch(
    input wire in1,//�����ź���
    input wire in2,//ALU�����
    output wire banch
);
    assign banch = in1&in2;
endmodule