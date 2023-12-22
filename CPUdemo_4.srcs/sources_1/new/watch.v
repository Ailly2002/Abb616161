module watch(
    output  reg     [3:0]   d2,
    output  reg     [3:0]   d1,
    output  reg     [3:0]   d0,
    
    input   wire            clk_use,
    input   wire            clr
    );
    
    
    always @ (posedge clk_use or negedge clr) begin
        if (clr == 1'b0) begin
            d2  <=  4'b0;
            d1  <=  4'b0;
            d0  <=  4'b0;
        end else begin//½øÎ»
            if (d0 < 9) 
                d0  <=  d0 + 1'b1;
            else begin
                d0  <=  4'b0;
                if (d1 < 9)
                    d1 <= d1 + 1'b1;
                else begin
                    d1 <= 4'b0;
                    if (d2 < 9)
                        d2 <= d2 + 1'b1;
                    else begin
                        d2  <=  4'b0;
                    end
                end
            end
        end
    end
    
endmodule