@echo off
REM vmake work > makefile
@echo on
wsl mod5asm test.s -o memory_package.vhd
@echo off 
make 
vsim -batch -quiet work.processor_testbench -do "test.do" >debug.txt
type test.hex
del "*.wlf"