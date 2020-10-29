LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY top_level IS
	
END top_level;
ARCHITECTURE bhv OF top_level IS
	SIGNAL clk						: std_logic						:= '1';
	SIGNAL reset					: std_logic						:= '0';
	SIGNAL debug					: std_logic						:= '0';

	SIGNAL data_from_memory			: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL instruction_in			: std_logic_vector(31 DOWNTO 0)	:= x"00000000";

	SIGNAL read_enable_out			: std_logic;
	SIGNAL write_enable_out 		: std_logic;
	SIGNAL output_address			: std_logic_vector(13 DOWNTO 0);

	SIGNAL byte_enable 				: std_logic_vector( 3 DOWNTO 0);
	SIGNAL data_to_memory 			: std_logic_vector(31 DOWNTO 0);

	SIGNAL read_enable_instruction	: std_logic;
	SIGNAL instruction_address_out	: std_logic_vector(13 DOWNTO 0);

	SIGNAL finished				: boolean 	:= FALSE;
BEGIN
	clk <= not clk AFTER 500 us when not finished;
	cpu: ENTITY work.top_level_processor
		PORT MAP
		(
			clk						=> clk,
			reset					=> reset,
			debug					=> debug,
			data_from_memory		=> data_from_memory,
			
			instruction_in			=> instruction_in,
			
			read_enable_out			=> read_enable_out,
			write_enable_out 		=> write_enable_out,
			output_address			=> output_address,
			
			byte_enable 			=> byte_enable,
			data_to_memory 			=> data_to_memory,
			
			read_enable_instruction	=> read_enable_instruction,
			instruction_address_out	=> instruction_address_out
		);
		
	mem: ENTITY work.four_byte_enable_memory
		PORT MAP 
		(
			clk			=>  clk,	
			addr_a		=>  output_address,		
			addr_b		=>  instruction_address_out,		
			data_a		=>  data_to_memory,		
			we_a		=>  write_enable_out,		
									
			q_a			=>  data_from_memory,			
			q_b			=>  instruction_in,			
			byte_enable	=>  byte_enable
		);
	PROCESS
	BEGIN
		WAIT FOR 4 ms;
		reset<='1';
		WAIT FOR 2 sec;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;