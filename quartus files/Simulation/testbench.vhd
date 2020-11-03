LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench_top_level IS
END testbench_top_level;
ARCHITECTURE appel OF testbench_top_level IS 

	SIGNAL clk 			: std_logic := '1';
	SIGNAL reset 		: std_logic := '0';
	SIGNAL debug		: std_logic := '0';
	
	SIGNAL KEY			: std_logic_vector(2 DOWNTO 0):="111";
	SIGNAL SW			: std_logic_vector(8 DOWNTO 0):="000011000";
			
	SIGNAL HEX0			: std_logic_vector(6 DOWNTO 0);
	SIGNAL HEX1			: std_logic_vector(6 DOWNTO 0);
	SIGNAL HEX2			: std_logic_vector(6 DOWNTO 0);
	SIGNAL HEX3			: std_logic_vector(6 DOWNTO 0);
	SIGNAL HEX4			: std_logic_vector(6 DOWNTO 0);
	SIGNAL HEX5			: std_logic_vector(6 DOWNTO 0);
		
	SIGNAL LEDR			: std_logic_vector(9 DOWNTO 0);
	
	SIGNAL keys			: std_logic_vector(9 DOWNTO 0);
	SIGNAL KEY_intern	: std_logic_vector(3 DOWNTO 0);
	
BEGIN
	keys 		<= debug & SW;
	KEY_intern	<= KEY & reset;
	clk 		<= not clk AFTER 500 us;
	tld: ENTITY work.top_level
	PORT MAP
	(
		CLOCK_50 		=> clk,
		
		KEY				=> KEY_intern,
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
		reset 		<='1';
		WAIT FOR 20 ms;
		KEY 		<="000";
		SW			<='0' & x"02";
	END PROCESS;
	
END appel;