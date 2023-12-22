module clk_use(
    input   wire    clk_sys,
    input   wire    go,
    input   wire    clr,
    
    output  reg     clk_use
    );
    
    parameter   clk_count = 10_000_000;
    //parameter   clk_count = 4;
    reg     [23:0]  counter;
    //reg     [3:0]  counter;
    always @ (posedge clk_sys or negedge clr) begin
        if (clr == 1'b0) begin
            counter <=  24'b0;
        end else    begin
            if (go == 1'b1) begin
                if (counter >= clk_count)   counter <=  24'b0;
                else                        counter <=  counter + 1'b1;
            end else begin
                counter <=  counter;
            end
        end
    end
    
    always @ (counter)
        if ( counter == clk_count)  clk_use <=  1'b1;
        else                        clk_use <=  1'b0;
        
endmodule
