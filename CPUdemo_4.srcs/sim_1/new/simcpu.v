 module simcpu;
    reg clk, rst ,go;
    
    initial begin 
      clk = 1;
      rst = 1;
      go = 1;
      #5 rst = 0;
      #180 $stop;
    end

    cpu CPU(
        .clk(clk), .rst(rst), .go(go)
    );

    always #5 clk = ~clk;

endmodule
