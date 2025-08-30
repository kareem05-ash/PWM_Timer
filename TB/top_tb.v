//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module top_tb();
    // DUT Parameters
        parameter num_ch = 4;                                   // number of channels
        parameter mem_width = 16;                               // word width stored in register file
        parameter mem_depth = 4 * num_ch;                       // 4 entries (ctrl, period, divisor, DC) for each channel
        parameter adr_width = 16;                               // address width
    // DUT Inputs
        reg i_wb_clk;                                           // active-high wb clk signal
        reg i_wb_rst;                                           // async. active-high wb rst signal
        reg i_wb_cyc;                                           // indicates valid bus cycle
        reg i_wb_stb;                                           // indicates valid data
        reg i_wb_we;                                            // if set, write operation. if reset, read operation.
        reg [adr_width-1:0] i_wb_adr;                           // address to write on it or read from it
        reg [mem_width-1:0] i_wb_data;                          // input data to be written in register file
        reg [num_ch*mem_width-1 : 0] i_DC;                      // external duty cycle
        reg i_extclk;                                           // external active-high clk signal
        reg [num_ch-1:0] i_DC_valid;                            // indicats valid data on i_DC
    // DUT Outputs      
        wire [mem_width-1:0] o_wb_data;                         // output data read from register file
        wire o_wb_ack;                                          // acknowledgement: indicates valid termination
        wire [num_ch-1:0] o_pwm;                                // pulse width modulated output
    // Local Parameters
        localparam i_wb_clk_period = 20;                        // 50 MHZ frequency
        localparam i_extclk_period = 40;                        // 25 MHZ frequency
    // Internal Signals
        integer all;                                            // all test cases
        integer passed;                                         // passed test cases
        integer i;                                              // for loop counter
        reg [mem_width-1 : 0] data; 
        reg [2:0] DC, period;   
        reg timer_mode;      
        reg mode;   
        reg DC_sel;
        reg[1:0] ch;       
    // DUT Instantiation
        top #(.num_ch(num_ch), .mem_width(mem_width), .mem_depth(mem_depth), .adr_width(adr_width))
        DUT(
            // Inputs
                .i_wb_clk(i_wb_clk), 
                .i_wb_rst(i_wb_rst), 
                .i_wb_cyc(i_wb_cyc), 
                .i_wb_stb(i_wb_stb), 
                .i_wb_we(i_wb_we), 
                .i_wb_adr(i_wb_adr), 
                .i_wb_data(i_wb_data), 
                .i_DC(i_DC), 
                .i_extclk(i_extclk), 
                .i_DC_valid(i_DC_valid), 
            // Outputs
                .o_wb_data(o_wb_data), 
                .o_wb_ack(o_wb_ack), 
                .o_pwm(o_pwm)
        );
    // i_wb_clk Generation
        initial begin
            i_wb_clk = 0;
            forever #(i_wb_clk_period/2) i_wb_clk = ~i_wb_clk;
        end
    // i_extclk Generation
        initial begin
            i_extclk = 0;
            forever #(i_extclk_period/2) i_extclk = ~i_extclk;
        end
    // TASKs
        // reest task
            task reset(); begin
                i_wb_rst = 1;               // apply rst
                i_wb_cyc = 0;               // default value
                i_wb_stb = 0;               // default value
                i_wb_we = 0;                // default value
                i_wb_adr = 0;               // default value
                i_wb_data = 0;              // default value
                i_DC = 0;                   // default value
                i_DC_valid = 0;             // default value
                @(negedge i_extclk);        // waits for a clk cycle of the external clk to ensure all data assigned (e_extclk normally is slower)
                i_wb_rst = 0;               // release rst
            end
            endtask 
        // assign_data task
            task assign_data(input cyc, stb, we, i_dc_valid, input [mem_width-1 : 0] data, input [adr_width-1 : 0] adr, input [num_ch*mem_width-1 : 0] i_dc, input clk_sel); begin
                i_wb_cyc = cyc; i_wb_stb = stb; i_wb_we = we;   i_DC_valid = i_dc_valid;    i_wb_adr = adr;     i_wb_data = data;   i_DC = i_dc;
                if(clk_sel)     @(negedge i_extclk);
                else            @(negedge i_wb_clk);
            end
            endtask
        // assert_pwm task 
            task assert_pwm(input [mem_width-1 : 0] DC, period, input clk_sel, input [1:0] ch, input[mem_width-1:0] divisor); begin
                if(DC > period) begin
                    #1;
                    repeat(DC) begin
                        all = all + 1;
                        if(!clk_sel) begin
                            if(o_pwm[ch] == i_wb_clk) begin
                                passed = passed + 1;
                                $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], i_wb_clk);
                            end else begin
                                $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], i_wb_clk);
                            end
                            repeat(divisor) #(i_wb_clk_period/2);
                        end else begin
                            if(o_pwm == i_extclk) begin
                                passed = passed + 1;
                                $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], i_extclk);
                            end else begin
                                $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], i_extclk);
                            end
                            repeat(divisor) #(i_wb_clk_period/2);
                        end
                    end
                end else begin 
                    repeat(DC) begin
                        all = all + 1;
                        if(o_pwm[ch]) begin
                            passed = passed + 1;
                            $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                        end else begin
                            $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                        end
                        if(clk_sel)     repeat(divisor) @(negedge i_extclk);
                        else            repeat(divisor) @(negedge i_wb_clk);
                    end
                    repeat(period - DC) begin
                        all = all + 1;
                        if(!o_pwm[ch]) begin
                            passed = passed + 1;
                            $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                        end else begin
                            $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                        end
                        if(clk_sel)     repeat(divisor) @(negedge i_extclk);
                        else            repeat(divisor) @(negedge i_wb_clk);
                    end  
                end
            end
            endtask
        // assert_timer task
            task assert_timer(input [15:0] period, input timer_mode, clk_sel, input [1:0] ch, input[mem_width-1:0] divisor); begin
                // cont mode
                    if(timer_mode) begin    
                        repeat(2) begin
                            repeat(period) begin
                                all = all + 1;
                                if(!o_pwm[ch]) begin
                                    passed = passed + 1;
                                    $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                                end else begin
                                    $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                                end
                                if(clk_sel) repeat(divisor) @(negedge i_extclk);
                                else        repeat(divisor) @(negedge i_wb_clk);
                            end
                            all = all + 1;
                            if(o_pwm[ch]) begin
                                passed = passed + 1;
                                $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                            end else begin
                                $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                            end
                            if(clk_sel) repeat(divisor) @(negedge i_extclk);
                            else        repeat(divisor) @(negedge i_wb_clk);
                        end
                // one-shot mode
                    end else begin
                        repeat(period) begin
                            all = all + 1;      
                            if(!o_pwm[ch]) begin
                                passed = passed + 1;
                                $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                            end else begin
                                $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                            end
                            if(clk_sel) repeat(divisor) @(negedge i_extclk);
                            else        repeat(divisor) @(negedge i_wb_clk);
                        end
                        all = all + 1;
                        if(o_pwm[ch]) begin
                            passed = passed + 1;
                            $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                        end else begin
                            $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd1);
                        end
                        if(clk_sel) repeat(divisor) @(negedge i_extclk);
                        else        repeat(divisor) @(negedge i_wb_clk);
                        repeat(period + 1) begin
                            all = all + 1;
                            if(!o_pwm[ch]) begin
                                passed = passed + 1;
                                $display("[PASS] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                            end else begin
                                $display("[FAIL] | o_pwm[%d] = %d, expected = %d", ch, o_pwm[ch], 1'd0);
                            end
                            if(clk_sel) repeat(divisor) @(negedge i_extclk);
                            else        repeat(divisor) @(negedge i_wb_clk);
                        end
                    end
            end
            endtask
        // assert_interface task
            task assert_interface(input [mem_width-1 : 0] data); begin
                i_wb_we = 0;    @(negedge i_wb_clk);    // enables read operation
                all = all + 1;
                if(o_wb_data == data && o_wb_ack) begin
                    passed = passed + 1;
                    $display("[PASS] | o_wb_data = %h, expected = %h, o_wb_ack = %d, exptected = %d", o_wb_data, data, o_wb_ack, 1'd1);
                end else begin
                    $display("[FAIL] | o_wb_data = %h, expected = %h, o_wb_ack = %d, exptected = %d", o_wb_data, data, o_wb_ack, 1'd1);
                end
            end
            endtask
    // Stimulus
        initial begin
            // 1st scenario Functional Correctness (RESET behavior)
                $display("========== 1st scenario Functional Correctness (RESET behavior) ==========");
                reset(); all = 1;
                ch = 0;
                if(!o_pwm[0] && !o_wb_ack && o_wb_data == 0) begin 
                            passed =  1;
                            $display("[PASS] | o_pwm[%d] = %d, expected = %d, o_wb_ack = %d, expected = %d, o_wb_data = %h, expected = %h", ch, o_pwm, 1'd0, o_wb_ack, 1'd0, o_wb_data, 16'h0); 
                end else    $display("[FAIL] | o_pwm[%d] = %d, expected = %d, o_wb_ack = %d, expected = %d, o_wb_data = %h, expected = %h", ch, o_pwm, 1'd0, o_wb_ack, 1'd0, o_wb_data, 16'h0);
            // 2nd scenairo Functional Correctness (Direct wb write/read for all registers)
                $display("========== 2nd scenairo Functional Correctness (Direct wb write/read for all registers) ==========");
                reset();
                for(i=0; i<mem_depth; i=i+1) begin
                    data = 40 * i;
                    assign_data(1, 1, 1, 1, data, i, 0, 0);
                    assert_interface(data);
                end
            // 3rd scenairo Functional Correctness (Random wb write/read for all registers)
                $display("========== 3rd scenairo Functional Correctness (Random wb write/read for all registers) ==========");
                reset();
                for(i=0; i<mem_depth; i=i+1) begin
                    data = $random;
                    assign_data(1, 1, 1, 1, data, i, 0, 0);
                    assert_interface(data);
                end
            // 4th scenairo Functional Correctness (pwm core: DC_reg = 50 percent, period_reg = 4)
                $display("========== 4th scenairo Functional Correctness (pwm core: DC_reg = 50 percent, period_reg = 4) ==========");
                reset();
                assign_data(1, 1, 1, 1, 16'd2, 3, 0, 0);                // DC register
                assign_data(1, 1, 1, 1, 16'd4, 1, 0, 0);                // period register
                assign_data(1, 1, 1, 1, 16'b0001_0110, 0, 0, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd2, 16'd4, 0, 0, 1);
            // 5th scenairo Functional Correctness (pwm core: DC_reg = 25 percent, period_reg = 8)
                $display("========== 5th scenairo Functional Correctness (pwm core: DC_reg = 25 percent, period_reg = 8) ==========");
                reset();
                assign_data(1, 1, 1, 1, 16'd2, 3, 0, 0);                // DC register
                assign_data(1, 1, 1, 1, 16'd8, 1, 0, 0);                // period register
                assign_data(1, 1, 1, 1, 16'b0001_0110, 0, 0, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd2, 16'd8, 0, 0, 1);
            // 6th scenairo Functional Correctness (pwm core: i_DC = 75 percent, period_reg = 4)
                $display("========== 6th scenairo Functional Correctness (pwm core: i_DC = 75 percent, period_reg = 4) ==========");
                reset();
                assign_data(1, 1, 1, 1, 16'd4, 1, 64'd3, 0);                // period register
                assign_data(1, 1, 1, 1, 16'b0101_0110, 0, 64'd3, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd3, 16'd4, 0, 0, 1);
            // 7th scenairo Functional Correctness (pwm core: random DC = 40 percent, period_reg = 5)
                $display("========== 7th scenairo Functional Correctness (pwm core: random DC = 40 percent, period_reg = 5) ==========");
                reset();
                DC_sel = $random;
                assign_data(1, 1, 1, 1, 16'd2, 3, 64'd2, 0);                            // DC register
                assign_data(1, 1, 1, 1, 16'd5, 1, 64'd2, 0);                            // period register
                assign_data(1, 1, 1, 1, {9'b0, DC_sel, 6'b01_0110}, 0, 64'd2, 0);         // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd2, 16'd5, 0, 0, 1);
            // 8th scenairo Functional Correctness (timer core: [one-shot mode] period_reg = 4)
                $display("========== 8th scenairo Functional Correctness (timer core: [one-shot mode] period_reg = 4) ==========");
                reset();
                assign_data(1, 1, 1, 0, 16'd4, 1, 0, 0);                // period register
                assign_data(1, 1, 1, 0, 16'b0001_0100, 0, 0, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                assert_timer(16'd4, 0, 0, 0, 1);                           // one-shot mode, i_wb_clk selected
            // 9th scenairo Functional Correctness (timer core: [cont mode] period_reg = 4)
                $display("========== 9th scenairo Functional Correctness (timer core: [cont mode] period_reg = 4) ==========");
                reset();
                assign_data(1, 1, 1, 0, 16'd4, 1, 0, 0);                // period register
                assign_data(1, 1, 1, 0, 16'b0001_1100, 0, 0, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                assert_timer(16'd4, 1, 0, 0, 1);                           // one-shot mode, i_wb_clk selected
            // 10th scenairo Functional Correctness (timer core: [random mode] period_reg = 7)
                $display("========== 10th scenairo Functional Correctness (timer core: [random mode] period_reg = 7) ==========");
                reset();
                timer_mode = $random;
                assign_data(1, 1, 1, 0, 16'd7, 1, 0, 0);                                // period register
                assign_data(1, 1, 1, 0, {12'b0001, timer_mode, 3'b100}, 0, 0, 0);       // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                assert_timer(16'd7, timer_mode, 0, 0, 1);          
            // 11th scenairo Functional Correctness (Random core: DC = 50 percent, period_reg = 4)
                $display("========== 11th scenairo Functional Correctness (Random core: DC = 50 percent, period_reg = 4) ==========");
                reset();
                mode = $random;
                timer_mode = $random;
                assign_data(1, 1, 1, 0, 16'd4, 1, 0, 0);                                        // period register
                assign_data(1, 1, 1, 0, 16'd2, 3, 0, 0);                                        // DC register
                assign_data(1, 1, 1, 0, {12'b0001, timer_mode, 1'd1, mode, 1'd0}, 0, 0, 0);     // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                if(mode)    repeat(2)   assert_pwm(16'd2, 16'd4, 0, 0, 1);
                else        assert_timer(16'd4, timer_mode, 0, 0, 1);
            // 12th scenairo Functional Correctness (timer core: [random mode] period_reg = 4, divisor_reg = 2)
                $display("========== 12th scenairo Functional Correctness (timer core: [random mode] period_reg = 4, divisor_reg = 2) ==========");
                reset();
                timer_mode = 1;
                assign_data(1, 1, 1, 0, 16'd4, 1, 0, 0);                                // period register
                assign_data(1, 1, 1, 0, {12'b0001, timer_mode, 3'b100}, 0, 0, 0);       // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                assert_timer(16'd4, timer_mode, 0, 0, 1);  
            // 13th scenario Corner Case (pwm core: [DC_reg = 4] > [period_reg = 3])
                $display("========== 13th scenario Corner Case (pwm core: [DC_reg = 4] > [period_reg = 3]) ==========");
                reset();
                assign_data(1, 1, 1, 1, 16'd4, 3, 0, 0);                // DC register
                assign_data(1, 1, 1, 1, 16'd3, 1, 0, 0);                // period register
                assign_data(1, 1, 1, 1, 16'b0001_0110, 0, 0, 0);        // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd4, 16'd3, 0, 0, 1);
            // 14th scenario Corner Case (pwm core: [i_DC = 5] > [period_reg = 4])
                $display("========== 14th scenario Corner Case (pwm core: [i_DC = 5] > [period_reg = 4]) ==========");
                reset();
                assign_data(1, 1, 1, 1, 16'd4, 1, 64'd5, 0);                    // period register
                assign_data(1, 1, 1, 1, 16'b0101_0110, 0, 64'd5, 0);            // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                repeat(2)   assert_pwm(16'd5, 16'd4, 0, 0, 1);
            // 15th scenario Corner Case (timer core: [random mode] period_reg = 1)
                $display("========== 15th scenario Corner Case (timer core: [random mode] period_reg = 1) ==========");
                reset();
                timer_mode = $random;
                assign_data(1, 1, 1, 0, 16'd1, 1, 0, 0);                                // period register
                assign_data(1, 1, 1, 0, {12'b0001, timer_mode, 3'b100}, 0, 0, 0);       // ctrl register
                repeat(2)   @(negedge i_wb_clk);
                assert_timer(16'd1, timer_mode, 0, 0, 1);  
            // 16th scenario Corner Case (assign RANDOM data for each channel and cheack outputs in parallel)
                $display("========== 16th scenario Corner Case (assign RANDOM data for each channel and cheack outputs in parallel) ==========");
                reset();
                repeat(5) begin
                    for(i=0; i<num_ch; i=i+1) begin
                        mode = $random;
                        timer_mode = $random;
                        DC = $random;
                        period = $random;
                        ch = i;
                        $display("channel[%d] | RANDOM: DC = %d, period = %d", ch, DC, period);
                        if(mode)            $display("  Selected Core: pwm_core");
                        else if(timer_mode) $display("  Selected Core: timer_core in continuous mode");
                        else                $display("  Selected Core: timer_core in one-shot mode");
                        assign_data(1, 1, 1, 0, {12'b0, DC}, 4*i + 3, 0, 0);                                
                        assign_data(1, 1, 1, 0, {12'b0, period}, 4*i + 1, 0, 0);                            
                        assign_data(1, 1, 1, 0, {12'b0001, timer_mode, 1'd1, mode, 1'd0}, 4*i + 0, 0, 0);   
                        repeat(2)   @(negedge i_wb_clk);
                        if(mode)    repeat(2)assert_pwm({12'b0, DC}, {12'b0, period}, 0, i, 1);
                        else        assert_timer({12'b0, period}, timer_mode, 0, i, 1);
                    reset();
                    end 
                end
            // STOP Simulation
                $display("==================== STOP Simulation ====================");
                $display("------------------------- Report ------------------------\nAll Test Cases    = %d\nPASSed Test Cases = %d\nFAILed Test Cases = %d", 
                        all, passed, all-passed);
                #200;
                $stop;
        end
    // monitor
        initial begin
            // $monitor("Time: %t | o_pwm = %d, o_wb_ack = %d, o_wb_data = %h, all = %d, passed = %d", $time, o_pwm, o_wb_ack, o_wb_data, all, passed);
            // $monitor("all = %d, passed = %d", all, passed);
            // $monitor("i_DC = %h, valid_ext_DC = %h, i_DC_valid = %d", i_DC, DUT.valid_ext_DC, i_DC_valid);
        end
endmodule