`timescale 1ns/1ps
module pwm_timer_tb();
    reg i_clk; 
    reg i_rst;
    reg i_wb_cyc;
    reg i_wb_stb;
    reg i_wb_we;
    reg [15:0] i_wb_adr;
    reg [15:0] i_wb_data;
    reg i_ext_clk;
    reg [15:0] i_DC;
    reg i_DC_valid;
    wire o_wb_ack;
    wire o_pwm;  

// dut instantiation
    pwm_timer DUT(
        .i_clk(i_clk),
        .i_rst(i_rst), 
        .i_wb_cyc(i_wb_cyc), 
        .i_wb_stb(i_wb_stb), 
        .i_wb_we(i_wb_we), 
        .i_wb_adr(i_wb_adr), 
        .i_wb_data(i_wb_data), 
        .i_ext_clk(i_ext_clk), 
        .i_DC(i_DC), 
        .i_DC_valid(i_DC_valid), 
        .o_wb_ack(o_wb_ack), 
        .o_pwm(o_pwm)
    );

// i_clk generation
    initial
        begin
            i_clk = 0;  // initial to avoid xx
            // 50 MHZ 
            forever #10 i_clk = ~i_clk;
        end

// i_ext_clk generation
    initial
        begin
            i_ext_clk = 0;  // initial to avoid xx
            // slower external clk
            forever #50 i_ext_clk = ~i_ext_clk;
        end

// TASKs
    // reset task
    task reset();
        begin
            i_rst = 1;          // activate reset
            i_wb_cyc = 0;       // default value
            i_wb_stb = 0;       // default value
            i_wb_we = 0;        // default value
            i_wb_adr = 16'd0;   // default value
            i_wb_data = 16'd0;  // default value
            i_DC = 16'd0;       // default value
            i_DC_valid = 0;     // default value
            repeat(30)
                // waits for 30 i_clk cycles to track reset
                @(negedge i_clk);
            i_rst = 0;          // release reset
        end
    endtask

//dump vars
    initial
        begin
            $dumpfile("waveform.vcd");
            $dumpvars(0, pwm_timer_tb);
        end

//testing
    initial
        begin
        // 1st scenario Functional Correctness (Reset Behaviour)
            $display("\n==================== 1st scenario Functional Correctness (Reset Behaviour) ====================");
            reset();
            if((DUT.regfile.REG[0] == 0) && (DUT.regfile.REG[2] == 0) && (DUT.regfile.REG[4] == 0) && (DUT.regfile.REG[6] == 0) && 
                !o_pwm && !o_wb_ack && (DUT.wb.o_reg_adr == 0) &&  (DUT.wb.o_wb_data == 0) && (DUT.wb.o_reg_we == 0))
                $display("[PASS] 1st scenario Functional Correctness (Reset Behaviour)");
            else
                $display("[FAIL] 1st scenario Functional Correctness (Reset Behaviour)");


        // 2nd scenario Functional Correctness (PWM output (Period, DC))
            $display("\n==================== 2nd scenario Functional Correctness (PWM output (Period, DC)) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'b0001_0110;  // choose wanted mode  //i_clk & pwm mode & counter EN & o_pwm EN & duty_reg 
            @(negedge i_clk);
            i_wb_adr = 16'd4;           // choose period reg
            i_wb_data = 16'd8;          // 
            @(negedge i_clk);
            i_wb_adr = 16'd6;           // choose DC reg
            i_wb_data = 16'd4;          // 50 % DC
            @(negedge i_clk);
            $display("start cycle : o_pwm = %d", o_pwm);
            repeat(4) // waits for DC
                @(negedge i_clk);
            $display("after 4 clk cycles (DC = 4) : o_pwm = %d", o_pwm);
            if(o_pwm)
                $display("[PASS] 2nd scenario Functional Correctness (PWM output (Period, DC))");
            else
                $display("[FAIL] 2nd scenario Functional Correctness (PWM output (Period, DC)) | o_pwm = %d, expected = 1", o_pwm);
            repeat(80) // waits for DC
                @(negedge i_clk);

            //i_DC input with DC 25%
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            repeat(4) 
                @(negedge i_clk);
            i_wb_adr = 16'd4;           // choose period reg
            i_wb_data = 16'd8;          // 
            @(negedge i_clk);   
            i_DC_valid = 1 ;
            i_DC = 16'd2 ;
            @(negedge i_clk);      
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'b0101_0111;  // choose wanted mode  //i_ext_clk & pwm mode & counter EN & o_pwm EN & external duty
            repeat(200) // waits and watch wave form
                @(negedge i_clk);


        // 3rd scenario Functional Correctness (Timer Mode interrupts [cont])
            $display("\n==================== 3rd scenario Functional Correctness (Timer Mode interrupts [cont]) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd4;           // choose period reg
            i_wb_data = 16'd8;          // 
            @(negedge i_clk);
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'b0011_1100;  // choose wanted mode (cont) //i_clk & timer mode & counter EN & cont & o_pwm EN 
            repeat(20)                   // wait and watch counter keeps incrementing
            @(negedge i_clk);
            repeat(12)                   // waits counter to reach period
                @(negedge i_clk);
            if(o_pwm)
                $display("[PASS] 3rd scenario Functional Correctness (Timer Mode interrupts [cont]) : after counter reachs period (8)");
            else
                $display("[FAIL] 3rd scenario Functional Correctness (Timer Mode interrupts [cont]) : after counter reachs period (8) | o_pwm = %d, expected = 0", o_pwm);
            @(negedge i_clk);
            if(DUT.timer.count == 0)
                $display("[FAIL] 3rd scenario Functional Correctness (Timer Mode interrupts [cont]) : after one time cycle counter doesn't start counting again | count = %d", DUT.timer.count);
            else
                $display("[PASS] 3rd scenario Functional Correctness (Timer Mode interrupts [cont]) : after one time cycle counter doesn't start counting again | count = %d", DUT.timer.count);
            repeat(20)                   // wait and watch counter keeps incrementing
                @(negedge i_clk);

        // 4th scenario Functional Correctness (Timer Mode interrupts [one-shot])
            $display("\n==================== 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd4;           // choose period reg
            i_wb_data = 16'd6;          // 
            @(negedge i_clk);
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'b0011_0100;  // choose wanted mode //i_clk , timer mode , counter EN , one shot , o_pwm EN 
            @(negedge i_clk);
            if(o_pwm)
                $display("[FAIL] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : before counter reachs period (8) | o_pwm = %d, expected = 0", o_pwm);
            else
                $display("[PASS] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : before counter reachs period (8)");
            repeat(20)                   // waits counter to reach period
                @(negedge i_clk);
            if(o_pwm)
                $display("[PASS] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : beafter counter reachs period (8)");
            else
                $display("[FAIL] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : after counter reachs period (8) | o_pwm = %d, expected = 1", o_pwm);
            @(negedge i_clk);
            if(DUT.timer.count != 0)
                $display("[FAIL] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : after one time cycle counter starts counting again | count = %d", DUT.timer.count);
            else
                $display("[PASS] 4th scenario Functional Correctness (Timer Mode interrupts [one-shot]) : after one time cycle counter doesn't start counting again | count = %d", DUT.timer.count);    


        // 5th scenaroi Functional Correctness (Down Clocking (divisor = 2))
            $display("\n==================== 5th scenaroi Functional Correctness (Down Clocking (divisor = 2)) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd2;           // choose divisor reg
            i_wb_data = 16'd2;          // choose wanted mode (cont)
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            repeat(2/2)         //now, o_slow_clk should be 1 
                @(negedge i_clk);
            if(DUT.down_clk.o_slow_clk)
                $display("[PASS] 5th scenaroi Functional Correctness (Down Clocking (divisor = 2)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 5th scenaroi Functional Correctness (Down Clocking (divisor = 2)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            repeat(2/2)         //now, o_slow_clk should be 0
                @(negedge i_clk);
            if(!DUT.down_clk.o_slow_clk)
                $display("[PASS] 5th scenaroi Functional Correctness (Down Clocking (divisor = 2)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 5th scenaroi Functional Correctness (Down Clocking (divisor = 2)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            repeat(20)                   // wait and watch wave form
                @(negedge i_clk);

        // 6th scenaroi Functional Correctness (Down Clocking (divisor = 10))
            $display("\n==================== 6th scenaroi Functional Correctness (Down Clocking (divisor = 10)) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd2;           // choose divisor reg
            i_wb_data = 16'd10;          // choose wanted mode (cont)
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            repeat(10/2)         //now, o_slow_clk should be 1 
                @(negedge i_clk);
            if(DUT.down_clk.o_slow_clk)
                $display("[PASS] 6th scenaroi Functional Correctness (Down Clocking (divisor = 10)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 6th scenaroi Functional Correctness (Down Clocking (divisor = 10)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            repeat(10/2)         //now, o_slow_clk should be 0
                @(negedge i_clk);
            if(!DUT.down_clk.o_slow_clk)
                $display("[PASS] 6th scenaroi Functional Correctness (Down Clocking (divisor = 10)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 6th scenaroi Functional Correctness (Down Clocking (divisor = 10)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            repeat(200) // waits and watch wave form
                @(negedge i_clk);   

        // 7th scenaroi Functional Correctness (Down Clocking (divisor = 0))
            $display("\n==================== 7th scenaroi Functional Correctness (Down Clocking (divisor = 0)) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd2;           // choose divisor reg
            i_wb_data = 16'd0;          // 
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            repeat(10/2)         //now, o_slow_clk should be 1 
                @(negedge i_clk);
            // if(DUT.down_clk.o_slow_clk)
            //     $display("[PASS] 7th scenaroi Functional Correctness (Down Clocking (divisor = 0)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            // else    
            //     $display("[FAIL] 7th scenaroi Functional Correctness (Down Clocking (divisor = 0)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            // repeat(10/2)         //now, o_slow_clk should be 0
                @(negedge i_clk);
            if(!DUT.down_clk.o_slow_clk)
                $display("[PASS] 7th scenaroi Functional Correctness (Down Clocking (divisor = 0)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 7th scenaroi Functional Correctness (Down Clocking (divisor = 0)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            repeat(200) // waits and watch wave form
                @(negedge i_clk); 

        // 8th scenaroi Functional Correctness (Down Clocking (divisor = 1))
            $display("\n==================== 8th scenaroi Functional Correctness (Down Clocking (divisor = 1)) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd2;           // choose divisor reg
            i_wb_data = 16'd1;          // choose wanted mode (cont)
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            // repeat(1/2)         //now, o_slow_clk should be 1 
                @(negedge i_clk);
            // if(DUT.down_clk.o_slow_clk)
            //     $display("[PASS] 8th scenaroi Functional Correctness (Down Clocking (divisor = 1)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            // else    
            //     $display("[FAIL] 8th scenaroi Functional Correctness (Down Clocking (divisor = 1)) : high level half-cycle | o_slow_clk = %d, expected = 1", DUT.down_clk.o_slow_clk);
            // repeat(10/2)         //now, o_slow_clk should be 0
                @(negedge i_clk);
            if(!DUT.down_clk.o_slow_clk)
                $display("[PASS] 8th scenaroi Functional Correctness (Down Clocking (divisor = 1)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            else    
                $display("[FAIL] 8th scenaroi Functional Correctness (Down Clocking (divisor = 1)) : low level half-cycle | o_slow_clk = %d, expected = 0", DUT.down_clk.o_slow_clk);
            repeat(200) // waits and watch wave form
                @(negedge i_clk);                               

        // 9th scenario Optional Feature (DC > period handling)
            $display("\n==================== 9th scenario Optional Feature (DC > period handling) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd4;           // choose period reg
            i_wb_data = 16'd2;          // period = 2
            @(negedge i_clk);           // waits to track changes 
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd6;           // choose DC reg
            i_wb_data = 16'd4;          // choose wanted mode (cont)
            @(negedge i_clk);           // DC = 4
            
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'b0001_0110;  // 
            @(negedge i_clk);           // waits to track changes 
                @(negedge DUT.o_clk);
                if(o_pwm == DUT.o_clk)
                    $display("[PASS] 9th scenario Optional Feature (DC > period handling) ");
                else
                    $display("[FAIL] 9th scenario Optional Feature (DC > period handling) | o_pwm = %d, expected = %d", DUT.pwm_out, DUT.o_clk);
            


        // 10th scenario Functional Correctness (WB Read)
            $display("\n==================== 10th scenario Functional Correctness (WB Read) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'hFF;         // FF
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            if(DUT.i_data == DUT.i_wb_data)
                $display("[PASS] 10th scenario Functional Correctness (WB Read)");
            else
                $display("[FAIL] 10th scenario Functional Correctness (WB Read) | o_wb_data = %h, expected = %h", DUT.i_data, DUT.i_wb_data);


            // 11th scenario Functional Correctness (WB Write to reg_file [ctrl])
            $display("\n==================== 11th scenario Functional Correctness (WB Write to reg_file [ctrl]) ====================");
            reset();
            i_wb_cyc = 1;               // enable process
            i_wb_stb = 1;               // enable process
            i_wb_we = 1;                // enable process
            i_wb_adr = 16'd0;           // choose ctrl reg
            i_wb_data = 16'h2F;         // 2F
            @(negedge i_clk);           // waits to track changes 
            @(negedge i_clk);
            if(DUT.ctrl_reg == DUT.i_wb_data)
                $display("[PASS] 11th scenario Functional Correctness (WB Write to reg_file [ctrl])");
            else
                $display("[FAIL] 11th scenario Functional Correctness (WB Write to reg_file [ctrl]) | ctrl_reg = %h, expected = %h", DUT.ctrl_reg, DUT.i_wb_data);
            i_wb_data = 16'h0;         


        // STOP Simulation
            $display("\n==================== STOP Simulation ====================");
            // reset();
            #100; 
            $stop;
        end

// monitor
    // initial
    //     $monitor("o_pwm = %d , pwm_out from pwm core = %d, timer.count = %d , slow_clk = %d", o_pwm, DUT.pwm_out, DUT.timer.count, DUT.o_clk);

endmodule
