radix -hexadecimal
add wave processor_testbench/cu/rg/register_i 
run 100 ms
examine cu/rg/register_i
examine {cu/rg/register_i[3]}
mem save -format hex -outfile test.hex -start 3 -end 3 /cu/rg/register_i 
exit