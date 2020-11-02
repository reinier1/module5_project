LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench_top_level IS
END testbench_top_level;
ARCHITECTURE appel OF testbench_top_level IS 

	SIGNAL clk 			: std_logic := '1';
	SIGNAL reset 		: std_logic := '0';
	SIGNAL debug		: std_logic := '0';
	
	SIGNAL KEY			: std_logic_vector(1 DOWNTO 0):="11";
	SIGNAL SW			: std_logic_vector(7 DOWNTO 0):="00011000";
			
	SIGNAL HEX0			: std_logic_vector(7 DOWNTO 0);
	SIGNAL HEX1			: std_logic_vector(7 DOWNTO 0);
	SIGNAL HEX2			: std_logic_vector(7 DOWNTO 0);
	SIGNAL HEX3			: std_logic_vector(7 DOWNTO 0);
	SIGNAL HEX4			: std_logic_vector(7 DOWNTO 0);
	SIGNAL HEX5			: std_logic_vector(7 DOWNTO 0);
		
	SIGNAL LEDR			: std_logic_vector(9 DOWNTO 0);
	SIGNAL finished		:  boolean 	:= FALSE;
	
	SIGNAL keys			: std_logic_vector(9 DOWNTO 0);
	
BEGIN
	keys <= debug & reset & SW;
	clk <= not clk AFTER 500 us when not finished; 
	tld: ENTITY work.top_level_DE10
	PORT MAP
	(
		MAX10_CLK1_50 		=> clk,
		
		KEY				=> KEY,
		SW				=> keys,
			
		HEX0			=> HEX0,
		HEX1			=> HEX1,
		HEX2			=> HEX2,
		HEX3			=> HEX3,
		HEX4			=> HEX4,
		HEX5			=> HEX5,
			
		LEDR			=> LEDR
	);
	PROCESS		
		BEGIN
		WAIT FOR 10 ms;
		reset <='1';
		WAIT FOR 20 ms;
		KEY <="00";
		SW <=x"02";
		WAIT FOR 1 sec;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished		<=TRUE;
		WAIT;
	END PROCESS;
	
END appel;