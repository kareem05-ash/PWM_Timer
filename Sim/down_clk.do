vlib work
vlog down_clk.v down_clk_tb.v
vsim -voptargs=+acc work.down_clk_tb
add wave *
run -all
#quit -sim