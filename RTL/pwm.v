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
        input wire [15:0] counter,                              // main counter
        input wire [15:0] period_reg,                           // period register
        input wire [15:0] DC_reg,                               // duty cycle register
    // Outputs
        output reg pwm                                          // pwm output
);

    // Internal Signals
        reg [15:0] period_reg_sync;
        reg [15:0] DC_reg_sync;
        wire [15:0] DC;                                         // chosen duty cycle
        assign DC = DC_sel? i_DC : DC_reg_sync;

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
                pwm <= 1'b0;
            end else if(pwm_en) begin
                if(DC > period_reg_sync) begin          // DC > period handling 
                    pwm <= chosen_clk;                  // output chosen_clk if DC > period
                end else if(counter < period_reg_sync) begin
                    pwm <= (counter < DC)? 1'b1 : 1'b0;
                end else begin
                    pwm <= 1'b0;                        // reset the pwm output in case of counter exceedes the period register
                end  
            end
        end
endmodule