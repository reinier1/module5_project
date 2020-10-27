LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.memory_package.ALL;
ENTITY testbench IS
END testbench;
ARCHITECTURE bhv OF testbench IS 
	
	CONSTANT DATA_WIDTH : integer 	:= 32;
	
	SIGNAL clk 			: std_logic 								:= '0';
	SIGNAL reset 		: std_logic 								:= '0';
	SIGNAL we_a			: std_logic 								:= '0';
	SIGNAL byte_enable	: std_logic_vector(3 DOWNTO 0)				:= "1111";
	SIGNAL addr_a		: std_logic_vector(16-1 DOWNTO 0)			:= x"0000";
	SIGNAL addr_b		: std_logic_vector(16-1 DOWNTO 0)			:= x"0000";
	SIGNAL data_a		: std_logic_vector((DATA_WIDTH-1) DOWNTO 0)	:= x"00000000";
	SIGNAL q_a			: std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
	SIGNAL q_b			: std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
	
	SIGNAL finished	: boolean 	:= FALSE;
BEGIN
	clk <= not clk AFTER 1 ms when not finished;
	
	mem: ENTITY work.four_byte_enable_memory
		PORT MAP 
		(
			clk			=> clk,
			we_a		=> we_a,
			byte_enable	=> byte_enable,
			addr_a		=> addr_a(ADDR_WIDTH-1 DOWNTO 0),
			addr_b		=> addr_b(ADDR_WIDTH-1 DOWNTO 0),
			data_a		=> data_a,
			q_a			=> q_a,
			q_b			=> q_b
		);
	PROCESS
	BEGIN
		WAIT FOR 10 ms;
		reset		<='1';
		WAIT FOR 12 ms;
		
		we_a		<='1';
		data_a		<=x"DEADBEEF";
		WAIT FOR 4 ms;
		we_a		<='0';
		WAIT FOR 4 ms;
		
		addr_a		<=x"0013";
		we_a		<='1';
		data_a		<=x"f0f0f0f0";
		WAIT FOR 4 ms;
		we_a		<='0';
		WAIT FOR 4 ms;
		addr_b		<=x"0013";
		WAIT FOR 4 ms;
		
		addr_a		<=x"0000";
		we_a		<='1';
		byte_enable	<="1010";
		data_a		<=x"f0f0f0f0";
		WAIT FOR 4 ms;
		we_a		<='0';
		WAIT FOR 4 ms;
		addr_b		<=x"0000";
		
		WAIT FOR 10 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;