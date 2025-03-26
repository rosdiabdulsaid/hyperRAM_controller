## Generated SDC file "top.out.sdc"

## Copyright (C) 2024  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 23.1std.1 Build 993 05/14/2024 SC Standard Edition"

## DATE    "Tue Mar 18 15:37:12 2025"

##
## DEVICE  "10CL025YU256I7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {refclk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {refclk}]
create_clock -name {rwds} -period 8.000 -waveform { 0.000 4.000 } [get_ports {rwds}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_clk} -source [get_pins {pll2_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -master_clock {refclk} [get_pins {pll2_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {pll_clk90} -source [get_pins {pll2_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -phase 90 -master_clock {refclk} [get_pins {pll2_inst|altpll_component|auto_generated|pll1|clk[1]}]
#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {csn}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[0]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[1]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[2]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[3]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[4]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[5]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[6]}]
set_output_delay -add_delay -rise -max -clock [get_clocks {clock}]  1.000 [get_ports {dq[7]}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

