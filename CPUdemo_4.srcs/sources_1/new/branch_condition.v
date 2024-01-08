module branch_condition(
    input wire[`AluSelBus] funct,  //操作选择信号alu_op/funct
    input wire [`RegBus] in1,
    input wire [`RegBus] in2,
    output reg ct//Branch指令条件判断结果，输出0则跳转
);

always @(*)begin
    case(funct)
                    3'b000:begin
                        ct <= (in1==in2);//BEQ
                        end
                    3'b001:begin
                        ct <= ~(in1==in2);//BNE
                        end
                    3'b010:begin
                        ct <= ($signed(in1)<$signed(in2));//BLT
                        end
                    3'b011:begin;
                        ct <= (in1<in2);//BLTU
                        end
                    3'b100:begin
                        ct <= ($signed(in1)>$signed(in2));//BGE
                        end
                    3'b101:begin;
                        ct <= (in1>in2);//BGEU
                        end
                endcase
end

endmodule