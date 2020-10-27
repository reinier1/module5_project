LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY debug_testbench IS
END debug_testbench;
ARCHITECTURE koe_of_paard OF debug_testbench IS 
	
	SIGNAL clk 			: std_logic 								:= '0';
	SIGNAL dip0			: std_logic 								:= '0';
	SIGNAL dip1			: std_logic 								:= '0';
	SIGNAL dip2			: std_logic 								:= '0';
	SIGNAL dip3			: std_logic 								:= '0';
	SIGNAL dip4			: std_logic 								:= '0';
	SIGNAL dip5			: std_logic 								:= '0';
	SIGNAL dip6			: std_logic 								:= '0';
	SIGNAL dip7			: std_logic 								:= '0';
	SIGNAL key1			: std_logic 								:= '1';
	SIGNAL key2			: std_logic 								:= '1';
	SIGNAL key3			: std_logic 								:= '1';
	SIGNAL b_read		: std_logic 								;
	SIGNAL b_write		: std_logic 								;
	SIGNAL byte_in		: std_logic_vector(7 DOWNTO 0)				:= X"DA";
	SIGNAL byte_out		: std_logic_vector(7 DOWNTO 0);	
	SIGNAL address		: std_logic_vector(15 DOWNTO 0)				:= X"DADA";
	SIGNAL hex0			: std_logic_vector(6 DOWNTO 0)	;		
	SIGNAL hex1			: std_logic_vector(6 DOWNTO 0)	;		
	SIGNAL hex2			: std_logic_vector(6 DOWNTO 0)	;		
	SIGNAL hex3			: std_logic_vector(6 DOWNTO 0)	;			
	SIGNAL hex4			: std_logic_vector(6 DOWNTO 0)	;			
	SIGNAL hex5			: std_logic_vector(6 DOWNTO 0)	;			
	
	SIGNAL finished		: boolean 	:= FALSE;
BEGIN
	clk<= not clk AFTER 1 ms when not finished;
	mem: ENTITY work.debug
		PORT MAP 
		(
		clk		=> clk,
		dip0	=> dip0,
		dip1	=> dip1,
		dip2	=> dip2,
		dip3	=> dip3,
		dip4	=> dip4,
		dip5	=> dip5,
		dip6	=> dip6,
		dip7	=> dip7,
		key1	=> key1,
		key2	=> key2,
		key3	=> key3,
		byte_in	=> byte_in,
		byte_out=> byte_out,
		b_read	=> b_read,
		b_write	=> b_write,
		address	=> address,
		hex0	=> hex0,
		hex1	=> hex1,
		hex2	=> hex2,
		hex3	=> hex3,
		hex4	=> hex4,
		hex5	=> hex5
		);
	PROCESS
	BEGIN
		WAIT FOR 10 ms;
		key3 <= '0';
		WAIT FOR 10 ms;
		key3 <= '1';
		WAIT FOR 10 ms;
		dip0 <= '1';
		dip3 <= '1';
		dip6 <= '1';
		WAIT FOR 4 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		dip0 <= '0';
		dip3 <= '0';
		dip6 <= '0';
		dip1 <= '1';
		dip2 <= '1';
		dip4 <= '1';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		WAIT FOR 15 ms;
		
		dip1 <= '0';
		dip2 <= '0';
		dip4 <= '0';
		dip1 <= '1';
		byte_in <= X"AD";
		WAIT FOR 10 ms;
		key3 <= '0';
		WAIT FOR 10 ms;
		key3 <= '1';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		WAIT FOR 15 ms;
		
		dip1 <= '0';
		dip0 <= '1';
		WAIT FOR 10 ms;
		key3 <= '0';
		WAIT FOR 10 ms;
		key3 <= '1';
		dip7 <= '1';
		dip6 <= '1';
		dip5 <= '1';
		dip2 <= '1';
		dip1 <= '1';
		dip0 <= '1';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		dip7 <= '0';
		dip6 <= '0';
		dip5 <= '1';
		dip2 <= '0';
		dip1 <= '1';
		dip0 <= '0';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		dip7 <= '1';
		dip6 <= '0';
		dip5 <= '0';
		dip2 <= '0';
		dip1 <= '0';
		dip0 <= '1';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		WAIT FOR 15 ms;
		
		dip0 <= '1';
		dip1 <= '1';
		dip7 <= '0';
		WAIT FOR 10 ms;
		key3 <= '0';
		WAIT FOR 10 ms;
		key3 <= '1';
		dip4 <= '0';
		dip6 <= '1';
		dip5 <= '1';
		dip2 <= '1';
		WAIT FOR 10 ms;
		key2 <= '0';
		WAIT FOR 10 ms;
		key2 <= '1';
		WAIT FOR 15 ms;
				
		WAIT FOR 10 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END koe_of_paard;