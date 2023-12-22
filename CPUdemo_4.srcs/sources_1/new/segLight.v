module segLight(
    input clk,//ego 100Mhz
    input [31:0] din,
    output reg[7:0] bit,//数码管位选信号
    output reg[7:0] dout1,//数码管段选信号
    output reg[7:0] dout2//数码管段选信号
);
    parameter _0= 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
               _4= 8'h99,_5 =8'h92,_6 = 8'h82,_7 = 8'hf8,
               _8 = 8'h80,_9 = 8'h90,_a=8'h88,_b=8'h83,_c=8'hc6,_d=8'ha1,_e=8'h86,_f=8'h8e;
    reg[1:0] ctrl;
    reg[20:0] cnt;
    wire clk_200hz;

endmodule