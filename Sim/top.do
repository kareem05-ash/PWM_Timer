vlib work
vlog top.v top_tb.v
vsim -voptargs=+acc work.top_tb
add wave *
add wave DUT/counter
add wave DUT/wb_slave_inst/regfile
run -all
#quit -sim