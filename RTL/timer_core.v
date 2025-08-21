module timer_core (
    input chosen_clk ,
    input rst ,
    input core_en ,                //~ctrl[1] & ctrl[2]
    input out_en ,                //ctrl[4]
    input cont  ,                //ctrl[3] = 1 -> contineous mode , 0 -> oneshot mode
    input irq_bit ,             //ctrl[7] = 1 -> interrupt not cleared , 0 -> interruput cleared 
    input [15:0] period_reg ,  //time for irq 
    input [15:0] cnt ,        //main counter 
    output reg inter_bit ,   //ctrl[5] = 1 -> irq , 0 -> interrupt cleared    //! how should i write to the wb??
    output reg cnt_rst ,    //ctrl[7] to rest the counter                    //! how should i write to the wb??
    output reg irq         //interrupt when the counter reaches the period 
);

reg [15:0] int_period ; //interanl period

//syncronize period reg 
    always @(posedge chosen_clk or negedge rst)begin
        if(!rst)begin
            int_period <= 16'b0 ;
        end
        else begin
            int_period <= period_reg ;
        end
    end


    always @(posedge chosen_clk or negedge rst)begin
        if(!rst)begin
            irq <= 1'b0 ;
        end
        else if (core_en && out_en)begin
            if (cont | !irq_bit) begin 
                if (cnt == int_period)begin
                    irq <= 1'b1 ;
                    cnt_rst <= 1'b1 ;    //!this should be written to ctrl[7]
                    inter_bit <= 1'b1 ; //!this should be written to ctrl[7]
                end
                else irq <= 1'b0 ;
            end
        end
    end



endmodule