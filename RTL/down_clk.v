///////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification Engineer
// kareem.ash05@gmail.com
// 01002321067
// github.com/kareem05-ash
///////////////////////////////////////////////////////////
module down_clk
(
    // inputs
        input wire chosen_clk,                                          //active-high clk isgnal to be divided
        input wire i_wb_rst,                                            //async. active-high rst signal
        input wire [15:0] divisor_reg,                                  //divisor from reg_file
    // outputs
        output wire slow_clk                                            //divided clk signal. It can be down clocked at most (1/(2^16 - 1)) of original frequency                       
);
    // internal signals needed
        reg [15:0] divisor_reg_sync;
        wire zero_flag = divisor_reg_sync == 0;                         //track zero ratio
        wire one_flag = divisor_reg_sync == 1;                          //track one ratio
        wire enable = (!zero_flag && !one_flag);                        //set if divisor_reg_sync is greater than one. it can be implemented by (divisor_reg_sync > 1)
        wire odd_flag = divisor_reg_sync[0];                            //set if the divisor_reg_sync is odd to maintain unequal low and high levels in case of odd divisor_reg_sync
        wire [14:0] divisor_reg_sync_shifted = divisor_reg_sync >> 1;   //floor the result of (divisor_reg_sync/2)
        reg [14:0] count;                                               //counter counts chosen_clk cycles to handle division operation
        reg slow_clk_calc;                                              //slow clk after dividing logic

    // assign output logic
        assign slow_clk = (zero_flag | one_flag )? chosen_clk : slow_clk_calc;
        
    // register synchronization
        always@(posedge chosen_clk or posedge i_wb_rst)
            if(i_wb_rst)    divisor_reg_sync <= 0;
            else            divisor_reg_sync <= divisor_reg;

    // division logic block
        always@(posedge chosen_clk or posedge i_wb_rst)
            begin
                if(i_wb_rst)
                    begin
                        count <= 0;                         //reset the counter
                        slow_clk_calc <= 0;                 //initialize the slow clk to avoid 'x' : unknown slow_clk signal output 
                    end
                else if(enable)
                    begin
                        if(!odd_flag && count == divisor_reg_sync_shifted-1)    //even ratio
                            begin
                                count <= 0;                                     //reset the counter
                                slow_clk_calc <= ~slow_clk_calc;                //toggle slow_clk signal
                            end
                        else if(odd_flag)                                       //odd ratio
                            begin
                                if(((count == divisor_reg_sync_shifted) && !slow_clk_calc) || ((count == divisor_reg_sync_shifted-1) && slow_clk_calc))
                                    begin
                                        count <= 0;                             //reset the counter
                                        slow_clk_calc <= ~slow_clk_calc;        //toggle slow_clk signal    
                                    end
                                else 
                                    count <= count + 1;                         //increment the counter to reach the needed value
                            end     
                        else            
                            count <= count + 1;                                 //increment the counter to reach the needed value
                    end
            end
endmodule