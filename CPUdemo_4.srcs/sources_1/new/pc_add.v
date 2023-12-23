`include "define.v"
module pc_add(
    input wire[`ADDR_BUS]pc_dr,
    output reg[`ADDR_BUS] pc
    );

    
    always @(*) begin  
          pc <= pc_dr+1;
    end
endmodule
