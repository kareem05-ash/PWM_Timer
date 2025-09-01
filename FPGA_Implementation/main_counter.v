module main_counter
(
    // Inputs
        input wire slow_clk,                            // +ve edge slow clk from clk_divider module
        input wire rst,                                 // async +ve edge system rst (i_wb_rst)
        input wire sw_rst,                              // sync software rst signal: active-high level trig
        input wire irq_rst,                             // interrupt request rst
        input wire counter_en,                          // ctrl[2]
        input wire mode,                                // ctrl[1]? pwm : timer mode
        input wire timer_mode,                          // ctrl[3]? cont : one-shot
        input wire [15:0] period_reg,                   // period register from register file
    // Outputs
        output reg [15:0] counter                       // main counter (feeds pwm and timer cores)
);
    // Internal Signals
        reg [15:0] period_reg_sync;                     // period register synchronous with slow_clk (essential in case of i_extclk is chosen instead of i_wb_clk)
        reg sw_rst_sync;
        reg irq_rst_sync;
        reg counter_en_sync;
        reg mode_sync;
        reg timer_mode_sync;
        reg mode_prev;                                  // holds the previousv mode
        reg counts;                                     // flag indicates that the one-shot mode is done
    // Register Synchronization
        always@(posedge slow_clk or posedge rst) begin
            if(rst) begin
                period_reg_sync <= 16'b0;           // reset the register
                sw_rst_sync <= 0;
                irq_rst_sync <= 0;
                counter_en_sync <= 0;
                mode_sync <= 0;
                timer_mode_sync <= 0;
            end
            else begin
                period_reg_sync <= period_reg;      // load the rgister from register file (period_reg)
                sw_rst_sync <= sw_rst;
                irq_rst_sync <= irq_rst;
                counter_en_sync <= counter_en;
                mode_sync <= mode;
                timer_mode_sync <= timer_mode; 
            end
        end 
    // counter logic
        always@(posedge slow_clk or posedge rst) begin
            if(rst || sw_rst_sync) begin
                counter <= 16'b0; 
                mode_prev <= 1'b0; 
                counts <= 1'b0;
            end else begin
                // reset the counter right after changing mode from pwm to timer    
                    if(!mode_sync && mode_prev)  counter <= 16'b0; 
                // clear interrupt request
                    if(!irq_rst_sync)    counts <= 1'b0;             // recount if in timer one-shot mode
                // incrementation
                    if(counter_en_sync) begin                        // if not enabled, counter will stop running (stores the past value)
                        if(mode_sync) begin      // PWM Mode
                            if(counter < period_reg_sync-1) begin
                                counter <= counter + 1;         // increment the counter
                            end else begin
                                counter <= 16'b0;               // reset the counter (roll over) if it's enabled
                            end
                        end else begin      // Timer Mode
                            if(!timer_mode_sync && counts) begin
                                counter <= 16'b0;               // stop running if in one-shot mode
                            end else begin
                                if(counter >= period_reg_sync) begin
                                    counts <= 1'b1;             // raise up one-shot flag   
                                    counter <= 16'b0;           // reset the counter (roll over) it ti's enabled
                                end else begin
                                    counter <= counter + 1;     // increment the counter
                                end
                            end
                        end
                    end else begin                              
                        counter <= counter;                     // stores the past value
                    end
                // update previous mode
                    mode_prev <= mode_sync;
            end
        end
endmodule