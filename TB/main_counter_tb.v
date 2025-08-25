//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module main_counter_tb();
    // DUT Inputs
        reg slow_clk;                               // +ve edge slow clk from clk_divider module
        reg rst;                                    // async +ve edge system rst (i_wb_rst)
        reg sw_rst;                                 // sync software rst signal: active-high level trig
        reg irq_rst;                                // interrupt request rst
        reg counter_en;                             // ctrl[2]
        reg mode;                                   // ctrl[1]? pwm : timer mode
        reg timer_mode;                             // ctrl[3]? cont : one-shot
        reg [15:0] period_reg;                      // period register from register file
    // DUT Outputs
        wire [15:0] counter;                        // main counter (feeds pwm and timer cores)
    // Internal Signals 
        reg [15:0] count;
    // DUT Instantiation
        main_counter DUT(
            // Inputs
                .slow_clk(slow_clk), 
                .rst(rst), 
                .sw_rst(sw_rst), 
                .irq_rst(irq_rst),
                .counter_en(counter_en), 
                .mode(mode), 
                .timer_mode(timer_mode), 
                .period_reg(period_reg), 
            // Outputs
                .counter(counter)
        );
    // slow_clk Generation
        initial begin
            slow_clk = 0;
            forever #10 slow_clk = ~slow_clk;
        end
    // TASKs
        // reset task
            task reset(); begin
                rst = 1;                // apply system rst
                sw_rst = 0;             // default value
                irq_rst = 0;            // default value
                counter_en = 0;         // default value
                mode = 0;               // default value
                timer_mode = 0;         // default value
                period_reg = 0;         // default value
                @(negedge slow_clk);    // waits for 1 slow_clk cycle to track rst signal
                rst = 0;                // release rst
            end
            endtask
        // pwm task (assert pwm 2 full counting cycles)
            task pwm(input [15:0] period); begin
                repeat(2) begin
                    count = 0;
                    repeat(period) begin
                        if(counter != count)    $display("[FAIL] | counter = %d, expected = %d", counter, count);
                        else                    $display("[PASS] | counter = %d, expected = %d", counter, count);
                        count = count + 1;              // increment count
                        @(negedge slow_clk);            // waits to increment
                    end
                end
            end
            endtask
        // timer_cont task (assert timer 2 full counting cycles)
            task timer_cont(input [15:0] period); begin
                repeat(2) begin
                    count = 0;
                    repeat(period+1) begin
                        if(counter != count)    $display("[FAIL] | counter = %d, expected = %d", counter, count);
                        else                    $display("[PASS] | counter = %d, expected = %d", counter, count);
                        count = count + 1;              // increment count
                        @(negedge slow_clk);            // waits to increment
                    end
                end
            end
            endtask
        // timer_one_shot task (assert timer full counting cylce)
            task timer_one_shot(input [15:0] period); begin
                count = 0;
                repeat(period+1) begin
                    if(counter != count)    $display("[FAIL] | counter = %d, expected = %d", counter, count);
                    else                    $display("[PASS] | counter = %d, expected = %d", counter, count);
                    count = count + 1;              // increment count
                    @(negedge slow_clk);            // waits to increment
                end
                repeat(period+1) begin
                    if(counter != 0)        $display("[FAIL] | counter = %d, expected = %d", counter, 16'd0);
                    else                    $display("[PASS] | counter = %d, expected = %d", counter, 16'd0);
                    @(negedge slow_clk);
                end
            end
            endtask
    // Stimulus
        initial begin
            // 1st scenario Functional Correctness (RESET Behavior)
                $display("==================== 1st scenario Functional Correctness (RESET Behavior) ====================");
                reset();
                if(counter == 16'b0) begin
                    $display("[PASS] | counter = %d, expected = %d", counter, 16'b0);
                end else begin
                    $display("[FAIL] | counter = %d, expected = %d", counter, 16'b0);
                end
            // 2nd scenario Functional Correctness (PWM mode full counting with period = 4)
                $display("==================== 2nd scenario Functional Correctness (PWM mode full counting with period = 4) ====================");
                reset();
                counter_en = 1;         // enable counting
                mode = 1;               // pwm mode
                period_reg = 4;         // set preiod = 4 slow_clk cycles
                pwm(period_reg);
            // 3rd scenario Functional Correctness (Timer mode full counting [continous] with period = 4)
                $display("==================== 3rd scenario Functional Correctness (Timer mode full counting [continous] with period = 4) ====================");
                reset();
                counter_en = 1;         // enable counting
                mode = 0;               // timer mode
                timer_mode = 1;         // continous  
                period_reg = 4;         // set preiod = 4 slow_clk cycles
                @(negedge slow_clk);
                timer_cont(period_reg);
            // 4th scenario Functional Correctness (Timer mode full counting [one-shot] with period = 4)
                $display("==================== 4th scenario Functional Correctness (Timer mode full counting [one-shot] with period = 4) ====================");
                reset();
                counter_en = 1;         // enable counting
                mode = 0;               // timer mode
                timer_mode = 0;         // one-shot
                period_reg = 4;         // set preiod = 4 slow_clk cycles
                @(negedge slow_clk);
                timer_one_shot(period_reg);
            // 5th scenario Corner Case (RESET during counting)
                $display("==================== 5th scenario Corner Case (RESET during counting) ====================");
                reset();
                counter_en = 1;         // enable counting
                mode = 1;               // pwm mode
                period_reg = 10;        // set preiod = 10 slow_clk cycles
                repeat(period_reg/2) @(negedge slow_clk);
                reset();
                if(counter == 16'b0) begin
                    $display("[PASS] | counter = %d, expected = %d", counter, 16'b0);
                end else begin
                    $display("[FAIL] | counter = %d, expected = %d", counter, 16'b0);
                end
            // 6th scenario Corner Case (Disable the counter while counting)
                $display("==================== 6th scenario Corner Case (Disable the counter while counting) ====================");
                reset();
                counter_en = 1;         // enable counting
                mode = 1;               // pwm mode
                period_reg = 10;        // set preiod = 10 slow_clk cycles
                repeat(period_reg/2) @(negedge slow_clk);
                counter_en = 0;         // disable counting
                repeat(5) begin
                    @(negedge slow_clk);
                    if(counter != 5)    $display("[FAIL] | counter = %d, expected = %d", counter, 16'd5);
                    else                $display("[PASS] | counter = %d, expected = %d", counter, 16'd5);
                end
            // STOP Simulation
                $display("==================== STOP Simulation ====================");
                #100;
                $stop;
        end 
endmodule