vlib work
vlog pwm.v pwm_tb.v
vsim -voptargs=+acc work.pwm_tb
add wave *
run -all
#quit -sim