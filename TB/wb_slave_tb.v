//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kareem Ashraf Mostafa
// Digital IC Design & Verification
// Junior EECE Student @ Cairo University
// kareem.ash05@gmail.com
// +201002321067 / +201154398353
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module wb_slave_tb();
    // DUT Prameters
        parameter num_ch = 4;                       // number of channels
        parameter mem_width = 16;                   // word width stored in register file
        parameter mem_depth = 4 * num_ch;           // 4 entries (ctrl, period, divisor, DC) for each channel
        parameter adr_width = 16;                   // address width
    // DUT Inputs
        reg i_wb_clk;                               // clk signal from the host
        reg i_wb_rst;                               // async. active-high rst from the host
        reg i_wb_cyc;                               // indicates valid bus cycle
        reg i_wb_stb;                               // indicates valid data
        reg i_wb_we;                                // if set, write operation. if reset, read operation.
        reg [num_ch-1:0] irq_flag;                  // itrrupt flag from timer module
        reg [adr_width-1:0] i_wb_adr;               // address to write on it or read from it
        reg [mem_width-1:0] i_wb_data;              // input data to be written
    // DUT Outpus   
        wire o_wb_ack;                              // indicates successful transaction (read or write)
        wire [mem_width-1:0] o_wb_data;             // output data read from register file
    // Internal Signals 
        reg [15:0] data, adr;                       // internal register for assertions
        integer i;                                  // for loop counter
    // Local Parameters
        localparam clk_period = 20;
    // DUT Instantiation
        wb_slave #(
            .num_ch(num_ch),
            .mem_width(mem_width), 
            .mem_depth(mem_depth), 
            .adr_width(adr_width)
        )
        DUT(
            .i_wb_clk(i_wb_clk), 
            .i_wb_rst(i_wb_rst),
            .i_wb_cyc(i_wb_cyc), 
            .i_wb_stb(i_wb_stb), 
            .i_wb_we(i_wb_we), 
            .irq_flag(irq_flag),
            .i_wb_adr(i_wb_adr), 
            .i_wb_data(i_wb_data), 
            .o_wb_ack(o_wb_ack), 
            .o_wb_data(o_wb_data)
        );
    // i_wb_clk Generation
        initial begin
            i_wb_clk = 0;   
            forever #(clk_period/2) i_wb_clk = ~i_wb_clk;
        end
    // TASKs
        // reset task
            task reset(); begin
                i_wb_rst = 1;           // apply rst
                i_wb_cyc = 0;           // default value
                i_wb_stb = 0;           // default value
                i_wb_we = 0;            // default value
                irq_flag = 0;           // default value
                i_wb_adr = 0;           // default value
                i_wb_data = 0;          // default value
                @(negedge i_wb_clk);    // waits for a clk cycle to track rst signal
                i_wb_rst = 0;           // release rst
            end
            endtask
        // write task
            task write(input[adr_width-1:0] adr, input[mem_width-1:0] data);begin
                // Data Assignment
                    i_wb_cyc = 1;                   // valid cycle
                    i_wb_stb = 1;                   // valid proccess
                    i_wb_we = 1;                    // enables write operation
                    i_wb_adr = adr;                 // address decoding
                    i_wb_data = data;               // data to be written
                    @(negedge i_wb_clk);            // waits for a clc cycle to capture the data
                // Assertion
                    if(adr < mem_depth) begin        // valid address
                        if(DUT.regfile[adr] == data && o_wb_ack)
                                $display("[PASS] | regfile[%h] = %h, expected = %h, o_wb_ack = %d, expected = %d", adr, DUT.regfile[adr], data, o_wb_ack, 1'd1);
                        else    $display("[FAIL] | regfile[%h] = %h, expected = %h, o_wb_ack = %d, expected = %d", adr, DUT.regfile[adr], data, o_wb_ack, 1'd1);
                    end else begin                  // invalid address
                        if(!o_wb_ack)
                                $display("[PASS] | in case of (i_wb_adr = %d) >= (mem_depth = %d): o_wb_ack = %d, expected = %d", i_wb_adr, mem_depth, o_wb_ack, 1'd0);
                        else    $display("[FAIL] | in case of (i_wb_adr = %d) >= (mem_depth = %d): o_wb_ack = %d, expected = %d", i_wb_adr, mem_depth, o_wb_ack, 1'd0);
                    end
            end
            endtask
        // write_read task
            task write_read(input[adr_width-1:0] adr, input[mem_width-1:0] data);begin
                // Write Data
                    i_wb_cyc = 1;                   // valid cycle
                    i_wb_stb = 1;                   // valid proccess
                    i_wb_we = 1;                    // enables write operation
                    i_wb_adr = adr;                 // address decoding
                    i_wb_data = data;               // data to be written
                    @(negedge i_wb_clk);            // waits for a clc cycle to capture the data
                //  Read Data
                    i_wb_we = 0;                    // enables read operation
                    @(negedge i_wb_clk);            // waits for a clc cycle to capture the data
                // Assertoin
                    if(o_wb_data == data && o_wb_ack)
                            $display("[PASS] | o_wb_data = %h, expected = %h, o_wb_ack = %d, expected = %d", o_wb_data, data, o_wb_ack, 1'd1);
                    else    $display("[FAIL] | o_wb_data = %h, expected = %h, o_wb_ack = %d, expected = %d", o_wb_data, data, o_wb_ack, 1'd1);
            end
            endtask
    // Stimulus
        initial begin
            // 1st scenario Functional Correctness (RESET behavior)
                $display("==================== 1st scenario Functional Correctness (RESET behavior) ====================");
                reset();
                if(!o_wb_ack && o_wb_data == 0) $display("[PASS] | o_wb_ack = %d, o_wb_data = %h", o_wb_ack, o_wb_data);
                else                            $display("[FAIL] | o_wb_ack = %d, o_wb_data = %h", o_wb_ack, o_wb_data);
            // 2nd scenario Functional Correctness (Write random data to all registers)
                $display("==================== 2nd scenario Functional Correctness (Write random data to all registers) ====================");
                reset();
                for(i=0; i<mem_depth; i=i+1) begin
                    adr = i;    data = $random;         // assign random
                    write(adr, data);
                end
            // 3rd scenario Functional Correctness (Read from all registers)
                $display("==================== 3rd scenario Functional Correctness (Read from all registers) ====================");
                reset();
                for(i=0; i<mem_depth; i=i+1) begin
                    adr = i;    data = $random;         // assign random
                    write_read(adr, data);
                end
            // 4th scenario Corner Case (i_wb_adr >= mem_depth)
                $display("==================== 4th scenario Corner Case (i_wb_adr >= mem_depth) ====================");
                reset();
                adr = mem_depth;    data = $random;     // assign random data to regfile[mem_depth] which isn't valid address
                write(adr, data);
                adr = mem_depth+5;  data = $random;     // assign random data to regfile[mem_depth+5] which isn't valid address
                write(adr, data);
            // STOP Simulation
                $display("==================== STOP Simulation ====================");
                #100;
                $stop;
        end
endmodule