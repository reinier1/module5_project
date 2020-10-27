LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;
ARCHITECTURE bhv OF testbench IS 
	
	CONSTANT DATA_WIDTH : integer 	:= 32;
	
	SIGNAL byte 				: std_logic						:= '0';
	SIGNAL write_enable 		: std_logic						:= '0';
	SIGNAL read_enable 			: std_logic						:= '0';
	SIGNAL address 				: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL data_from_processor 	: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL data_from_memory		: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
		  
	SIGNAL read_enable_out		: std_logic;
	SIGNAL write_enable_out 	: std_logic;
	SIGNAL output_address		: std_logic_vector(13 DOWNTO 0);
				
	SIGNAL byte_enable 			: std_logic_vector( 3 DOWNTO 0);
	SIGNAL data_to_processor 	: std_logic_vector(31 DOWNTO 0);
	SIGNAL data_to_memory 		: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL finished	: boolean 	:= FALSE;
BEGIN
	mc: ENTITY work.memory_controller
		PORT MAP 
		(
			byte 				=> byte,
			write_enable 		=> write_enable,
			read_enable 		=> read_enable,
			address 			=> address,
			data_from_processor => data_from_processor,
			data_from_memory	=> data_from_memory,
													
			read_enable_out		=> read_enable_out,
			write_enable_out 	=> write_enable_out,
			output_address		=> output_address,
								 					
			byte_enable 		=> byte_enable,
			data_to_processor 	=> data_to_processor,
			data_to_memory 		=> data_to_memory
		);
	PROCESS
	BEGIN
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '0';
		byte				<= '0';
		address 			<= x"12345678";
		data_from_processor <= x"deadbeef";
		data_from_memory	<= x"F00FF00F";
		WAIT FOR 1 ms;
		
		write_enable		<= '1';
		read_enable			<= '0';
		byte				<= '0';
		address 			<= x"98765432";
		data_from_processor <= x"F00FF00F";
		data_from_memory	<= x"deadbeef";
		WAIT FOR 1 ms;
		
		write_enable		<= '1';
		read_enable			<= '0';
		byte				<= '1';
		address 			<= x"12345678";
		data_from_processor <= x"F00FF03C";
		data_from_memory	<= x"deadbeef";
		WAIT FOR 1 ms;
		
		write_enable		<= '1';
		read_enable			<= '0';
		byte				<= '1';
		address 			<= x"12345673";
		data_from_processor <= x"F00FF05e";
		data_from_memory	<= x"deadbeef";
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '1';
		byte				<= '0';
		address 			<= x"02468ACE";
		data_from_processor <= x"0FF00FF0";
		data_from_memory	<= x"feebdaed";
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '1';
		byte				<= '1';
		address 			<= x"02468AC0";
		data_from_processor <= x"0FF00FF0";
		data_from_memory	<= x"00000080";
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '1';
		byte				<= '1';
		address 			<= x"02468AC4";
		data_from_processor <= x"0FF00FF0";
		data_from_memory	<= x"0000007F";
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '1';
		byte				<= '1';
		address 			<= x"02468AC2";
		data_from_processor <= x"0FF00FF0";
		data_from_memory	<= x"00EE007F";
		WAIT FOR 1 ms;
		
		write_enable		<= '0';
		read_enable			<= '1';
		byte				<= '1';
		address 			<= x"02468AC3";
		data_from_processor <= x"0FF00FF0";
		data_from_memory	<= x"3CEE007F";
		WAIT FOR 1 ms;
		
		WAIT FOR 2 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;