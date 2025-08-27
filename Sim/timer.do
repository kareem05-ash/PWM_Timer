vlib work
vlog timer.v timer_tb.v
vsim -voptargs=+acc work.timer_tb
add wave *
run -all
#quit -sim