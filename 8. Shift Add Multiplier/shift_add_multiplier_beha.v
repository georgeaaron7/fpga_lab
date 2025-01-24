module full_adder (
    input A, B, Cin,
    output Sum, Cout );
    assign {Cout, Sum} = A + B + Cin;
endmodule

module multiplier (
    input [3:0] A, B,
    output [7:0] P);
      wire [3:0] pp0, pp1, pp2, pp3;
      wire [3:0] sum1, sum2, sum3;
      wire c1, c2, c3, c4;
      wire [4:0] temp1, temp2, temp3, temp4;
      assign pp0 = A[0] ? B : 4'b0000;
      assign pp1 = A[1] ? B : 4'b0000;
      assign pp2 = A[2] ? B : 4'b0000;
      assign pp3 = A[3] ? B : 4'b0000;   
      assign temp1 = {1'b0, pp0};
      assign temp2 = {pp1, 1'b0};
      assign temp3 = {pp2, 2'b0};
      assign temp4 = {pp3, 3'b0};  
      full_adder fa1_0(temp1[0], temp2[0], 1'b0, sum1[0], c1);
      full_adder fa1_1(temp1[1], temp2[1], c1, sum1[1], c2);
      full_adder fa1_2(temp1[2], temp2[2], c2, sum1[2], c3);
      full_adder fa1_3(temp1[3], temp2[3], c3, sum1[3], c4); 
      full_adder fa2_0(sum1[0], temp3[0], 1'b0, sum2[0], c1);
      full_adder fa2_1(sum1[1], temp3[1], c1, sum2[1], c2);
      full_adder fa2_2(sum1[2], temp3[2], c2, sum2[2], c3);
      full_adder fa2_3(sum1[3], temp3[3], c3, sum2[3], c4);
      full_adder fa3_0(sum2[0], temp4[0], 1'b0, sum3[0], c1);
      full_adder fa3_1(sum2[1], temp4[1], c1, sum3[1], c2);
      full_adder fa3_2(sum2[2], temp4[2], c2, sum3[2], c3);
      full_adder fa3_3(sum2[3], temp4[3], c3, sum3[3], c4);
      assign P = {c1, c2, c3, sum3};
endmodule
