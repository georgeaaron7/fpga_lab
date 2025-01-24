`timescale 1ns / 1ps
module sequence_1011_generator(
    input clk,           
    input reset,         
    output reg data_out  
);
    reg [2:0] state; 

   
    parameter S0 = 3'b000; 
    parameter S1 = 3'b001; 
    parameter S2 = 3'b010; 
    parameter S3 = 3'b011; 

    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0; 
        else begin
            case (state)
                S0: state <= S1;
                S1: state <= S2;
                S2: state <= S3;
                S3: state <= S0; 
                default: state <= S0; 
            endcase
        end
    end

    
    always @(*) begin
        case (state)
            S0: data_out = 1'b1; 
            S1: data_out = 1'b0; 
            S2: data_out = 1'b1; 
            S3: data_out = 1'b1; 
            default: data_out = 1'b0; 
        endcase
    end
endmodule


module tb_sequence_generator_1011;
    reg clk;
    reg reset;
    wire data_out;
    sequence_1011_generator uut (
        .clk(clk),
        .reset(reset),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        reset = 1; #10 
        reset = 0; #100 
        $finish(); 
    end
endmodule
