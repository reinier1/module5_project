vsim -t ms -gui work.testbench_top_level
add wave clk
add wave reset
add wave debug
add wave SW
add wave KEY
add wave LEDR
add wave -radix hexadecimal HEX* 
add wave -radix hexadecimal tld/instruction_address_out 
add wave -radix hexadecimal tld/instruction_in 
add wave -radix hexadecimal tld/output_address 
add wave tld/byte_enable
add wave -radix hexadecimal tld/data_from_memory 
add wave -radix hexadecimal tld/data_to_memory 
add wave -radix hexadecimal tld/cpu/rg/register_i
run 1 sec