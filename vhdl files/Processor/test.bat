REM vmake work > makefile
make 
vsim -batch -quiet work.processor_testbench -do "test.do"
del "*.wlf"