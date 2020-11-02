@echo off
REM vmake work > makefile
@echo on
wsl dcc -m=mod5 test.c -o memory_package.vhd
@echo off 
make 
vsim -batch -quiet work.processor_testbench -do "test.do" >debug.txt
type test.hex
del "*.wlf"