LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY memory_controller IS
	PORT 
	(
		byte 				: IN  std_logic;
		write_enable 		: IN  std_logic;
		read_enable 		: IN  std_logic;
		address 			: IN  std_logic_vector(31 DOWNTO 0);
		data_from_processor : IN  std_logic_vector(31 DOWNTO 0);
		data_from_memory	: IN  std_logic_vector(31 DOWNTO 0);
		
		read_enable_out		: OUT std_logic;
		write_enable_out 	: OUT std_logic;
		output_address		: OUT std_logic_vector(13 DOWNTO 0);
		
		byte_enable 		: OUT std_logic_vector( 3 DOWNTO 0);
		data_to_processor 	: OUT std_logic_vector(31 DOWNTO 0);
		data_to_memory 		: OUT std_logic_vector(31 DOWNTO 0)
    );
END memory_controller;

ARCHITECTURE bhv OF memory_controller IS
	CONSTANT K_ONE : unsigned(3 DOWNTO 0) := "0001";
	SIGNAL  integer_address : integer RANGE 0 TO 3;
BEGIN

	integer_address		<= to_integer(unsigned(address(1 DOWNTO 0)));

	read_enable_out		<= read_enable;	-- Values are constant
	write_enable_out 	<= write_enable;
	output_address	 	<= address(15 DOWNTO 2);

	PROCESS(byte,data_from_processor,data_from_memory,integer_address,write_enable,read_enable)
	BEGIN 
		IF write_enable = '1' THEN
			IF byte = '1' THEN				-- If byte is active a byte is stored, otherwise a word is stored
				byte_enable 		<= std_logic_vector(SHIFT_LEFT(K_ONE, integer_address));		-- Depending on the last two bits of the adress the '1' in byte enable can be shifted 0-3 times
				data_to_memory 		<= data_from_processor(7 DOWNTO 0)&data_from_processor(7 DOWNTO 0)&data_from_processor(7 DOWNTO 0)&data_from_processor(7 DOWNTO 0);
				data_to_processor 	<= data_from_memory;
			ELSE
				byte_enable 		<= "1111";
				data_to_memory 		<= data_from_processor;
				data_to_processor 	<= data_from_memory;
			END IF;
		ELSIF read_enable = '1' THEN
			IF byte = '1' THEN				-- If byte is active a byte is read, otherwise a word is read
				byte_enable 		<= std_logic_vector(SHIFT_LEFT(K_ONE, integer_address));				
				data_to_processor 	<= std_logic_vector(resize(signed(data_from_memory((8 * integer_address + 7) DOWNTO (8 * integer_address))), 32));				
				data_to_memory 		<= data_from_processor;
			ELSE
				byte_enable 		<= "1111";
				data_to_processor 	<= data_from_memory;
				data_to_memory 		<= data_from_processor;
			END IF;
		ELSE
			data_to_processor 		<= data_from_memory;
			data_to_memory 			<= data_from_processor;
			byte_enable 			<= "0000";
		END IF;
	END PROCESS;
END bhv;