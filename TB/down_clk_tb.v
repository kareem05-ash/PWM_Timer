///////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification Engineer
// kareem.ash05@gmail.com
// 01002321067
// github.com/kareem05-ash
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
module down_clk_tb();

    reg chosen_clk;                          //active-high clk isgnal to be divided
    reg i_wb_rst;                          //async. active-high rst signal
    reg [15:0] divisor_reg;               //divisor from reg_file
    wire slow_clk;                    //divided clk signal. It can be down clocked at most (1/(2^16 - 1)) of original frequency   

    // DUT Instantiation
    down_clk DUT(
        .chosen_clk(chosen_clk), 
        .i_wb_rst(i_wb_rst), 
        .divisor_reg(divisor_reg), 
        .slow_clk(slow_clk)
    );

    // CLK Generation
    initial
        begin
            chosen_clk = 0;          //initial value to avoid unknown chosen_clk signal
            // chosen_clk signal with frequency 50 MHZ 
            forever # 10 chosen_clk = ~chosen_clk;
        end

    // TASKs
    // reset task
    task reset();
        begin
            i_wb_rst = 1;          //activate i_wb_rst
            divisor_reg = 0;      //initial value
            repeat(30)          //waits for 30 chosen_clk cycles to track i_wb_rst signal
                @(negedge chosen_clk);
            i_wb_rst = 0;          //release i_wb_rst
        end
    endtask     

    initial                     //Test Scenarios & Corner Cases
        begin
                                //1st scenario Functional Correctness (Reset Behavior)
            $display("\n=================== 1st scenario Functional Correctness (Reset Behavior) ====================");
            reset();            //now, slow_clk = 0
            if(!slow_clk && DUT.count == 0)
                $display("[PASS] 1st scenario Functional Correctness (Reset Behavior)");
            else
                $display("[FAIL] 1st scenario Functional Correctness (Reset Behavior) : slow_clk = %d, count = %d", slow_clk, DUT.count);


                                //2nd scenario Functional Correctness (even divisor_reg = 4)
            $display("\n=================== 2nd scenario Functional Correctness (even divisor_reg = 4) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 4;      //even divisor
            repeat(4/2)         //now, slow_clk should be 1 
                @(negedge chosen_clk);
            if(slow_clk)
                $display("[PASS] 2nd scenario Functional Correctness (even divisor_reg = 4)");
            else    
                $display("[FAIL] 2nd scenario Functional Correctness (even divisor_reg = 4) : slow_clk = %d, expected = 1", slow_clk);
            repeat(4/2)         //now, slow_clk should be 0
                @(negedge chosen_clk);
            if(!slow_clk)
                $display("[PASS] 2nd scenario Functional Correctness (even divisor_reg = 4)");
            else    
                $display("[FAIL] 2nd scenario Functional Correctness (even divisor_reg = 4) : slow_clk = %d, expected = 0", slow_clk);


                                //3rd scenario Fuctional Correctness (odd divisor_reg = 5)
            $display("\n=================== 3rd scenario Fuctional Correctness (odd divisor_reg = 5) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 5;      //odd divisor
            repeat(((5-1)/2) + 1)   //waits for divisor_reg_shifted + 1 chosen_clk cycles to maintain posedeg of slow_clk
                @(negedge chosen_clk);
            if(slow_clk)
                $display("[PASS] 3rd scenario Fuctional Correctness (odd divisor_reg = 5)");
            else    
                $display("[FAIL] 3rd scenario Fuctional Correctness (odd divisor_reg = 5) : slow_clk = %d, expected = 1", slow_clk);
            repeat((5-1)/2)     //waits for divisor_reg_shifted chosen_clk cycles to maintain negedge of slow_clk
                @(negedge chosen_clk);
            if(!slow_clk)
                $display("[PASS] 3rd scenario Fuctional Correctness (odd divisor_reg = 5)");
            else    
                $display("[FAIL] 3rd scenario Fuctional Correctness (odd divisor_reg = 5) : slow_clk = %d, expected = 0", slow_clk);


                                //4th scenario Corner Case (Error Handling : divisor_reg = 0)
            $display("\n=================== 4th scenario Corner Case (Error Handling : divisor_reg = 0) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 0;      //invalid divisor_reg should stay at reset state
            if(!slow_clk && DUT.count == 0)
                $display("[PASS] 4th scenario Corner Case (Error Handling : divisor_reg = 0)");
            else
                $display("[FAIL] 4th scenario Corner Case (Error Handling : divisor_reg = 0) : slow_clk = %d, count = %d", slow_clk, DUT.count);


                                //5th scenario Corner Case (Error Handling : divisor_reg = 1)
            $display("\n=================== 5th scenario Corner Case (Error Handling : divisor_reg = 1) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 1;      //invalid divisor_reg should stay at reset state
            if(!slow_clk && DUT.count == 0)
                $display("[PASS] 5th scenario Corner Case (Error Handling : divisor_reg = 1)");
            else
                $display("[FAIL] 5th scenario Corner Case (Error Handling : divisor_reg = 1) : slow_clk = %d, count = %d", slow_clk, DUT.count);  


                                //6th scenario Corner Case (even divisor_reg = 100)
            $display("\n=================== 6th scenario Corner Case (even divisor_reg = 100) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 100;    //even divisor
            repeat(100/2)       //now, slow_clk should be 1 
                @(negedge chosen_clk);
            if(slow_clk)
                $display("[PASS] 6th scenario Corner Case (even divisor_reg = 100)");
            else    
                $display("[FAIL] 6th scenario Corner Case (even divisor_reg = 100) : slow_clk = %d, expected = 1", slow_clk);
            repeat(100/2)       //now, slow_clk should be 0
                @(negedge chosen_clk);
            if(!slow_clk)
                $display("[PASS] 6th scenario Corner Case (even divisor_reg = 100)");
            else    
                $display("[FAIL] 6th scenario Corner Case (even divisor_reg = 100) : slow_clk = %d, expected = 0", slow_clk);  


                                //7th scenario Corner Case (odd divisor_reg = 101)
            $display("\n=================== 7th scenario Corner Case (odd divisor_reg = 101) ====================");
            reset();            //now, slow_clk = 0
            divisor_reg = 101;    //odd divisor
            repeat(((101-1)/2) + 1) //waits for divisor_reg_shifted + 1 chosen_clk cycles to maintain posedeg of slow_clk
                @(negedge chosen_clk);
            if(slow_clk)
                $display("[PASS] 7th scenario Corner Case (odd divisor_reg = 101)");
            else    
                $display("[FAIL] 7th scenario Corner Case (odd divisor_reg = 101) : slow_clk = %d, expected = 1", slow_clk);
            repeat((101-1)/2)   //waits for divisor_reg_shifted chosen_clk cycles to maintain negedge of slow_clk
                @(negedge chosen_clk);
            if(!slow_clk)
                $display("[PASS] 7th scenario Corner Case (odd divisor_reg = 101)");
            else    
                $display("[FAIL] 7th scenario Corner Case (odd divisor_reg = 101) : slow_clk = %d, expected = 0", slow_clk);

                                //STOP Simulation
            #100;
            $stop;
        end       
endmodule