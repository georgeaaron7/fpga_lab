`timescale 1ns / 1ps

module multiplier(
    input [3:0] x,y,
    output [7:0] z 
    );
    wire [3:0] carry1, sum1;
    wire [3:0] carry2, sum2;
    wire [3:0] carry3, sum3;
    
    ha h1_1( (y[0] & x[1]) , (y[1] & x[0]), sum1[0], carry1[0]);
    fa f1_1( (y[0] & x[2]) , (y[1] & x[1]), carry1[0], sum1[1], carry1[1]);
    fa f2_1( (y[0] & x[3]) , (y[1] & x[2]), carry1[1], sum1[2], carry1[2]);
    ha h2_1( (y[1] & x[3]) , carry1[2], sum1[3], carry1[3]);
    
    ha h1_2 (sum1[1], (y[2] & x[0]), sum2[0], carry2[0] ) ;
    fa f1_2 (sum1[2], (y[2] & x[1]), carry2[0], sum2[1], carry2[1]);
    fa f2_2 (sum1[3], (y[2] & x[2]), carry2[1], sum2[2], carry2[2]);
    fa f3_2 (carry1[3], (y[2] & x[3]), carry2[2], sum2[3], carry2[3]);
    
    ha h1_3 (sum2[1], (y[3] & x[0]), sum3[0], carry3[0] ) ;
    fa f1_3 (sum2[2], (y[3] & x[1]), carry3[0], sum3[1], carry3[1]);
    fa f2_3 (sum2[3], (y[3] & x[2]), carry3[1], sum3[2], carry3[2]);
    fa f3_3 (carry2[3], (y[3] & x[3]), carry3[2], sum3[3], carry3[3]);
    
    assign z[0] = x[0] & y[0];
    assign z[1] = sum1[0];
    assign z[2] = sum2[0];
    assign z[3] = sum3[0];
    assign z[4] = sum3[1];
    assign z[5] = sum3[2];
    assign z[6] = sum3[3];
    assign z[7] = carry3[3];
    
endmodule

module fa(
    input a, b, cin,
    output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = ((a & b) | (b & cin) | (a & cin));
endmodule 

module ha(
    input a, b,
    output sum, carry);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule


module multiplier_tb;
    reg [3:0] x, y;
    wire [7:0] z;
    multiplier uut (x,y,z);
    initial begin
    x = 4'b0011; y = 4'b0011; #10
    x = 4'b0110; y = 4'b0010; #10
    x = 4'b0101; y = 4'b0101; #10
    x = 4'b0101; y = 4'b0110; #10
    x = 4'b0110; y = 4'b0110; #10
    x = 4'b1111; y = 4'b1111; #10
    x = 4'b0111; y = 4'b0111; #10
    $finish();
    end
endmodule
