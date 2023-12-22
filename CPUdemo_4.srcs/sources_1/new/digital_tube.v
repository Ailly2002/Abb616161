module digital_tube(
    input wire clk,
    input wire rst,
    input signed [31:0] display,
    output reg [7:0] an,
    output reg [6:0] seg
);
    reg [20:0] cnt_dt;
    
    always @ (posedge clk or negedge rst)begin//时钟分频
        if(!rst)begin
            cnt_dt<=0;
        end
        else begin
            cnt_dt<=cnt_dt+1'b1;
        end
    end
    
    reg [3:0] sel;//选择输出
    
    always @(*) begin
        if(!rst)begin
            an=8'b1111_1111;
        end
        else begin
            case(cnt_dt[20:18])
                3'b000: begin an=8'b0111_1111; sel=display[31:28]; end
                3'b001: begin an=8'b1011_1111; sel=display[27:24]; end
                3'b010: begin an=8'b1101_1111; sel=display[23:20]; end
                3'b011: begin an=8'b1110_1111; sel=display[19:16]; end
                3'b100: begin an=8'b1111_0111; sel=display[15:12]; end
                3'b101: begin an=8'b1111_1011; sel=display[11:8]; end
                3'b110: begin an=8'b1111_1101; sel=display[7:4]; end
                3'b111: begin an=8'b1111_1110; sel=display[3:0]; end
            endcase 
            
//            case(sel)
                
//            endcase
        end
    end
endmodule