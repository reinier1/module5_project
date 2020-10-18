LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;

ARCHITECTURE bhv OF testbench IS 
	SIGNAL key : std_logic_vector(7 DOWNTO 0);
	SIGNAL output : integer;
BEGIN
	tc: ENTITY work.key2pulselength 
		PORT MAP 
		(
			key	=> key,
			pulse_length => output
		);
	PROCESS
	BEGIN
		FOR i in 0 TO 100 LOOP
			key<=std_logic_vector(to_unsigned(i,8));
			wait for 1 ns;
		END LOOP;
		ASSERT FALSE REPORT "done" SEVERITY note;
		WAIT;
	END PROCESS;
END bhv;