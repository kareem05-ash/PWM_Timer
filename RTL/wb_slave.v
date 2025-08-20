//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module wb_slave#
(   
    // Prameters
        parameter mem_width = 16,                   // word width stored in register file
        parameter mem_depth = 12,                   // 4 entries (ctrl, period, divisor, DC) for each channel
        parameter adr_width = 16                    // address width
)
(
    // Inputs
        input wire i_wb_clk,                        // clk signal from the host
        input wire i_wb_rst,                        // async. active-high rst from the host
        input wire i_wb_cyc,                        // indicates valid bus cycle
        input wire i_wb_stb,                        // indicates valid data
        input wire i_wb_we,                         // if set, write operation. if reset, read operation.
        input wire [adr_width-1:0] i_wb_adr,        // address to write on it or read from it
        input wire [mem_width-1:0] i_wb_data,       // input data to be written
    // Outpus
        output reg o_wb_ack,                        // indicates successful transaction (read or write)
        output reg [mem_width-1:0] o_wb_data        // output data read from register file
);

    // Internal Signals
        reg [mem_width-1:0] regfile [0:mem_depth-1];// register file internal memory
        integer i;                                  // for loop counter

    // Logic
        always@(posedge i_wb_clk or posedge i_wb_rst) begin
            if (i_wb_rst) begin
                // reset wishbone outputs
                    o_wb_ack <= 0;
                    o_wb_data <= 0; 
                // reset register file
                    for(i=0; i<mem_depth; i=i+1) begin
                        regfile[i] <= 0;            // set all registers to 0x00
                    end
            end else if(i_wb_cyc && i_wb_stb && (i_wb_adr < mem_depth)) begin
                // write operation
                    if(i_wb_we) begin                   
                        regfile[i_wb_adr] <= i_wb_data; 
                        o_wb_ack <= 1;              // indicates write operation's done successfully
                // read operation
                    end else begin                      
                        o_wb_data <= regfile[i_wb_adr];
                        o_wb_ack <= 1;              // indicates read operation's done successfully
                    end 
            end else begin
                o_wb_ack <= 0;                      // deassert ack while no write or read operation
            end
        end
endmodule