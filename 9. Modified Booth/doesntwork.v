module booth_multiplier_3bit(
    input [2:0] A,
    input [2:0] B,
    output reg [5:0] P
);

    reg [5:0] multiplicand;
    reg [3:0] multiplier;
    reg [5:0] product;
    reg [1:0] temp;
    integer i;

    always @ (A or B)
    begin
        multiplicand = {3'b000, A};
        multiplier = {B, 1'b0}; // add an extra bit for Booth's algorithm
        product = 6'b000000;

        for (i = 0; i < 3; i = i + 1) begin
            temp = {multiplier[1], multiplier[0]};

            if (temp == 2'b01)
                product = product + multiplicand;
            else if (temp == 2'b10)
                product = product - multiplicand;

            multiplicand = multiplicand << 1;
            multiplier = multiplier >> 1;
        end

        P = product;
    end
endmodule

module test_bench;
    reg [2:0] A;
    reg [2:0] B;
    wire [5:0] P;

    booth_multiplier_3bit uut (
        .A(A),
        .B(B),
        .P(P)
    );

    initial begin
        // Test cases
        A = 3'b001; B = 3'b010; // 1 * 2 = 2
        #10;
        A = 3'b110; B = 3'b011; // -2 * 3 = -6
        #10;
        A = 3'b011; B = 3'b001; // 3 * 1 = 3
        #10;
        A = 3'b101; B = 3'b100; // -3 * -4 = 12
        #10;
        A = 3'b111; B = 3'b111; // -1 * -1 = 1
        #10;

        $stop;
    end
endmodule
