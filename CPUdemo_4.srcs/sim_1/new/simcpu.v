 module simcpu;
    reg clk, rst;
    
    initial begin 
      clk = 1;
      rst = 1;
      #5 rst = 0;
      #160 $stop;
    end

    cpu cpu(
        .clk(clk), .rst(rst)
    );

    always #5 clk = ~clk;

endmodule
