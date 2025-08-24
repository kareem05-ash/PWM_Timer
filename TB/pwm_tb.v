//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module pwm_tb();
    // DUT Inputs 
        reg chosen_clk;                                     // active-high clk signal. chosen_clk = ctrl[0]? i_ext_clk : i_wb_clk;
        reg rst;                                            // i_wb_rst: async. active-high reset signal
        reg pwm_en;                                         // pwm_en = ctrl[1] & ctrl[2]. mode-bit, counter_en-bit
        reg DC_sel;                                         // DC = ctrl[6]? i_DC : DC_reg
        reg [15:0] i_DC;                                    // external duty cycle
        reg [15:0] period_reg;                              // period register
        reg [15:0] DC_reg;                                  // duty cycle register
        wire [15:0] counter;                                // main counter
    // DUT Outputs
        wire pwm;                                           // pwm output
    // Internal Signals
        reg slow_clk;
    // Local Parameters
        localparam chosen_clk_period = 10, 
                   slow_clk_period = 20;
    // DUT Instantiation
        pwm DUT(
            .chosen_clk(chosen_clk), 
            .rst(rst), 
            .pwm_en(pwm_en), 
            .DC_sel(DC_sel), 
            .i_DC(i_DC), 
            .counter(counter), 
            .period_reg(period_reg), 
            .DC_reg(DC_reg),
            .pwm(pwm)
        );
    // main_counter Instantiation
        main_counter mc(
            .slow_clk(slow_clk), 
            .rst(rst), 
            .sw_rst(1'b0), 
            .counter_en(1'b1),
            .mode(1'b1),            // pwm mode
            .timer_mode(1'b0),      // it doesn't matter as we in pwm mode
            .period_reg(period_reg), 
            .counter(counter)
        );
    // chosen_clk Genreation
        initial begin
            chosen_clk = 0;
            forever #(chosen_clk_period) chosen_clk = ~chosen_clk;
        end

    // slow_clk Generation
        initial begin
            slow_clk =1;
            forever #(slow_clk_period) slow_clk = ~slow_clk;
        end

    // TASKs
        // reset task
            task reset(); begin
                rst = 1;            // apply rst
                pwm_en = 0;         // default value
                DC_sel = 0;         // default value
                i_DC = 0;           // default value
                period_reg = 0;     // default value
                DC_reg = 0;         // default value
                @(negedge chosen_clk);
                rst = 0;            // release rst
            end
            endtask
        // assert_pwm task
            task assert_pwm(input [15:0] period, DC); begin
                repeat(period)  @(negedge slow_clk);
                if(DC > period) begin 
                    repeat(period * 2) begin
                        #(chosen_clk_period + 1);
                        if(pwm == chosen_clk)   $display("[PASS] | pwm = %d, expected = %d", pwm, chosen_clk);
                        else                    $display("[FAIL] | pwm = %d, expected = %d", pwm, chosen_clk);
                    end
                end else begin
                    repeat(DC) begin
                        @(negedge slow_clk);
                        if(pwm == 1)            $display("[PASS] | pwm = %d, expected = %d, counter = %d", pwm, 1'd1, counter);
                        else                    $display("[FAIL] | pwm = %d, expected = %d, counter = %d", pwm, 1'd1, counter);
                    end
                    repeat(period - DC) begin
                        @(negedge slow_clk);
                        if(pwm == 0)            $display("[PASS] | pwm = %d, expected = %d, counter = %d", pwm, 1'd0, counter);
                        else                    $display("[FAIL] | pwm = %d, expected = %d, counter = %d", pwm, 1'd0, counter);
                    end
                end
            end
            endtask
    // Stimulus
        initial begin
            // 1st scenario Functional Correctness (RESET Behavior)
                $display("==================== 1st scenario Functional Correctness (RESET Behavior) ====================");
                reset();
                if(!pwm) begin
                    $display("[PASS] | pwm = %d, expected = %d, counter = %d", pwm, 1'b0, counter);
                end else begin
                    $display("[FAIL] | pwm = %d, expected = %d, counter = %d", pwm, 1'b0, counter);
                end
            // 2nd scenario Functional Correctness (DC_reg = 50 percent)
                $display("==================== 2nd scenario Functional Correctness (DC_reg = 50 percent) ====================");
                reset();
                pwm_en = 1; DC_sel = 0; i_DC = 0;   period_reg = 6; DC_reg = 3; 
                assert_pwm(period_reg, DC_reg);
            // 3rd scenario Functional Correctness (DC_reg = 25 percent)
                $display("==================== 3rd scenario Functional Correctness (DC_reg = 25 percent) ====================");
                reset();
                pwm_en = 1; DC_sel = 0; i_DC = 0;   period_reg = 4; DC_reg = 1; 
                assert_pwm(period_reg, DC_reg);
            // 4th scenario Functional Correctness (DC_reg = 75 percent)
                $display("==================== 4th scenario Functional Correctness (DC_reg = 75 percent) ====================");
                reset();
                pwm_en = 1; DC_sel = 0; i_DC = 0;   period_reg = 4; DC_reg = 3; 
                assert_pwm(period_reg, DC_reg);
            // 5th scenario Corner Case ([DC=4] > [period=3])
                $display("==================== 5th scenario Corner Case ([DC=4] > [period=3]) ====================");
                reset();
                pwm_en = 1; DC_sel = 0; i_DC = 0;   period_reg = 3; DC_reg = 4; 
                assert_pwm(period_reg, DC_reg);
            // 6th scenario Corner Case (choose external [i_DC=3] > [period=2])
                $display("==================== 6th scenario Corner Case (choose external [i_DC=3] > [period=2]) ====================");
                reset();
                pwm_en = 1; DC_sel = 1; i_DC = 0;   period_reg = 2; i_DC = 3; 
                assert_pwm(period_reg, i_DC);
            // STOP Simulation
                $display("==================== STOP Simulation ====================");
                #100;
                $stop;
        end
endmodule