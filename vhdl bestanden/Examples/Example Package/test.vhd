library work;
use work.alu_package.all;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;

ARCHITECTURE bhv OF testbench IS 
	SIGNAL clk 		: std_logic := '0';
	SIGNAL alu		: alu_op := alu_add;
BEGIN
	clk<= not clk AFTER 500 ms;
	PROCESS
	BEGIN
		alu<=alu_add;
		WAIT FOR 1 sec;
		alu<=alu_sub;
		WAIT FOR 1 sec;
		alu<=alu_mul;
		WAIT FOR 1 sec;
		alu<=alu_or;
		WAIT FOR 1 sec;
		alu<=alu_and;
		WAIT FOR 1 sec;
		alu<=alu_xor;
		WAIT FOR 1 sec;
		alu<=alu_sra;
		WAIT FOR 1 sec;
		alu<=alu_sla;
		WAIT FOR 1 sec;
		alu<=alu_move;
		WAIT FOR 1 sec;
		alu<=alu_eq;
		WAIT FOR 1 sec;
		alu<=alu_ne;
		WAIT FOR 1 sec;
		alu<=alu_lt;
		WAIT FOR 1 sec;
		alu<=alu_ltu;
		WAIT FOR 1 sec;
		alu<=alu_dont_care;
		ASSERT FALSE REPORT "done" SEVERITY note;
		WAIT;
	END PROCESS;
END bhv;