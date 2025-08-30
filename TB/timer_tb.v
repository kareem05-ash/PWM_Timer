//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module timer_tb();
    // DUT Inputs
        reg chosen_clk;                                     // active-high clk signal. chosen_clk = ctrl[0]? i_ext_clk : i_wb_clk;
        reg rst;                                            // i_wb_rst: async. active-high reset signal
        reg timer_en;                                       // ~ctrl[1] & ctrl[2]. mode-bit & main_counter enable-bit
        reg [15:0] period_reg;                              // period register 
        wire [15:0] counter;                                // main counter from main_counter mocule
    // DUT Outputs
        wire timer;                                         // interrupt output to be passed through o_pwm
        wire irq_flag;                                      // to be passed to ctrl[5]
    // Internal Signals
        reg timer_mode;                                     // if(0): one-shot, elif(1) count
        reg counter_en;
    // DUT Instantiation
        timer DUT(
            // Inputs
                .chosen_clk(chosen_clk), 
                .rst(rst), 
                .timer_en(timer_en), 
                .counter(counter), 
                .period_reg(period_reg), 
            // Outputs
                .timer(timer), 
                .irq_flag(irq_flag)
        );
    // main_counter Instantiation
        main_counter mc(
            .slow_clk(chosen_clk),
            .rst(rst), 
            .sw_rst(1'b0), 
            .irq_rst(1'b1), 
            .counter_en(counter_en), 
            .mode(1'b0),        // timer mode
            .timer_mode(timer_mode), 
            .period_reg(period_reg), 
            .counter(counter)
        );
    // chosen_clk Generation
        initial begin
            chosen_clk = 0; 
            forever #10 chosen_clk = ~chosen_clk;
        end
    // TASKs
        // reset task
            task reset(); begin
                rst = 1;                // apply rst
                timer_en = 0;           // default value
                period_reg = 0;         // default value
                timer_mode = 1;         // default value: cont. mode
                @(negedge chosen_clk);  // waits for a clk cycle to capture data
                rst = 0;                // release rst
            end
            endtask
        // assert_timer task
            task assert_timer(input[15:0] period, input mode); begin
                period_reg = period;    // assign period register
                @(posedge chosen_clk);  // waits to synchronize preiod_reg
                counter_en = 1;
                timer_en = 1;           // enables the core
                timer_mode = mode;      // set timer mode
                @(negedge chosen_clk);  // waits for a clk cycle to capture data
                repeat(period+1) begin
                    if(!timer & !irq_flag)  $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd0, counter);
                    else                    $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd0, counter);
                    @(negedge chosen_clk);
                end
                if(timer & irq_flag)        $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd1, irq_flag, 1'd1, counter);
                else                        $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd1, irq_flag, 1'd1, counter);
                @(negedge chosen_clk);
                if(!timer & irq_flag)       $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd1, counter);
                else                        $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd1, counter);      
            end
            endtask
    // Stimulus
        initial begin
            // 1st scenario Functional Correctness (RESET behavior)
                $display("==================== 1st scenario Functional Correctness (RESET behavior) ====================");
                reset();
                if(!timer & !irq_flag)      $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d", timer, 1'd0, irq_flag, 1'd0);
                else                        $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d", timer, 1'd0, irq_flag, 1'd0);
            // 2nd scenario Functional Correctness (cont. mode, period = 4)
                $display("==================== 2nd scenario Functional Correctness (cont. mode, period = 4) ====================");
                reset();
                period_reg = 16'd4;    // assign period register
                @(posedge chosen_clk);  // waits to synchronize preiod_reg
                counter_en = 1;
                timer_en = 1;           // enables the core
                timer_mode = 1'd1;      // set timer mode
                @(negedge chosen_clk);
                @(negedge chosen_clk);  // waits for a clk cycle to capture data
                repeat(period_reg+1) begin
                    if(!timer & !irq_flag)  $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd0, counter);
                    else                    $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd0, counter);
                    @(negedge chosen_clk);
                end
                if(timer & irq_flag)        $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd1, irq_flag, 1'd1, counter);
                else                        $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd1, irq_flag, 1'd1, counter);
                @(negedge chosen_clk);
                if(!timer & irq_flag)       $display("[PASS] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd1, counter);
                else                        $display("[FAIL] | timer = %d, expected = %d, irq_flag = %d, expected = %d, counter = %d", timer, 1'd0, irq_flag, 1'd1, counter); 
            // 3rd scenario Functional Correctness (one-shot mode, period = 4)
                $display("==================== 3rd scenario Functional Correctness (one-shot mode, period = 4) ====================");
                reset();
                assert_timer(16'd4, 1'd0);
            // 4th scenario Corner Case (cont. mode, period = 1)
                $display("==================== 4th scenario Corner Case (cont. mode, period = 1) ====================");
                reset();
                assert_timer(16'd1, 1'd1);
            // 5th scenario Corner Case (one-shot mode, period = 1)
                $display("==================== 5th scenario Corner Case (one-shot mode, period = 1) ====================");
                reset();
                assert_timer(16'd1, 1'd0);
            // STOP Simulation
                $display("==================== STOP Simulation ====================");
                #100;
                $stop;
        end 
    // Monitor
        // initial begin
        //     $monitor("timer = %d, irq_flag = %d, counter = %d, period_reg = %d", timer, irq_flag, counter, period_reg);
        // end
endmodule