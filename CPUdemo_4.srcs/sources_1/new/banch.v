module banch(
    input wire in1,//�����ź���
    input wire in2,//ALU�����
    output wire sel
);
    assign sel = in1|in2;
endmodule