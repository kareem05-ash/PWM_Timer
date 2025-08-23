vlib work
vlog main_counter.v main_counter_tb.v
vsim -voptargs=+acc work.main_counter_tb
add wave *
run -all
#quit -sim