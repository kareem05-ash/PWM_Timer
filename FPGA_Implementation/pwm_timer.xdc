## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports i_wb_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_wb_clk]

## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports i_extclk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_extclk]

## Switches
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[0]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[1]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[2]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[3]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[4]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[5]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[6]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {i_wb_data[7]}]
set_property -dict {PACKAGE_PIN V2  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[8]}]
set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[9]}]
set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[10]}]
set_property -dict {PACKAGE_PIN R3  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[11]}]
set_property -dict {PACKAGE_PIN W2  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[12]}]
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[13]}]
set_property -dict {PACKAGE_PIN T1  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[14]}]
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports {i_wb_data[15]}].

##7 Segment Display
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {i_wb_cyc}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {i_wb_stb}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {i_wb_we}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {i_DC_valid}]

##Pmod Header JXADC
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[0]}];#Sch name = XA1_P
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[1]}];#Sch name = XA2_P
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[2]}];#Sch name = XA3_P
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[3]}];#Sch name = XA4_P
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[4]}];#Sch name = XA1_N
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[5]}];#Sch name = XA2_N
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[6]}];#Sch name = XA3_N
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[7]}];#Sch name = XA4_N

##Pmod Header JA
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[8]}];#Sch name = JA1
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[9]}];#Sch name = JA2
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[10]}];#Sch name = JA3
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[11]}];#Sch name = JA4
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[12]}];#Sch name = JA7
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[13]}];#Sch name = JA8
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[14]}];#Sch name = JA9
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {i_wb_adr[15]}];#Sch name = JA10
##Buttons
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports i_wb_rst]



##Pmod Header JB
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {i_DC[0]}];#Sch name = JB1
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {i_DC[1]}];#Sch name = JB2
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {i_DC[2]}];#Sch name = JB3
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {i_DC[3]}];#Sch name = JB4
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {i_DC[4]}];#Sch name = JB7
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {i_DC[5]}];#Sch name = JB8
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {i_DC[6]}];#Sch name = JB9
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {i_DC[7]}];#Sch name = JB10

##Pmod Header JC
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {i_DC[8]}];#Sch name = JC1
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {i_DC[9]}];#Sch name = JC2
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {i_DC[10]}];#Sch name = JC3
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {i_DC[11]}];#Sch name = JC4
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports {i_DC[12]}];#Sch name = JC7
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {i_DC[13]}];#Sch name = JC8
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {i_DC[14]}];#Sch name = JC9
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {i_DC[15]}];#Sch name = JC10

## LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {o_wb_data[8]}]
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[9]}]
set_property -dict {PACKAGE_PIN W3  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[10]}]
set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[11]}]
set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[12]}]
set_property -dict {PACKAGE_PIN N3  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[13]}]
set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[14]}]
set_property -dict {PACKAGE_PIN L1  IOSTANDARD LVCMOS33} [get_ports {o_wb_data[15]}]


set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {o_wb_ack}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {o_pwm}]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]