module shiftAddMultiplier(
    input [3:0] a,  // 4-bit multiplier
    input [3:0] b,  // 4-bit multiplicand
    output reg [7:0] o  // 8-bit product
);
    integer i;
    reg [3:0] tempA;  
    reg [7:0] shiftedB;  

    always @(*) begin
        o = 0;                 
        tempA = a;               
        shiftedB = {4'b0000, b};  // Extend b to 8 bits

        for (i = 0; i < 4; i = i + 1) begin
            if (tempA[0] == 1) begin // Check LSB of A
                o = o + shiftedB; // Add partial product
            end
            tempA = tempA >> 1;      // Right shift A (divide by 2)
            shiftedB = shiftedB << 1; // Left shift B (multiply by 2)
        end
    end
endmodule

module tb_shiftAddMultiplier();
    reg [3:0] a;
    reg [3:0] b;
    wire [7:0] o;
    
    // Instantiate the multiplier module
    shiftAddMultiplier uut (a, b, o);

    initial begin
        $monitor("Time=%0t | a = %b (%d), b = %b (%d), o = %b (%d)", 
                 $time, a, a, b, b, o, o);
        
        // Test Cases
        a = 4'b1011; b = 4'b1100; #10; // 11 * 12 = 132
        a = 4'b1111; b = 4'b1111; #10; // 15 * 15 = 225
        a = 4'b1010; b = 4'b1010; #10; // 10 * 10 = 100
        a = 4'b0101; b = 4'b0011; #10; // 5 * 3 = 15
        a = 4'b0111; b = 4'b0001; #10; // 7 * 1 = 7
        a = 4'b0000; b = 4'b0110; #10; // 0 * 6 = 0
        a = 4'b0110; b = 4'b0000; #10; // 6 * 0 = 0

        $finish;
    end
endmodule
