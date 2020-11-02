library work;
use work.alu_package.all;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.math_real.ALL;
USE ieee.numeric_std.ALL; 
 -- This is the code for the alu. 
 -- It support commands that are defined in the alu_package. And it can return the following flags
 -- flag(0) high means A and B are equal.
 -- flag(1) high means absolute value of A is smaller then the absolute value of B
 -- flag(2) high means A is smaller then B
 -- flag(3) low means Alu not working

ENTITY alu IS
  PORT( 
         reset                   : IN std_logic;
         alu_opcode              : IN alu_op;  --there are on this moment 3 bits necessary but the fourth when is for extra comments
	     register_a			     : IN signed(31 DOWNTO 0);
		 register_b			     : IN signed(31 DOWNTO 0);
	     register_out			 : OUT signed(31 DOWNTO 0);
		 flags					 : OUT std_logic_vector(3 downto 0) -- on this moment 4 flags are enough but for futher expansion 4 bits are reserved
	  ); 
END alu;
ARCHITECTURE bhv OF alu IS
	
BEGIN 
	PROCESS (register_a, register_b, alu_opcode, reset)
		
	BEGIN
		IF reset = '0' THEN
			register_out <= ( OTHERS => '0');
			flags <= (OTHERS => '0'); -- no flags set
			
		ELSE
			--Alu commands are defined in the alu package
			CASE alu_opcode IS          
				WHEN alu_add => register_out <= (register_a + register_b);
				WHEN alu_sub => register_out <= (register_a - register_b);
				WHEN alu_mul => register_out <= (resize((register_a * register_b), 32));
				WHEN alu_and => register_out <= (register_a and register_b);
				WHEN alu_or => register_out <= (register_a or register_b);
				WHEN alu_xor => register_out <= (register_a xor register_b);
				WHEN alu_sll => register_out <=  signed(shift_left((  unsigned(register_a)), to_integer(register_b)));-- shift_left works a bit strange. Also it is shift left logically. 
				-- B can be negative and in that case it works as srl
				WHEN alu_sra => register_out <= shift_right(register_a, to_integer(register_b)); --b can be negative and then it works as sla
				WHEN alu_set_flag => register_out <= register_a;
				WHEN alu_move => register_out <= register_b;
				
				
			END CASE;
			--with the following flags setting the control only has to check 1 bit at the time
			IF (register_a = register_b) THEN --for branch equal
				flags <= "1001";
			
			ELSE
				flags(0) <= '0';
				flags(3) <= '1';
				IF (unsigned(register_a) < unsigned(register_b)) THEN --for branch unsigned less
					flags(1) <= '1';
				ELSE 
					flags(1) <= '0';
				END IF;
				IF (register_a < register_b) THEN --for branch signed less THEN
					flags(2) <= '1';
				ELSE 
					flags(2) <= '0';
				END IF;
			END IF; 
		END IF;
	END PROCESS;
	
	
END bhv;