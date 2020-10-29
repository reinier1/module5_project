LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench_top_level_debug IS
END testbench_top_level_debug;
ARCHITECTURE appel OF testbench_top_level_debug IS 

	SIGNAL clk 				:  std_logic := '1'  ;
	SIGNAL reset				:  std_logic := '0';			
	SIGNAL addr_a_outm			:  std_logic_vector(13 DOWNTO 0); -- address to memory
	SIGNAL addr_b_outm			:  std_logic_vector(13 DOWNTO 0);
	SIGNAL data_a_outm			:  std_logic_vector(31 DOWNTO 0);
	SIGNAL we_a_outm			:  std_logic := '1' ;
	SIGNAL q_a_inm				:  std_logic_vector((31) DOWNTO 0); -- input from memory
	SIGNAL q_b_inm				:  std_logic_vector((31) DOWNTO 0);
	SIGNAL byte_enable_outm	:  std_logic_vector(3 DOWNTO 0);
	
	SIGNAL addr_a_inm			:  std_logic_vector(15 DOWNTO 0);
	SIGNAL addr_b_inm			:  std_logic_vector(15 DOWNTO 0);
	SIGNAL data_a_inm			:  std_logic_vector((31) DOWNTO 0);
	SIGNAL we_a_inm			:  std_logic := '1';
	SIGNAL q_a_outm			:  std_logic_vector((31) DOWNTO 0);
	SIGNAL q_b_outm			:  std_logic_vector((31) DOWNTO 0);
	SIGNAL byte_enable_inm		:  std_logic_vector(3 DOWNTO 0);
	
	SIGNAL dipswitches			:  std_logic_vector(9 DOWNTO 0);
	SIGNAL hex0				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL hex1				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL hex2				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL hex3				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL hex4				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL hex5				:  std_logic_vector(7 DOWNTO 0);
	SIGNAL leds				:  std_logic_vector(9 DOWNTO 0);
	SIGNAL buttons				:  std_logic_vector(2 DOWNTO 0);  -- buttons does not include reset button	
	SIGNAL debug_on_of_out			:  std_logic;
	SIGNAL finished			:  boolean 	:= FALSE;
	
BEGIN
	clk <= not clk AFTER 1 ms when not finished; 
	mem: ENTITY work.top_level_debug
	PORT MAP(
			clk  				=> clk,
			reset				=> reset,			
			addr_a_outm			=>addr_a_outm, -- address to memory
			addr_b_outm			=>addr_b_outm,
			data_a_outm			=>data_a_outm,
			we_a_outm			=> we_a_outm,
			q_a_inm				=> q_a_inm, -- input from memory
			q_b_inm				=> q_b_inm,
			byte_enable_outm 	=>byte_enable_outm,
			
			addr_a_inm			=>addr_a_inm(15 DOWNTO 2),
			addr_b_inm			=>addr_b_inm(15 DOWNTO 2),
			data_a_inm			=>data_a_inm,
			we_a_inm			=>we_a_inm,
			q_a_outm			=>q_a_outm,
			q_b_outm			=>q_b_outm,
			byte_enable_inm		=>byte_enable_inm,
			debug_on_of_out	    =>  debug_on_of_out, 
			dipswitches			=>dipswitches,
			hex0				=>hex0,
			hex1				=>hex1,
			hex2				=>hex2,
			hex3				=>hex3,
			hex4				=>hex4,
			hex5				=>hex5,
			leds				=>leds,
			buttons				=> buttons  -- buttons does not include reset button
			
	);
	PROCESS		
		BEGIN
		dipswitches(9) <= '0';
		dipswitches(8 DOWNTO 0) <= (others => '1');
		
		WAIT FOR 10 ms;
		reset			<='1';
		WAIT FOR 12 ms;
		
		we_a_inm		<='1';
		data_a_inm		<=x"DEADBEEF";
		WAIT FOR 4 ms;
		we_a_inm		<='0';
		WAIT FOR 4 ms;
		
		addr_a_inm		<=x"0013";
		we_a_inm		<='1';
		data_a_inm		<=x"f0f0f0f0";
		WAIT FOR 4 ms;
		we_a_inm		<='0';
		WAIT FOR 4 ms;
		addr_b_inm		<=x"0013";
		WAIT FOR 4 ms;
		
		addr_a_inm		<=x"0000";
		we_a_inm		<='1';
		byte_enable_inm	<="1010";
		data_a_inm		<=x"f0f0f0f0";
		WAIT FOR 4 ms;
		we_a_inm		<='0';
		WAIT FOR 4 ms;
		addr_b_inm		<=x"0000";
		WAIT FOR 4 ms;
		we_a_inm		<='1';
		data_a_inm 		<=x"FFFFFFFF";
		addr_a_inm 		<=x"FF00";
		byte_enable_inm	<="1111";
		buttons <= (others => '1');
		WAIT FOR 4 MS;
		
		we_a_inm		<='0';
		addr_b_inm <= x"FF08";
		WAIT FOR 6 ms;
		addr_b_inm <= x"FF04";
		WAIT FOR 6 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
	
END appel;