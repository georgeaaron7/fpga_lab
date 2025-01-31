module modified_booths(
    input [3:0] multiplicand,
    input [3:0] multiplier,
    output reg [7:0] product
);
    reg [4:0] BoothMultiplier;
    reg [7:0] BoothMultiplicand, BoothMultiplicandNeg;
    integer i;

    always @(*) begin
        BoothMultiplier = {multiplier, 1'b0};
        BoothMultiplicand = {4'b0, multiplicand};
        BoothMultiplicandNeg = ~BoothMultiplicand + 1;
        product = 8'b0;

        for (i = 0; i < 4; i = i + 1) begin
            case (BoothMultiplier[2:0])
                3'b001, 3'b010: product = product + (BoothMultiplicand << (i * 2));
                3'b011: product = product + ((BoothMultiplicand << 1) << (i * 2));
                3'b100: product = product + ((BoothMultiplicandNeg << 1) << (i * 2));
                3'b101, 3'b110: product = product + (BoothMultiplicandNeg << (i * 2));
                default: product = product;
            endcase

            BoothMultiplier = BoothMultiplier >>> 2;
        end
    end
endmodule

module modified_booths_tb;
    reg [3:0] multiplicand, multiplier;
    wire [7:0] product;

    modified_booths uut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );

    initial begin
        $monitor("Time: %0t | Multiplicand = %d, Multiplier = %d, Product = %d",
                 $time, multiplicand, multiplier, product);

        multiplicand = 4'b0011; multiplier = 4'b0101; #10;
        multiplicand = 4'b0110; multiplier = 4'b1010; #10;
        multiplicand = 4'b0000; multiplier = 4'b1111; #10;
        multiplicand = 4'b0101; multiplier = 4'b0110; #10;

        $finish;
    end
endmodule
