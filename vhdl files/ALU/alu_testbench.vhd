LIBRARY work;
use work.alu_package.all;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;

ARCHITECTURE bhv OF testbench IS 
	
	SIGNAL reset                   	:  std_logic;
	SIGNAL alu_opcode              	:  alu_op;  --defined in alu_testbench
	SIGNAL register_a			   	: signed(31 DOWNTO 0);
	SIGNAL register_b			   	: signed(31 DOWNTO 0);
	SIGNAL register_out			   	: signed(31 DOWNTO 0);
	SIGNAL flags				   	: std_logic_vector(3 downto 0); -- on this moment 4 flags are enough but fur futher expansion 4 bits are reserved
	SIGNAL input1				   	: integer;
	SIGNAL input2				   	: integer;
	SIGNAL finished					: boolean 	:= FALSE;
	
		PROCEDURE check_adding (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer

		BEGIN
		WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
		register_a <= to_signed(a, register_a'length );
		register_b <= to_signed(b, register_b'length);
		WAIT FOR 1 ms;
		alu_opcode <= alu_add; --alu opcode for adding
		WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
		c  := to_integer(register_out);
		ASSERT c = (a+b) REPORT "adding went wrong" SEVERITY error;
		END check_adding; 


		PROCEDURE check_substract (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer

		BEGIN
		WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
		register_a <= to_signed(a, register_a'length );
		register_b <= to_signed(b, register_b'length);
		WAIT FOR 1 ms;
		alu_opcode <= alu_sub; --alu opcode for substract
		WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
		c  := to_integer(register_out);
		ASSERT c = (a-b) REPORT "the substract function went wrong" SEVERITY error;
		END check_substract; 
		
		
		PROCEDURE check_multiply (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_mul; --alu opcode for multiply
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			ASSERT c = (a*b) REPORT "multiply went wrong" SEVERITY error;
		END check_multiply;
		

	PROCEDURE check_and (
	  SIGNAL  a  : IN integer; -- variable a
	  SIGNAL  b  : IN integer; -- variable b
	  
	  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
	  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
	  SIGNAL alu_opcode   : OUT alu_op;
	  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
	IS
	VARIABLE  c  : integer; -- output integer
	BEGIN
		WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
		register_a <= to_signed(a, register_a'length );
		register_b <= to_signed(b, register_b'length);
		WAIT FOR 1 ms;
		alu_opcode <= alu_and; --alu opcode for and
		WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
		c  := to_integer(register_out);
		ASSERT to_signed(c, register_out'length) = (to_signed(a, register_out'length) and to_signed(b, register_out'length)) REPORT "and went wrong" SEVERITY error;
	END check_and; 
	

	PROCEDURE check_or (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_or; --alu opcode for or
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			ASSERT to_signed(c, register_out'length) = (to_signed(a, register_out'length) or to_signed(b, register_out'length)) REPORT "or went wrong" SEVERITY error;
		END check_or; 

	
	PROCEDURE check_xor (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_or; --alu opcode for xor
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			ASSERT to_signed(c, register_out'length) = (to_signed(a, register_out'length) xor to_signed(b, register_out'length)) REPORT "or went wrong" SEVERITY error;
		END check_xor;
		
	PROCEDURE check_sll	(
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_sll; --alu opcode for sll
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			ASSERT to_signed(c, register_out'length) = (shift_left( (to_signed(a, register_out'length)), b)) REPORT "or went wrong" SEVERITY error;
		END check_sll;
		
	PROCEDURE check_sra (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : OUT alu_op;
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_sra; --alu opcode for sra
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			ASSERT to_signed(c, register_out'length) = (shift_right(to_signed(a, register_out'length), b)) REPORT "or went wrong" SEVERITY error;
		END check_sra;

	PROCEDURE check_equal_flag (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : INOUT alu_op;
		  SIGNAL flags 		  : IN std_logic_vector(3 DOWNTO 0);
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_set_flag; --alu opcode for check_equal_flag
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			IF a = b THEN
				ASSERT flags = "1001" REPORT "check equal flag went wrong" SEVERITY error;
			ELSIF flags = "1001" THEN
				REPORT "flags for equal is set but numbers are not equal" SEVERITY error; 
			ELSE 
				REPORT "two unequal numbers are send to a check_equal_flag function" SEVERITY warning ;
			END IF ;
		END check_equal_flag;
	
	PROCEDURE check_unsigned_less_flag (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : INOUT alu_op;
		  SIGNAL flags 		  : IN std_logic_vector(3 DOWNTO 0);
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_set_flag; --alu opcode for xor
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			IF  (unsigned(to_signed(a, register_a'length)) < unsigned(to_signed(b, register_b'length)))  THEN
				ASSERT flags(1) = '1' REPORT "check unsigned less flag went wrong" SEVERITY error;
			ELSIF flags(1) = '1' THEN
				REPORT "flags for unsigned less is set but this not the case" SEVERITY error; 
			ELSE 
				REPORT "Number A is not smaller then number B (unsigned)" SEVERITY warning ;
			END IF ;
		END check_unsigned_less_flag; 
		
		PROCEDURE check_signed_flag (
		  SIGNAL  a  : IN integer; -- variable a
		  SIGNAL  b  : IN integer; -- variable b
		  
		  SIGNAL register_a   : INOUT signed(31 DOWNTO 0);
		  SIGNAL register_b   : INOUT signed(31 DOWNTO 0);
		  SIGNAL alu_opcode   : INOUT alu_op;
		  SIGNAL flags 		  : IN std_logic_vector(3 DOWNTO 0);
		  SIGNAL register_out :	IN signed(31 DOWNTO 0) )		  
		IS
		VARIABLE  c  : integer; -- output integer
		BEGIN
			WAIT FOR 1 ms; --gives time to update a. if this stament is remove a is not defined
			register_a <= to_signed(a, register_a'length );
			register_b <= to_signed(b, register_b'length);
			WAIT FOR 1 ms;
			alu_opcode <= alu_set_flag; --alu opcode for xor
			WAIT FOR 3 ms; --gives time to get output back 2 ms for clock time and 1 ms to update everything
			c  := to_integer(register_out);
			IF a < b THEN
				ASSERT flags(2) = '1' REPORT "signed less went wrong" SEVERITY error;
			ELSIF flags(2) = '1'THEN
				REPORT "flags for signed less were set but htis is not the case" SEVERITY error; 
			ELSE 
				REPORT "a is larger then b in check_signed function" SEVERITY warning ;
			END IF ;
		END check_signed_flag;
		
		
	
		


BEGIN
	
	tc: ENTITY work.alu 
		PORT MAP 
		(
			reset			=> reset,
			alu_opcode		=> alu_opcode,
			register_a		=> register_a,
			register_b 		=> register_b,
			register_out 	=> register_out,
			flags			=> flags
		);
	PROCESS
		BEGIN
			reset <= '0';
			WAIT FOR 1 ms;
			reset <='1';
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_adding(input1, input2, register_a, register_b, alu_opcode, register_out);
			WAIT FOR 4 ms;
			
			
			input1 <= 1;
			input2 <= 2;
			check_substract(input1, input2, register_a, register_b, alu_opcode, register_out);
			WAIT FOR 4 ms;
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_multiply(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_and(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_or(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_xor(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 7;
			check_sll(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			WAIT FOR 4 ms;
			input1 <= -1;
			input2 <= 7;
			check_sll(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			wait for 4 ms;
			input1 <= 16;
			input2 <= 2;
			check_sra(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			wait for 4 ms;
			input1 <= 16;
			input2 <= -2;
			check_sra(input1, input2, register_a, register_b, alu_opcode, register_out);
			
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 1;
			check_equal_flag(input1, input2, register_a, register_b, alu_opcode, flags, register_out);
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_unsigned_less_flag(input1, input2, register_a, register_b, alu_opcode, flags, register_out);
			
			WAIT FOR 4 ms;
			input1 <= 1;
			input2 <= 2;
			check_signed_flag(input1, input2, register_a, register_b, alu_opcode, flags, register_out);
			
			WAIT FOR 4 ms;
			input1 <= -2;
			input2 <= 1;
			check_signed_flag(input1, input2, register_a, register_b, alu_opcode, flags, register_out);
			
			WAIT FOR 4 ms;
			input1 <= 2;
			input2 <= 1;
			check_signed_flag(input1, input2, register_a, register_b, alu_opcode, flags, register_out);
			
			
			finished <= TRUE;
			WAIT;
		END PROCESS;
END bhv;