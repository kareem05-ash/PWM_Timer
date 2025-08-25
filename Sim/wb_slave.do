vlib work
vlog wb_slave.v wb_slave_tb.v
vsim -voptargs=+acc work.wb_slave_tb
add wave *
run -all
#quit -sim