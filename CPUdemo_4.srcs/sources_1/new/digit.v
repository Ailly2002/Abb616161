`include "define.v"
module digit_tubes(
    input wire clk,
    input wire rst,
    input wire [11:0] disp_dat,//32位，要显示的数据
//    input[15:0] sw, //开关
    output  reg [7:0] seg,//数码管段选，高有效
    output reg [3:0] an //数码管位选，低有效
);

//    reg[18:0] divclk_cnt = 0;//分频计数器
//    reg divclk = 0;//分频后的时钟

//    reg [3:0] sel;//一个七段数码管的输出值

	   parameter   seg7_0 = ~8'hc0,    seg8_0 = ~8'h40;
	   parameter   seg7_1 = ~8'hf9,    seg8_1 = ~8'h79;
	   parameter   seg7_2 = ~8'ha4,    seg8_2 = ~8'h24;
	   parameter   seg7_3 = ~8'hb0,    seg8_3 = ~8'h30;
	   parameter   seg7_4 = ~8'h99,    seg8_4 = ~8'h19;
	   parameter   seg7_5 = ~8'h92,    seg8_5 = ~8'h12;
	   parameter   seg7_6 = ~8'h82,    seg8_6 = ~8'h02;
	   parameter   seg7_7 = ~8'hf8,    seg8_7 = ~8'h78;
	   parameter   seg7_8 = ~8'h80,    seg8_8 = ~8'h00;
	   parameter   seg7_9 = ~8'h90,    seg8_9 = ~8'h10;
	   parameter   _err = ~8'hcf;
	   
	   parameter   N = 18;
    
    reg     [7:0]   seg7_data2, seg8_data1, seg7_data0;   
    reg     [N-1 : 0]  regN; 
    reg     [3:0]       hex_in;//显示四位数字
    
        always @ (posedge clk)   begin
        if (rst == 1'b0)    begin
            regN    <=  0;
        end else    begin
            regN    <=  regN + 1;
        end
    end
    always @ (*)    begin
        case (regN[N-1: N-2])//[17:16]
            2'b00:  begin
                an  <=  4'b0001;
                seg  <=  seg7_0;
            end
            2'b01:  begin
                an  <=  4'b0010;
                seg  <=  seg7_data0;
            end
            2'b10:  begin
                an  <=  4'b0100;
                seg  <=  seg8_data1;
            end
            2'b11:  begin
                an  <=  4'b1000;
                seg  <=  seg7_data2;
            end
            default:    begin
                an  <=  4'b1111;
                seg  <=  _err;
            end
        endcase
    end
	 
    always @ (*)    begin
        case (disp_dat[11:8])
            4'h0:       seg7_data2 <= seg7_0;
            4'h1:       seg7_data2 <= seg7_1;
            4'h2:       seg7_data2 <= seg7_2;
            4'h3:       seg7_data2 <= seg7_3;
            4'h4:       seg7_data2 <= seg7_4;
            4'h5:       seg7_data2 <= seg7_5;
            4'h6:       seg7_data2 <= seg7_6;
            4'h7:       seg7_data2 <= seg7_7;
            4'h8:       seg7_data2 <= seg7_8;
            4'h9:       seg7_data2 <= seg7_9;
            default:    seg7_data2 <= _err;
        endcase
    end
    always @ (*)    begin
        case (disp_dat[7:4])
            4'h0:       seg8_data1 <= seg8_0;
            4'h1:       seg8_data1 <= seg8_1;
            4'h2:       seg8_data1 <= seg8_2;
            4'h3:       seg8_data1 <= seg8_3;
            4'h4:       seg8_data1 <= seg8_4;
            4'h5:       seg8_data1 <= seg8_5;
            4'h6:       seg8_data1 <= seg8_6;
            4'h7:       seg8_data1 <= seg8_7;
            4'h8:       seg8_data1 <= seg8_8;
            4'h9:       seg8_data1 <= seg8_9;
            default:    seg8_data1 <= _err;
        endcase
    end
    
    always @ (*)    begin    
        case (disp_dat[3:0])
            4'h0:       seg7_data0 = seg7_0;
            4'h1:       seg7_data0 = seg7_1;
            4'h2:       seg7_data0 = seg7_2;
            4'h3:       seg7_data0 = seg7_3;
            4'h4:       seg7_data0 = seg7_4;
            4'h5:       seg7_data0 = seg7_5;
            4'h6:       seg7_data0 = seg7_6;
            4'h7:       seg7_data0 = seg7_7;
            4'h8:       seg7_data0 = seg7_8;
            4'h9:       seg7_data0 = seg7_9;
            default:    seg7_data0 = _err;
        endcase
    end
//    initial an=8'b00000001;//位码

//    reg[`RegBus] disp_dat=0;//要显示的数据
    // reg[2:0] disp_bit=0;//要显示的位
//    parameter maxcnt = 50000;// 周期：50000*2/100M

//    always@(clk)//divide the clk
//    begin
//        if(divclk_cnt==maxcnt)
//        begin
//            divclk=~divclk;
//            divclk_cnt=0;
//        end
//        else
//        begin
//            divclk_cnt=divclk_cnt+1'b1;
//        end
//    end

//    reg [20:0] cnt_dt;
    
//    initial cnt_dt = 20'b00000_00000_00000_00000;
    
//    always @ (posedge clk)begin//计数自增
//        cnt_dt<=cnt_dt+1'b1;
//    end
    
//    always@(*) begin
//        if(!rst)begin
//            an=8'b1111_1111;
//        end
//        else begin
//            case(cnt_dt[20:18])//刷新显示顺序
//              case(cnt_dt[20:19])
//                3'b000: begin an=8'b0111_1111; sel=disp_dat[31:28]; end
//                3'b001: begin an=8'b1011_1111; sel=disp_dat[27:24]; end
//                3'b010: begin an=8'b1101_1111; sel=disp_dat[23:20]; end
//                3'b011: begin an=8'b1110_1111; sel=disp_dat[19:16]; end
//                3'b100: begin an=8'b1111_0111; sel=disp_dat[15:12]; end
//                3'b101: begin an=8'b1111_1011; sel=disp_dat[11:8];  end
//                3'b110: begin an=8'b1111_1101; sel=disp_dat[7:4];   end
//                3'b111: begin an=8'b1111_1110; sel=disp_dat[3:0];   end
//                2'b00: begin an=8'b1111_0111; sel=disp_dat[15:12]; end
//                2'b01: begin an=8'b1111_1011; sel=disp_dat[11:8];  end
//                2'b10: begin an=8'b1111_1101; sel=disp_dat[7:4];   end
//                2'b11: begin an=8'b1111_1110; sel=disp_dat[3:0];   end
//            endcase 
//        end
//    end

//    always @(*) begin
//        case(sel)//显示0-F
//                4'h0 : seg = 8'hfc;
//                4'h1 : seg = 8'h60;
//                4'h2 : seg = 8'hda;
//                4'h3 : seg = 8'hf2;
//                4'h4 : seg = 8'h66;
//                4'h5 : seg = 8'hb6;
//                4'h6 : seg = 8'hbe;
//                4'h7 : seg = 8'he0;
//                4'h8 : seg = 8'hfe;
//                4'h9 : seg = 8'hf6;
//                4'ha : seg = 8'hee;
//                4'hb : seg = 8'h3e;
//                4'hc : seg = 8'h9c;
//                4'hd : seg = 8'h7a;
//                4'he : seg = 8'h9e;
//                4'hf : seg = 8'h8e;
//            endcase
//    end

endmodule
