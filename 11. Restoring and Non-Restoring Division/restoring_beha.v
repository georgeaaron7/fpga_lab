module restoring_division (
    input [1:0] dividend,
    input [1:0] divisor,
    output reg [1:0] quotient,
    output reg [1:0] remainder
);
    reg [3:0] A;  // Accumulator
    reg [1:0] Q;  // Quotient
    reg [1:0] M;  // Divisor
    reg [1:0] count;

    always @(*) begin
        if (divisor == 2'b00) begin
            // Handle division by zero
            quotient = 2'b00;
            remainder = dividend;
        end else begin
            A = 4'b0000;     // Initialize accumulator to 0
            Q = dividend;    // Initialize quotient with dividend
            M = divisor;     // Initialize divisor
            count = 2'b10;   // We need 2 iterations for 2-bit numbers

            while (count > 0) begin
                // Left shift A and Q
                A = {A[2:0], Q[1]};
                Q = {Q[0], 1'b0};

                // Subtract M from A
                A = A - {2'b00, M};

                // Check if A is negative
                if (A[3] == 1) begin
                    // Restore A and set Q0 to 0
                    A = A + {2'b00, M};
                    Q[0] = 0;
                end else begin
                    // Set Q0 to 1
                    Q[0] = 1;
                end

                count = count - 1;
            end

            quotient = Q;
            remainder = A[1:0];
        end
    end
endmodule

`timescale 1ns / 1ps

module tb_restoring_division;
    reg [1:0] dividend;
    reg [1:0] divisor;
    wire [1:0] quotient;
    wire [1:0] remainder;

    // Instantiate the restoring division module
    restoring_division uut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    initial begin
        // Initialize inputs
        dividend = 2'b00;
        divisor = 2'b00;
        #10;

        // Test cases
        // Test case 1: 0 / 0
        dividend = 2'b00;
        divisor = 2'b00;
        #10;
        $display("Test case 1: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 2: 3 / 1
        dividend = 2'b11;
        divisor = 2'b01;
        #10;
        $display("Test case 2: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 3: 2 / 2
        dividend = 2'b10;
        divisor = 2'b10;
        #10;
        $display("Test case 3: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 4: 3 / 2
        dividend = 2'b11;
        divisor = 2'b10;
        #10;
        $display("Test case 4: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 5: 3 / 3
        dividend = 2'b11;
        divisor = 2'b11;
        #10;
        $display("Test case 5: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 6: 2 / 1
        dividend = 2'b10;
        divisor = 2'b01;
        #10;
        $display("Test case 6: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        // Test case 7: 1 / 2
        dividend = 2'b01;
        divisor = 2'b10;
        #10;
        $display("Test case 7: %b / %b = %b remainder %b", dividend, divisor, quotient, remainder);

        $finish;
    end
endmodule
