`include "define.v"
module pc_add(
    input wire[`ADDR_BUS]pc_dr,
    input stop,
    output reg pc_next
    );
    reg [`ADDR_BUS] pc;
    reg halt;//多周期暂停标志位
    initial halt = 1'b0;//初始时标志位为非暂停状态

    always@(*) begin
          pc<=pc_dr;
          if(stop == 1)begin//ID段检测到可能存在相关（记分牌），要求流水线暂停
                if(halt == 1'b0)begin//halt位为1，进入暂停的第一个周期
                    pc = pc-1;
                    halt <= 1'b1;
                    end
                else if(halt)begin 
                    pc = pc;
                    end
            end      
          else begin
                pc = pc+1;
                halt <= 1'b0;
          end
    end
endmodule
