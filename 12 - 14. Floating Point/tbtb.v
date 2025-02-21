        // Test Vector 1: 3.5 and 2.0 (Addition)
        // 3.5 = 0 10000000 11000000000000000000000 (binary representation)
        // 2.0 = 0 10000000 00000000000000000000000 (binary representation)
        A = 32'b0_10000000_11000000000000000000000;
        B = 32'b0_10000000_00000000000000000000000;
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
        // 10.0 = 0 10000010 01000000000000000000000 (binary representation)
        // 5.0  = 0 10000001 01000000000000000000000 (binary representation)
        A = 32'b0_10000010_01000000000000000000000;
        B = 32'b0_10000001_01000000000000000000000;
        op = 2'b10;  // multiplication
        #20;
        $display("Multiplication: 10.0 * 5.0");
        display_fp(result);
        
        // Test Vector 4: 10.0 and 5.0 (Division)
        op = 2'b11;  // division (10.0 / 5.0)
        #20;
        $display("Division: 10.0 / 5.0");
        display_fp(result);
        
        $finish;
