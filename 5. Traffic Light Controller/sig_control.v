`define TRUE 1'b1
`define FALSE 1'b0

//Delays
`define Y2RDELAY 3 //Yellow to red delay
`define R2GDELAY 2 //Red to green delay

module sig_control
      (hwy, cntry, X, clock, clear);
      
    //I/O ports
    output [1:0] hwy, cntry;
    //GREEN, YELLOW, RED;
    reg [1:0] hwy, cntry;
    //declared output signals are registers
    
    input X;
    //if TRUE, indicates that there is car on
    //the country road, otherwise FALSE
    
    input clock, clear;
    
    parameter RED = 2'd0,
              YELLOW = 2'd1,
              GREEN = 2'd2;
    
    //state definition      HWY      CNTRY
    parameter S0 = 3'd0;   //GREEN    RED
    parameter S1 = 3'd1;   //YELLOW   RED
    parameter S2 = 3'd2;   //RED      RED
    parameter S3 = 3'd3;   //RED      GREEN
    parameter S4 = 3'd4;   //RED      YELLOW
    
    //Internal state variables
    reg [2:0] state;
    reg [2:0] next_state;
    
    // Timer for delays
    reg [2:0] delay_count;
    reg in_delay;
    
    // Initialize state variables
    initial begin
        state = S0;
        next_state = S0;
        hwy = GREEN;
        cntry = RED;
        delay_count = 0;
        in_delay = 0;
    end
    
    //state changes only at positive edge of clock
    always @(posedge clock)
      if (clear)
        state <= S0; //Controller starts in S0 state
      else
        state <= next_state; //State change
    
    //Compute values of main signal and country signal
    always @(state)
    begin
      hwy = GREEN; //Default Light Assignment for Highway light
      cntry = RED; //Default Light Assignment for Country light
      case(state)
        S0: ; // No change, use default
        S1: hwy = YELLOW;
        S2: hwy = RED;
        S3: begin
            hwy = RED; 
            cntry = GREEN;
        end
        S4: begin
            hwy = RED; 
            cntry = YELLOW;
        end
        default: begin
            hwy = GREEN;
            cntry = RED;
        end
      endcase
    end

    // Delay counter logic
    always @(posedge clock) begin
        if (clear) begin
            delay_count <= 0;
            in_delay <= 0;
        end
        else if (in_delay) begin
            if (delay_count == 0)
                in_delay <= 0;
            else
                delay_count <= delay_count - 1;
        end
    end

    // State transition logic (combinational, no procedural statements)
    always @(state or X or in_delay or delay_count)
    begin
        case (state)
            S0: begin
                if(X && !in_delay)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (!in_delay) begin
                    in_delay = 1;
                    delay_count = `Y2RDELAY;
                    next_state = S1;
                end
                else if (delay_count == 0)
                    next_state = S2;
                else
                    next_state = S1;
            end
            S2: begin
                if (!in_delay) begin
                    in_delay = 1;
                    delay_count = `R2GDELAY;
                    next_state = S2;
                end
                else if (delay_count == 0)
                    next_state = S3;
                else
                    next_state = S2;
            end
            S3: begin
                if(X)
                    next_state = S3;
                else
                    next_state = S4;
            end
            S4: begin
                if (!in_delay) begin
                    in_delay = 1;
                    delay_count = `Y2RDELAY;
                    next_state = S4;
                end
                else if (delay_count == 0)
                    next_state = S0;
                else
                    next_state = S4;
            end
            default: next_state = S0;
        endcase
    end
endmodule

//Stimulus Module
module stimulus;
    
    wire [1:0] MAIN_SIG, CNTRY_SIG;
    reg CAR_ON_CNTRY_RD;
    //if TRUE, indicates that there is a car on
    //the country road
    
    reg CLOCK, CLEAR;
    
    //Instantiate signal controller
    sig_control SC(MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD, CLOCK, CLEAR);
    
    //Set up monitor
    initial
    $monitor($time, " Main Sig = %b Country Sig = %b Car_on_cntry = %b",
    MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
    
    //Set up clock
    initial
    begin
        CLOCK = `FALSE;
        forever #5 CLOCK = ~CLOCK;
    end
    
    //control clear signal
    initial
    begin
        CLEAR = `TRUE;
        repeat (5) @(negedge CLOCK);
        CLEAR = `FALSE;
    end
    
    //apply stimulus
    initial
    begin
        CAR_ON_CNTRY_RD = `FALSE;
        repeat(20) @(negedge CLOCK); CAR_ON_CNTRY_RD = `TRUE;
        repeat(10) @(negedge CLOCK); CAR_ON_CNTRY_RD = `FALSE;
        
        repeat(20) @(negedge CLOCK); CAR_ON_CNTRY_RD = `TRUE;
        repeat(10) @(negedge CLOCK); CAR_ON_CNTRY_RD = `FALSE;
        
        repeat(20) @(negedge CLOCK); CAR_ON_CNTRY_RD = `TRUE;
        repeat(10) @(negedge CLOCK); CAR_ON_CNTRY_RD = `FALSE;
        
        repeat(10) @(negedge CLOCK); $stop;
    end
endmodule
