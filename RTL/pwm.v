//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pwm
(
    // Inputs 
        input wire chosen_clk,                                  // active-high clk signal. chosen_clk = ctrl[0]? i_ext_clk : i_wb_clk;
        input wire rst,                                         // i_wb_rst: async. active-high reset signal
        input wire pwm_en,                                      // pwm_en = ctrl[1] & ctrl[2]. mode-bit, counter_en-bit
        input wire DC_sel,                                      // DC = ctrl[6]? i_DC : DC_reg
        input wire [15:0] i_DC,                                 // external duty cycle
        input wire [63:0] counter,                              // main counter. [15:0]: ch0, ..., [63:48] ch4
        input wire [63:0] period_reg,                           // period register. [15:0]: ch0, ..., [63:48] ch4
        input wire [63:0] DC_reg,                               // duty cycle register. [15:0]: ch0, ..., [63:48] ch4
    // Outputs
        output reg pwm_ch0,                                     // pwm output for channel 0
        output reg pwm_ch1,                                     // pwm output for channel 1
        output reg pwm_ch2,                                     // pwm output for channel 2
        output reg pwm_ch3                                      // pwm output for channel 3
);

    // Internal Signals
        reg [63:0] period_reg_sync;
        reg [63:0] DC_reg_sync;
        wire [15:0] DC0;                                        // ch0 duty cycle
        wire [15:0] DC1;                                        // ch1 duty cycle
        wire [15:0] DC2;                                        // ch2 duty cycle
        wire [15:0] DC3;                                        // ch3 duty cycle

    // Assign DCs
        assign DC0 = DC_sel? i_DC : DC_reg_sync[15:0];
        assign DC1 = DC_sel? i_DC : DC_reg_sync[31:16];
        assign DC2 = DC_sel? i_DC : DC_reg_sync[47:32];
        assign DC3 = DC_sel? i_DC : DC_reg_sync[63:48];

    // Registers syncronization
        always@(posedge chosen_clk or posedge rst) begin
            if(rst) begin
                period_reg_sync <= 0;
                DC_reg_sync <= 0;   
            end else begin
                period_reg_sync <= period_reg;
                DC_reg_sync <= DC_reg;
            end
        end

    // Logic
        always@(posedge chosen_clk or posedge rst) begin
            if(rst) begin
                pwm_ch0 <= 0;
                pwm_ch1 <= 0;
                pwm_ch2 <= 0;
                pwm_ch3 <= 0;
            end else if(pwm_en) begin
                // ch0 logic
                    // DC > period handling 
                    if(DC0 > period_reg_sync[15:0]) begin
                        pwm_ch0 <= chosen_clk;                  // output chosen_clk if DC > period
                    end else if(counter[15:0] < period_reg_sync[15:0]) begin
                        pwm_ch0 <= (counter[15:0] < DC0)? 1'b1 : 1'b0;
                    end else begin
                        pwm_ch0 <= 1'b0;                        // reset the pwm output in case of counter exceedes the period register
                    end
                // ch1 logic
                    // DC > period handling 
                    if(DC1 > period_reg_sync[31:16]) begin
                        pwm_ch1 <= chosen_clk;                  // output chosen_clk if DC > period
                    end else if(counter[31:16] < period_reg_sync[31:16]) begin
                        pwm_ch1 <= (counter[31:16] < DC0)? 1'b1 : 1'b0;
                    end else begin
                        pwm_ch1 <= 1'b0;                        // reset the pwm output in case of counter exceedes the period register
                    end
                // ch2 logic
                    // DC > period handling 
                    if(DC2 > period_reg_sync[47:32]) begin
                        pwm_ch2 <= chosen_clk;                  // output chosen_clk if DC > period
                    end else if(counter[47:32] < period_reg_sync[47:32]) begin
                        pwm_ch2 <= (counter[47:32] < DC0)? 1'b1 : 1'b0;
                    end else begin
                        pwm_ch2 <= 1'b0;                        // reset the pwm output in case of counter exceedes the period register
                    end
                // ch0 logic
                    // DC > period handling 
                    if(DC3 > period_reg_sync[63:48]) begin
                        pwm_ch3 <= chosen_clk;                  // output chosen_clk if DC > period
                    end else if(counter[63:48] < period_reg_sync[63:48]) begin
                        pwm_ch3 <= (counter[63:48] < DC0)? 1'b1 : 1'b0;
                    end else begin
                        pwm_ch3 <= 1'b0;                        // reset the pwm output in case of counter exceedes the period register
                    end    
            end
        end
endmodule