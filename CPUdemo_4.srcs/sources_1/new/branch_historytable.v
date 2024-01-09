//分支历史表BHT
module bht(
    input wire clk,
    input wire rst,    // reset to state A（00）
    input wire branch,
    input wire in,
    output reg out 
);
    parameter A=2'b00,B=2'b01,C=2'b10,D=2'b11;
    reg [1:0] state,next_state;
    initial state <= A;
    always @(posedge clk,posedge rst)begin
        if(branch)begin
            if(rst)
                state <= A;
            else
                state <= next_state;
        end
    end
    always @(*)begin
            case(state)
                A:begin
                    if(in)
                        next_state <= B;
                    else
                        next_state <= A;
                end
                B:begin
                    if(in)
                        next_state <= D;
                    else
                        next_state <= A;
                end
                C:begin
                    if(in)
                        next_state <= D;
                    else
                        next_state <= A;
                end
                D:begin
                    if(in)
                        next_state <= D;
                    else
                        next_state <= C;
                end
            endcase
    end
    always @(*)begin
        if(branch)
            out <= ((state == C)||(state == D));
        else
            out <= 1'b0;
    end
endmodule