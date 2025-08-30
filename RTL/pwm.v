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
        output wire pwm                                         // pwm output
);

    // Internal Signals
        reg [15:0] period_reg_sync;
        reg [15:0] DC_reg_sync;
        reg pwm_en_sync;
        reg DC_sel_sync;
        reg pwm_calc;                                           // calculated pwm signal
        wire [15:0] DC;                                         // chosen duty cycle
    // Assign Wires
        assign DC = DC_sel_sync? i_DC : DC_reg_sync;
        assign pwm = (DC > period_reg_sync)? chosen_clk : pwm_calc;

    // Registers syncronization
        always@(posedge chosen_clk or posedge rst) begin
            if(rst) begin
                period_reg_sync <= 0;
                DC_reg_sync <= 0;  
                pwm_en_sync <= 0;
                DC_sel_sync <= 0; 
            end else begin
                period_reg_sync <= period_reg;
                DC_reg_sync <= DC_reg;
                pwm_en_sync <= pwm_en;
                DC_sel_sync <= DC_sel; 
            end
        end

    // pwm_calc Logic
        always@(posedge chosen_clk or posedge rst) begin
            if(rst) begin
                pwm_calc <= 1'b0;
            end else if(pwm_en_sync) begin
                if(counter < period_reg_sync) begin
                    pwm_calc <= (counter < DC)? 1'b1 : 1'b0;
                end else begin
                    pwm_calc <= 1'b0;           // reset the pwm output in case of counter exceedes the period register
                end  
            end
        end
endmodule