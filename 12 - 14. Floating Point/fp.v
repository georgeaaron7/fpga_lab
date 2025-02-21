// fp_alu.v
// Single-precision (32-bit) floating-point ALU which performs addition, subtraction,
// multiplication, and division based on a 2-bit op-code.
// op-code details:
//    00 => addition
//    01 => subtraction
//    10 => multiplication
//    11 => division
//
// This simplified, behavioral implementation extracts the sign, exponent, and mantissa,
// performs the operation on the decomposed fields, normalizes the result, and then reassembles
// the IEEE-754 32-bit floating-point result.
// Note: This model assumes normalized inputs and does not handle special cases (NaN, Inf, denormals).

`timescale 1ns/1ps

module fp_adder_subtractor(
    input  [31:0] A,
    input  [31:0] B,
    input  [1:0]  op,     // 00: add, 01: sub, 10: mul, 11: div
    output reg [31:0] Out
);
    // Common variables for all operations
    reg        signA, signB, resSign;
    reg [7:0]  expA, expB, expRes;
    reg [23:0] manA, manB; // 24 bits: implicit '1' if normalized.
    
    // Variables for addition/subtraction
    reg [24:0] alignedA, alignedB;
    reg [24:0] sumMan;
    
    // Variables for multiplication
    reg [47:0] multRes;
    reg [23:0] normMan;
    
    // Variables for division
    reg [47:0] dividend;
    reg [23:0] quotientMan;
    integer i;
    
    always @(*) begin
        case(op)
            // Addition (00) and Subtraction (01)
            2'b00, 2'b01: begin
                // Extract fields from A
                signA = A[31];
                expA  = A[30:23];
                // If normalized, prepend implicit 1; otherwise use fraction as is.
                manA  = (expA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
                
                // Extract fields from B
                signB = B[31];
                // For subtraction, invert B's sign.
                if(op == 2'b01)
                    signB = ~signB;
                expB  = B[30:23];
                manB  = (expB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};
                
                // Align exponents by shifting the mantissa of the operand with the smaller exponent.
                if(expA >= expB) begin
                    expRes    = expA;
                    alignedA  = {1'b0, manA};
                    alignedB  = {1'b0, manB} >> (expA - expB);
                end else begin
                    expRes    = expB;
                    alignedA  = {1'b0, manA} >> (expB - expA);
                    alignedB  = {1'b0, manB};
                end
                
                // Perform addition if signs are the same; otherwise do subtraction.
                if(signA == signB) begin
                    sumMan   = alignedA + alignedB;
                    resSign  = signA;
                end else begin
                    if(alignedA >= alignedB) begin
                        sumMan  = alignedA - alignedB;
                        resSign = signA;
                    end else begin
                        sumMan  = alignedB - alignedA;
                        resSign = signB;
                    end
                end
                
                // Normalize the result:
                if(sumMan == 0) begin
                    Out = 32'b0;
                end
                else begin
                    // If there's an extra carry bit, shift right & increment exponent.
                    if(sumMan[24] == 1'b1) begin
                        sumMan  = sumMan >> 1;
                        expRes  = expRes + 1;
                    end else begin
                        // Shift left until the MSB (bit 23) is 1 (normalize) or exponent reduces.
                        while(sumMan[23] == 1'b0 && expRes > 0) begin
                            sumMan = sumMan << 1;
                            expRes = expRes - 1;
                        end
                    end
                    Out = {resSign, expRes, sumMan[22:0]};
                end
            end

            // Multiplication (10)
            2'b10: begin
                // Extract A's fields
                signA = A[31];
                expA  = A[30:23];
                manA  = (expA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
                
                // Extract B's fields
                signB = B[31];
                expB  = B[30:23];
                manB  = (expB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};
                
                // Determine the result sign as XOR of input signs.
                resSign = signA ^ signB;
                // Calculate new exponent with bias adjustment.
                expRes = expA + expB - 8'd127;
                
                // Multiply the 24-bit mantissas.
                multRes = manA * manB;
                
                // Normalize the product.
                if(multRes[47] == 1'b1) begin
                    normMan = multRes[46:23];
                    expRes  = expRes + 1;
                end else begin
                    normMan = multRes[45:22];
                end
                
                Out = {resSign, expRes, normMan[22:0]};
            end

            // Division (11)
            2'b11: begin
                // Extract A's fields
                signA = A[31];
                expA  = A[30:23];
                manA  = (expA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
                
                // Extract B's fields
                signB = B[31];
                expB  = B[30:23];
                manB  = (expB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};
                
                // Result sign is XOR of inputs.
                resSign = signA ^ signB;
                // Adjust exponent: subtract B's exponent from A's and add the bias.
                expRes = expA - expB + 8'd127;
                
                // Prepare dividend with extra precision.
                dividend = {manA, 23'b0};
                quotientMan = 0;
                // Simple restoring division algorithm for 24-bit quotient.
                for(i = 0; i < 24; i = i + 1) begin
                    dividend = dividend << 1;
                    quotientMan = quotientMan << 1;
                    if(dividend[47:24] >= manB) begin
                        dividend[47:24] = dividend[47:24] - manB;
                        quotientMan[0] = 1'b1;
                    end
                end
                
                Out = {resSign, expRes, quotientMan[22:0]};
            end

            default: Out = 32'b0;
        endcase
    end
endmodule

// Testbench for the unified floating-point ALU.
module fp_alu_tb;
    reg  [31:0] A, B;
    reg  [1:0] op; // operation selector
    wire [31:0] result;
    
    fp_adder_subtractor uut(
        .A(A),
        .B(B),
        .op(op),
        .Out(result)
    );
    
    // Helper task to display a floating-point number's fields.
    task display_fp;
        input [31:0] num;
        begin
            $display("Sign = %b, Exp = %b, Frac = %b", num[31], num[30:23], num[22:0]);
        end
    endtask

    initial begin
        // Test Vector 1: 3.5 and 2.0 (Addition)
        // 3.5 = 0x40600000, 2.0 = 0x40000000 (IEEE-754)
        A = 32'h40600000;
        B = 32'h40000000;
        op = 2'b00;  // addition
        #20;
        $display("Addition: 3.5 + 2.0");
        display_fp(result);
        
        // Test Vector 2: 3.5 and 2.0 (Subtraction)
        op = 2'b01;  // subtraction (3.5 - 2.0)
        #20;
        $display("Subtraction: 3.5 - 2.0");
        display_fp(result);
        
        // Test Vector 3: 10.0 and 5.0 (Multiplication)
        // 10.0 = 0x41200000, 5.0 = 0x40A00000
        A = 32'h41200000;
        B = 32'h40A00000;
        op = 2'b10;  // multiplication
        #20;
        $display("Multiplication: 10.0 * 5.0");
        display_fp(result);
        
        // Test Vector 4: 10.0 and 5.0 (Division)
        $finish();
    end
endmodule
