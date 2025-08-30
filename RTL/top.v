//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module top#
(   // Parameters
        parameter num_ch = 4,                                   // number of channels
        parameter mem_width = 16,                               // word width stored in register file
        parameter mem_depth = 4 * num_ch,                       // 4 entries (ctrl, period, divisor, DC) for each channel
        parameter adr_width = 16                                // address width
)               
(   // Ports                
    // Inputs               
        input wire i_wb_clk,                                    // active-high wb clk signal
        input wire i_wb_rst,                                    // async. active-high wb rst signal
        input wire i_wb_cyc,                                    // indicates valid bus cycle
        input wire i_wb_stb,                                    // indicates valid data
        input wire i_wb_we,                                     // if set, write operation. if reset, read operation.
        input wire [adr_width-1:0] i_wb_adr,                    // address to write on it or read from it
        input wire [mem_width-1:0] i_wb_data,                   // input data to be written in register file
        input wire [num_ch*mem_width-1 : 0] i_DC,               // external duty cycle
        input wire i_extclk,                                    // external active-high clk signal
        input wire [num_ch-1:0] i_DC_valid,                     // indicats valid data on i_DC
    // Outputs              
        output wire [mem_width-1:0] o_wb_data,                  // output data read from register file
        output wire o_wb_ack,                                   // acknowledgement: indicates valid termination
        output wire [num_ch-1:0] o_pwm                          // pulse width modulated output
);              
    // Internal Signals             
        wire [num_ch-1:0] chosen_clk;                           // chosen from i_wb_clk or i_extclk
        wire [num_ch-1:0] pwm_en;                                
        wire [num_ch-1:0] timer_en;                              
        wire [num_ch-1:0] slow_clk;                             // divided clk signal from down_clk module
        wire [num_ch-1:0] pwm;                                  // output modulated signal from pwm module
        wire [num_ch-1:0] timer;                                // output signal from timer module
        wire [num_ch-1:0] irq_flag;                             // interrupt flag to be passed to wb_slave
        wire [num_ch*16-1 : 0] counter;                         // main counter from main_counter module
        wire [num_ch*mem_width-1 : 0] valid_ext_DC;             // passes i_DC if it's valid. if not passes 0


        

    // wb_slave Instantiation
        wb_slave #(.num_ch(num_ch), .mem_width(mem_width), .mem_depth(mem_depth), .adr_width(adr_width))
            wb_slave_inst (
                // Inputs
                    .i_wb_clk(i_wb_clk), 
                    .i_wb_rst(i_wb_rst), 
                    .i_wb_cyc(i_wb_cyc), 
                    .i_wb_stb(i_wb_stb), 
                    .i_wb_we(i_wb_we), 
                    .irq_flag(irq_flag),
                    .i_wb_adr(i_wb_adr), 
                    .i_wb_data(i_wb_data), 
                // Outputs
                    .o_wb_ack(o_wb_ack), 
                    .o_wb_data(o_wb_data)
            );


    // Generate Block
        genvar i;                                               // generate loop counter
        generate
            for(i=0; i<num_ch; i=i+1) begin: ch
                // Module Instantiations

                    // down_clk Instantiation
                        down_clk down_clk_inst(
                            // Inputs
                                .chosen_clk(chosen_clk[i]), 
                                .i_wb_rst(i_wb_rst), 
                                .divisor_reg(wb_slave_inst.regfile[4*i + 2]),    // divisor_reg
                            // Outputs
                                .slow_clk(slow_clk[i])
                        );
                    // main_counter Instantiation
                        main_counter main_counter_inst(
                            // Inputs
                                .slow_clk(slow_clk[i]), 
                                .rst(i_wb_rst), 
                                .sw_rst(wb_slave_inst.regfile[4*i + 0][7]),      // ctrl[7]_reg
                                .irq_rst(wb_slave_inst.regfile[4*i + 0][5]),     // ctrl[5]_reg
                                .counter_en(wb_slave_inst.regfile[4*i + 0][2]),  // ctrl[2]_reg
                                .mode(wb_slave_inst.regfile[4*i + 0][1]),        // ctrl[1]_reg
                                .timer_mode(wb_slave_inst.regfile[4*i + 0][3]),  // ctrl[3]_reg
                                .period_reg(wb_slave_inst.regfile[4*i + 1]),     // period_reg
                            // Outputs
                                .counter(counter[16*(i+1)-1 : 16*i])
                        );
                    // pwm Instantiation
                        pwm pwm_inst(
                            // Inputs 
                                .chosen_clk(chosen_clk[i]), 
                                .rst(i_wb_rst), 
                                .pwm_en(pwm_en[i]),
                                .DC_sel(wb_slave_inst.regfile[4*i + 0][6]),      // ctrl[6]_reg
                                .i_DC(valid_ext_DC[mem_width*(i+1)-1 : mem_width*i]), 
                                .counter(counter[mem_width*(i+1)-1 : 16*i]), 
                                .period_reg(wb_slave_inst.regfile[4*i + 1]),     // period_reg
                                .DC_reg(wb_slave_inst.regfile[4*i + 3]),         // DC_reg
                            // Outputs
                                .pwm(pwm[i])
                        );
                    // timer Instantiation
                        timer timer_inst(
                            // Inputs
                                .chosen_clk(chosen_clk[i]), 
                                .rst(i_wb_rst), 
                                .timer_en(timer_en[i]), 
                                .counter(counter[16*(i+1)-1 : 16*i]), 
                                .period_reg(wb_slave_inst.regfile[4*i + 1]),     // period_reg
                            // Outputs
                                .timer(timer[i]), 
                                .irq_flag(irq_flag[i])
                        );
                // MUXs & Assign Statements
                    assign chosen_clk[i] = wb_slave_inst.regfile[4*i + 0][0]? i_extclk : i_wb_clk;
                    assign timer_en[i] = ~wb_slave_inst.regfile[4*i + 0][1] & wb_slave_inst.regfile[4*i + 0][2];      // ~ctrl[1] & ctrl[2]
                    assign pwm_en[i] = wb_slave_inst.regfile[4*i + 0][1] & wb_slave_inst.regfile[4*i + 0][2];         // ctrl[1] & ctrl[2]
                    assign valid_ext_DC[mem_width*(i+1)-1 : i*mem_width] = i_DC_valid[i]? i_DC[mem_width*(i+1)-1 : i*mem_width] : 0;
                    assign o_pwm[i] = wb_slave_inst.regfile[4*i + 0][7]? 1'b0 : (wb_slave_inst.regfile[4*i + 0][1]? pwm[i] : timer[i]);
            end
        endgenerate
endmodule