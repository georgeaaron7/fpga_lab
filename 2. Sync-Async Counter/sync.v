module up_down_counter (
    input clk,
    input reset,
    input mode,
    output reg [3:0] Q
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b0000;
        else begin
            if (mode)
                Q <= Q + 1;
            else
                Q <= Q - 1;
        end
    end
endmodule

module s;
    reg clk;
    reg reset;
    reg mode;
    wire [3:0] Q;

    up_down_counter uut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .Q(Q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        mode = 0;
        #10 reset = 0;
        mode = 1;
        #100;
        mode = 0;
        #100;
        reset = 1;
        #10 reset = 0;
        #50 $stop;
    end
endmodule
