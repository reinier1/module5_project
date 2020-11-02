LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;
ARCHITECTURE bhv OF testbench IS 
	SIGNAL clk 		: std_logic := '0';
	SIGNAL reset 	: std_logic := '0';
	SIGNAL DATA     :  std_logic_vector(15 DOWNTO 0);
	SIGNAL sine_complete  :  std_logic;
	SIGNAL  next_value : std_logic;
	SIGNAL finished	:  boolean 	:= FALSE;


BEGIN
	clk<= not clk AFTER 1 ms when not finished;
	tc: ENTITY work.sinegen
		PORT MAP 
		(
			clk				=> clk,
			reset			=> reset,
			next_value		=> next_value,
			sine_complete	=> sine_complete,
			DATA => DATA
		);
	PROCESS
	BEGIN
		WAIT FOR 10 ms;
		reset<='1';
		WAIT FOR 12 ms;
		for I in 0 to 128 loop --two sines 
			next_value<='1';
			WAIT UNTIL rising_edge(clk);
			WAIT FOR  500 us;
			next_value <='0';
			WAIT for 20 ms;
		end loop;	
		for I in 0 to 128 loop --two sines but now faster
			next_value<='1';
			WAIT UNTIL rising_edge(clk);
			WAIT FOR  500 us;
			next_value <='0';
			WAIT for 10 ms;
		end loop;	
		WAIT FOR 10 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;