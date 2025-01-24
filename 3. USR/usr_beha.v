module universal_shift_register(
    input clk,
    input reset,
    input [1:0] mode,
    input [3:0] parallel_in,
    input serial_in_left,
    input serial_in_right,
    output reg [3:0] Q
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b0000;
        else begin
            case (mode)
                2'b00: Q <= Q;
                2'b01: Q <= {serial_in_left, Q[3:1]};
                2'b10: Q <= {Q[2:0], serial_in_right};
                2'b11: Q <= parallel_in;
            endcase
        end
    end
endmodule

module tb_universal_shift_register;
    reg clk;
    reg reset;
    reg [1:0] mode;
    reg [3:0] parallel_in;
    reg serial_in_left;
    reg serial_in_right;
    wire [3:0] Q;

    universal_shift_register uut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .parallel_in(parallel_in),
        .serial_in_left(serial_in_left),
        .serial_in_right(serial_in_right),
        .Q(Q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1; mode = 2'b00; parallel_in = 4'b0000; serial_in_left = 1'b0; serial_in_right = 1'b0;
        #10 reset = 0;

        mode = 2'b11; parallel_in = 4'b1010; #10;
        mode = 2'b01; serial_in_left = 1'b1; #40;
        mode = 2'b10; serial_in_right = 1'b0; #40;
        mode = 2'b00; #10;
        reset = 1; #10 reset = 0;
        #50 $stop;
    end
endmodule
