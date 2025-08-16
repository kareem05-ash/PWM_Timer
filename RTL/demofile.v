// TOP Module

module pwm_timer(
    input i_clk, 
    input i_rst,
    input i_wb_cyc,
    input i_wb_stb,
    input i_wb_we,
    input [15:0] i_wb_adr,
    input [15:0] i_wb_data,
    input i_ext_clk,
    input [15:0] i_DC,
    input i_DC_valid,
    output o_wb_ack,
    output o_pwm  
);

//internal signals 
    //wb signals
    wire o_reg_we ;
    wire o_reg_adr ;
    wire o_wb_data ;
    //clk down signals
    wire o_clk ; //input clk for timer and pwm
    wire chosen_clk ;
    //pwm signals
    wire pwm_out ;
    //timer signals
    wire o_irq ;
    //register file signals
    wire wrEN ;
    wire [15:0] adr ;
    wire [15:0] i_data ;
    //regfile registers
    wire [15:0] ctrl_reg = regfile.REG[0] ;
    wire [15:0] divisor_reg = regfile.REG[2];
    wire [15:0] period_reg = regfile.REG[4] ;
    wire [15:0] duty_reg = regfile.REG[6] ;

//internal logic 
assign chosen_clk = (ctrl_reg[0])? i_ext_clk : i_clk ;
assign o_pwm = (ctrl_reg[1])? pwm_out : o_irq ;
assign pwm_rst = i_rst || ctrl_reg[7] ;
assign timer_core_EN = ctrl_reg[2] & (~ctrl_reg[1]) & (ctrl_reg[4]); //bit2 counter EN ,bit1 timer mode bit4 o_pwm EN

//modules instantiation
//wb module
wb_interface  wb (
    .i_wb_clk(i_clk),                
    .i_wb_rst(i_rst),                
    .i_wb_cyc(i_wb_cyc),                
    .i_wb_stb(i_wb_stb),                
    .i_wb_we(i_wb_we),                
    .i_wb_adr(i_wb_adr),        
    .i_wb_data(i_wb_data),         
    .o_wb_ack(o_wb_ack),           
    .o_reg_adr(adr),       
    .o_wb_data(i_data),       
    .o_reg_we(wrEN)              
);

//clock down module 
clock_down down_clk (
    .i_clk(chosen_clk),                               
    .i_rst(i_rst),                              
    .i_divisor(divisor_reg),                    
    .o_slow_clk(o_clk)                           
);

//pwm core module 
pwm_core pwm (
    .clk(o_clk) ,                    
    .rst(pwm_rst) ,                   
    .duty_sel(ctrl_reg[6]) ,             
    .pwm_core_EN(ctrl_reg[1]) ,        
    .main_counter_EN(ctrl_reg[2]) ,    
    .o_pwm_EN(ctrl_reg[4]) ,         
    .period_reg(period_reg) ,
    .duty_reg(duty_reg) , 
    .i_DC(i_DC) ,    
    .i_DC_valid(i_DC_valid) ,     
    .o_pwm(pwm_out)    
);

//timer module 
timer_core timer(
    .i_clk(o_clk),                       
    .i_rst(pwm_rst),                       
    .i_timer_core_en(timer_core_EN),             
    .i_cont(ctrl_reg[3]),                      
    .i_irq_clear(ctrl_reg[5]),                 
    .i_period(period_reg),            
    .o_irq(o_irq)       
);

//reg file module 
RegFile8x16 regfile (
    .clk(i_clk),
    .rst(i_rst),                         
    .wrEN(wrEN),                       
    .address(adr), 
    .wrData(i_data) 
);
endmodule


// wb_interface Module

///////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// kareem.ash05@gmail.com
// 01002321067
// github.com/kareem05-ash
///////////////////////////////////////////////////////////
module wb_interface#
(
    parameter base_adr = 16'h0000,      //base address
    parameter ctrl_spacing = 0,         //ctrl reg address : base_adr + ctrl_spacing
    parameter divisor_spacing = 2,      //divisor reg address : base_adr + divisor_spacing
    parameter period_spacing = 4,       //period reg address : base_adr + period_spacing
    parameter DC_spacing = 6            //DC reg address : base_adr + DC_spacing
)
(
    // Inputs
    input wire i_wb_clk,                //system active-high clk
    input wire i_wb_rst,                //system async. active-high reset
    input wire i_wb_cyc,                //should set to start any process
    input wire i_wb_stb,                //should set to start a single process
    input wire i_wb_we,                 //1:write process, 0:read process
    input wire [15:0] i_wb_adr,         //address used for read/write process
    input wire [15:0] i_wb_data,        //input data to be written 
    // Outputs
    output reg o_wb_ack,                //indication of process completion (set for one i_wb_clk cycle)
    output reg [15:0] o_reg_adr,        //address to choose between registers (ctrl, divisor, period, & dc)
    output reg [15:0] o_wb_data,        //data to be written in reg_file
    output reg o_reg_we                 //write enable to write on reg_file
);
    // Neede internal signals

    //handling invalid address only (0, 2, 4, 6) are valid
    wire adr_valid = ((i_wb_adr == base_adr + ctrl_spacing)    ||   // ctrl
                      (i_wb_adr == base_adr + divisor_spacing) ||   // divisor
                      (i_wb_adr == base_adr + period_spacing)  ||   // period
                      (i_wb_adr == base_adr + DC_spacing));         // DC

    // Slave WB logic
    always@(posedge i_wb_clk or posedge i_wb_rst)
        begin
            if(i_wb_rst)
                begin   //reset all outputs
                    o_wb_ack <= 1'b0;
                    o_reg_adr <= 16'h0000;
                    o_reg_we <= 1'b0;
                    o_wb_data <= 0;
                end
            else
                begin
                    if(i_wb_cyc && i_wb_stb && adr_valid)
                        begin
                            //address decoding
                            o_reg_adr <= i_wb_adr;      
                            //write operation    
                            if(i_wb_we)     
                                begin
                                    o_wb_data <= i_wb_data;
                                    o_reg_we <= 1;          //enable write operation
                                    o_wb_ack <= 1;          //indicates complete operation
                                end
                        end
                end
        end 
endmodule

// reg_file Module


module RegFile8x16 #
(   // Parameters
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter addressbits = 16 
)
(   // Inputs
    input clk,
    input rst,                          //active low rst to reset all regs to 0
    input wrEN,                         //signal to write to a specified reg
    input [addressbits-1:0] address,    //address of the desired reg
    input [DEPTH-1:0] wrData            //data to be writen to a reg
);

    reg [WIDTH-1:0] REG [DEPTH-1:0] ;       //actual stored regs
    integer k;
    always @(posedge clk ,posedge rst)begin
        if (rst) begin //set all regs to 0
            for ( k = 0 ; k < DEPTH ;k = k + 1)begin 
                REG[k] <= 'b0;
            end
        end
        else begin 
            if (wrEN)begin //write to a reg
                REG[address] <= wrData;
            end
        end
    end

endmodule

// pwm_core Module

module pwm_core(
    input clk ,                    //clk from clk down either external clk or wb clk
    input rst ,                   //total pwm core rst i_rst or ctrl bit 7
    input duty_sel ,             //ctrl bit 6 to select external duty or the registerd one
    input pwm_core_EN ,         //ctrl bit 1 if high then pwm is enabled
    input main_counter_EN ,    //ctrl bit 2 
    input o_pwm_EN ,          //ctrl bit 4
    input [15:0] period_reg ,//reg have the required output clk period
    input [15:0] duty_reg , //reg have the required output clk duty
    input [15:0] i_DC ,    //external duty cycle input
    input i_DC_valid ,    //signal high when a valid duty is input 
    output reg o_pwm     //the output modulated clk
);
//pwm core internal signals
reg [15:0] pwm_duty ;
reg [15:0] counter ; //main 16 bit counter

    //duty selection
        always @(*)begin
            //if ctrl bit 6 is set choose external duty
            if (duty_sel && i_DC_valid) pwm_duty = i_DC ;
            else pwm_duty = duty_reg ;
        end

//modulated duty output clk logic
    always @(posedge clk or posedge rst) begin
        if (rst || !pwm_core_EN) begin  //stay in reset while this mode is not enabled 
            counter <= 16'd0;
            o_pwm <= 1'b0;
        end else if(main_counter_EN & o_pwm_EN) begin 
                    if (pwm_duty < period_reg ) begin
                        if (counter < period_reg - 1 )
                            counter <= counter + 1;
                        else
                            counter <= 16'd0;

                        o_pwm <= (counter < pwm_duty) ? 1'b1 : 1'b0;
                    end
                    else o_pwm <= clk ;
        end
    end
endmodule

// timer_core Module

///////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// kareem.ash05@gmail.com
// 01002321067
// github.com/kareem05-ash
///////////////////////////////////////////////////////////
module timer_core
(
    // Inputs
    input wire i_clk,                       // divided clk signal
    input wire i_rst,                       // async. active-high reset
    input wire i_timer_core_en,             // ~ctrl[1] & ctrl[2]
    input wire i_cont,                      // ctrl [3] continuous mode
    input wire i_irq_clear,                 // ctrl [5] (interrupt clear)
    input wire [15:0] i_period,             // reg period
    // Outputs 
    output reg o_irq                        // Interrupt outupt
);

    reg [15:0] count;                       // Internal main counter
    reg [15:0] period_sync;                 // Syncronous poeriod reg
    reg one_shot = 0;                       // A register for (cont vs one-shot) handling

    // Syncronization of i_period reg
    always@(posedge i_clk)
        period_sync <= i_period;

    // timer core logic
    always@(posedge i_clk or posedge i_rst)
        begin
            if(i_rst || !i_timer_core_en)       // mode stays on reset while not enabled
                begin
                    o_irq <= 0;         // default value
                    one_shot <= 0;      // reg handles one-shot vs cont logic
                    count <= 16'd0;     // reset the counter
                end
            else    
                begin
                    // highest priority
                    if(!i_irq_clear) 
                        begin
                            o_irq <= 0;     // dafault value
                            one_shot <= 0;  // to start new time cycle
                        end
                    // start counting logic
                    if(i_timer_core_en && !one_shot)
                        begin
                            if(count >= period_sync)
                                begin
                                    o_irq <= 1;     // interrupt flag
                                    count <= 16'd0; // reset counter
                                    if(!i_cont)
                                        one_shot <= 1;
                                end
                            else
                                // increment count if < period_sync
                                count <= count + 1;
                        end       
                end
        end
endmodule

// clock_down Module

///////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// kareem.ash05@gmail.com
// 01002321067
// github.com/kareem05-ash
///////////////////////////////////////////////////////////
module clock_down
(
    // inputs
    input wire i_clk,                               //active-high clk isgnal to be divided
    input wire i_rst,                               //async. active-high rst signal
    input wire [15:0] i_divisor,                    //divisor from reg_file
    // outputs
    output wire o_slow_clk                           //divided clk signal. It can be down clocked at most (1/(2^16 - 1)) of original frequency                       
);
    // internal signals needed
    wire zero_flag = i_divisor == 0;                //track zero ratio
    wire one_flag = i_divisor == 1;                 //track one ratio
    wire enable = (!zero_flag && !one_flag);        //set if i_divisor is greater than one. it can be implemented by (i_divisor > 1)
    wire odd_flag = i_divisor[0];                   //set if the i_divisor is odd to maintain unequal low and high levels in case of odd i_divisor
    wire [14:0] i_divisor_shifted = i_divisor >> 1; //floor the result of (i_divisor/2)
    reg [14:0] count;                               //counter counts i_clk cycles to handle division operation
    reg slow_clk ;


assign o_slow_clk = (zero_flag | one_flag )? i_clk : slow_clk ;

    // division logic block
    always@(posedge i_clk or posedge i_rst)
        begin
            if(i_rst)
                begin
                    count <= '0;                    //reset the counter
                    slow_clk <= 0;                //initialize the slow clk to avoid 'x' : unknown o_slow_clk signal output 
                end
            else if(enable)
                begin
                    if(!odd_flag && count == i_divisor_shifted-1)   //even ratio
                        begin
                            count <= '0;                            //reset the counter
                            slow_clk <= ~slow_clk;              //toggle o_slow_clk signal
                        end
                    else if(odd_flag)                               //odd ratio
                        begin
                            if(((count == i_divisor_shifted) && !slow_clk) || ((count == i_divisor_shifted-1) && slow_clk))
                                begin
                                    count <= '0;                    //reset the counter
                                    slow_clk <= ~slow_clk;      //toggle o_slow_clk signal    
                                end
                            else 
                                count <= count + 1;                 //increment the counter to reach the needed value
                        end
                    else    
                        count <= count + 1;                 //increment the counter to reach the needed value
                end
        end
endmodule
