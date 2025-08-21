module main_counter (
    input slow_clk ,           //clk from the down clock block
    input rst ,               //system rest
    input soft_rst ,         //ctrl[7]
    input Enable ,          //ctrl[2]  
    output reg [15:0] cnt  //16 bit main counter
);

always @(posedge slow_clk or posedge rst or posedge soft_rst) begin
    if(rst | soft_rst) begin
        cnt <= 16'b0 ;
    end
    else if (Enable)begin
        cnt <= cnt + 1 ;
    end
end

endmodule 
