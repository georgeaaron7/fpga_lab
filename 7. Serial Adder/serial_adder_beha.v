module adder(
    input clk, reset,
    input [3:0] a,
    input [3:0] b,
    output reg [3:0] sum,
    output reg cout
);
    wire [3:0] shift_a;
    wire [3:0] shift_b;
    wire [3:0] result;
    wire [3:0] carry;

    register r1(clk, reset, a, shift_a);
    register r2(clk, reset, b, shift_b);

    full_adder f1(shift_a[0], shift_b[0], 1'b0, result[0], carry[0]);
    full_adder f2(shift_a[1], shift_b[1], carry[0], result[1], carry[1]);
    full_adder f3(shift_a[2], shift_b[2], carry[1], result[2], carry[2]);
    full_adder f4(shift_a[3], shift_b[3], carry[2], result[3], carry[3]);

    always @(posedge clk) begin
        if (reset) begin
            sum <= 4'b0000;
            cout <= 1'b0;
        end else begin
            sum <= result;
            cout <= carry[3];
        end
    end
endmodule

module full_adder(
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module register(
    input clk, reset,
    input [3:0] data_in,
    output [3:0] data_out
);
    reg [3:0] shift_reg;

    always @(posedge clk) begin
        if (reset)
            shift_reg <= 4'b0000;
        else
            shift_reg <= data_in;
    end

    assign data_out = shift_reg;
endmodule
