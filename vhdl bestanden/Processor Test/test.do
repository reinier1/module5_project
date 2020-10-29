radix -hexadecimal
add wave processor_testbench/cu/rg/register_i 
run 100 ms
examine cpu/rg/register_i
examine {cpu/rg/register_i[3]}
mem save -format hex -outfile test.hex -start 8 -end 8 /cpu/rg/register_i 
exit