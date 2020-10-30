library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY debug IS
	PORT 
	(
		clk			: IN std_logic;
		reset		: IN std_logic;
		dipswitches	: IN std_logic_vector(7 DOWNTO 0);
		key1		: IN std_logic;
		key2		: IN std_logic;
		key3		: IN std_logic;
		byte_in		: IN std_logic_vector(7 DOWNTO 0);
		byte_out	: OUT std_logic_vector(7 DOWNTO 0);				-- byte to be written into the memory
		b_read		: OUT std_logic;								-- byte read enable
		b_write		: OUT std_logic;								-- byte write enable
		address		: OUT std_logic_vector(15 DOWNTO 0);
		hex0		: OUT std_logic_vector(6 DOWNTO 0);
		hex1		: OUT std_logic_vector(6 DOWNTO 0);
		hex2		: OUT std_logic_vector(6 DOWNTO 0);
		hex3		: OUT std_logic_vector(6 DOWNTO 0);
		hex4		: OUT std_logic_vector(6 DOWNTO 0);
		hex5		: OUT std_logic_vector(6 DOWNTO 0);
		debug_in	: IN std_logic; 								-- gets debug in
		debug_out	: OUT std_logic									--gives debug out. Usefull for the do one instr_execute_and_wait
	);
END debug;

ARCHITECTURE salade OF debug IS

  FUNCTION hex2display (n:std_logic_vector(3 DOWNTO 0)) RETURN std_logic_vector IS
    VARIABLE res : std_logic_vector(6 DOWNTO 0);
  BEGIN
    CASE n IS
	    WHEN "0000" => RETURN NOT "0111111";
	    WHEN "0001" => RETURN NOT "0000110";
	    WHEN "0010" => RETURN NOT "1011011";
	    WHEN "0011" => RETURN NOT "1001111";
	    WHEN "0100" => RETURN NOT "1100110";
	    WHEN "0101" => RETURN NOT "1101101";
	    WHEN "0110" => RETURN NOT "1111101";
	    WHEN "0111" => RETURN NOT "0000111";
	    WHEN "1000" => RETURN NOT "1111111";
	    WHEN "1001" => RETURN NOT "1101111";
	    WHEN "1010" => RETURN NOT "1110111";
	    WHEN "1011" => RETURN NOT "1111100";
	    WHEN "1100" => RETURN NOT "0111001";
	    WHEN "1101" => RETURN NOT "1011110";
	    WHEN "1110" => RETURN NOT "1111001";
	    WHEN OTHERS => RETURN NOT "1110001";			
    END CASE;
  END hex2display;

	
	SIGNAL instr_view_byte_on_address 	: std_logic := '0';
	SIGNAL instr_write_byte_on_address 	: std_logic := '0';
	SIGNAL instr_view_byte_next_address : std_logic := '0';
	SIGNAL instr_write_byte_next_address: std_logic := '0';
	SIGNAL instr_execute_and_wait 		: std_logic := '0';
	--SIGNAL byte							: std_logic_vector(7 DOWNTO 0);
	SIGNAL part							: integer 	:= 0;
	SIGNAL byte_signal					: std_logic_vector(7 DOWNTO 0);
	SIGNAL wait_for_byte				: integer 	:= 5;
	SIGNAL b_read_intern				: std_logic := '0';
	SIGNAL b_write_intern				: std_logic := '0';
	SIGNAL address_intern				: std_logic_vector(15 DOWNTO 0);
	SIGNAL byte_out_intern				: std_logic_vector(7 DOWNTO 0);
	SIGNAL counter						: integer	:= 0;

BEGIN
	hex0 <= hex2display(byte_signal(3 DOWNTO 0));			-- the byte (that is written to memory or collected from memory) is shown on the hexadecimal displays
	hex1 <= hex2display(byte_signal(7 DOWNTO 4));			
	hex2 <= hex2display(address_intern(3 DOWNTO 0));		-- the address is shown on the hexadecimal displays
	hex3 <= hex2display(address_intern(7 DOWNTO 4));
	hex4 <= hex2display(address_intern(11 DOWNTO 8));
	hex5 <= hex2display(address_intern(15 DOWNTO 12));
PROCESS(clk)
BEGIN
	IF reset='0' THEN 
		instr_view_byte_on_address		<= '0';
		instr_write_byte_on_address		<= '0';
		instr_view_byte_next_address 	<= '0';
		instr_write_byte_next_address	<= '0';
		instr_execute_and_wait 			<= '0';
		--byte							<= 
		part							<= 0;
		byte_signal						<= x"00";
		wait_for_byte					<= 0;
		b_read                          <= '0';
		b_read_intern					<= '0';
		b_write                         <= '0';
		b_write_intern					<= '0';
		address                         <= x"0000";
		address_intern					<= x"0000";
		byte_out                        <= x"00";
		byte_out_intern					<= x"00";
		counter							<= 0;
		debug_out						<= debug_in;
	ELSIF rising_edge(clk) THEN 								-- synchrone
		IF debug_in='1' THEN
			wait_for_byte  <= wait_for_byte+1;
			IF wait_for_byte = 2 THEN								-- the write to or read from memory can now take up to three clockcycles
				IF b_read_intern = '1' THEN							-- when the byte is read from memory
					byte_signal 	<= byte_in;
					b_read 			<= '0';
					b_read_intern 	<= '0';
				ELSIF b_write_intern = '1' THEN						-- when the byte is written to the memory
					byte_signal 	<= byte_out_intern;
					b_write 		<= '0';
					b_write_intern 	<= '0';
				END IF;
			END IF;
			
			IF instr_execute_and_wait = '1' THEN 					-- debug_out is zero for one clock cycle 
				debug_out <= '0';
				instr_execute_and_wait <= '0';
			ELSE 
				debug_out <= debug_in; 								-- normally debug_out is equal to debug_in
			END IF;
			
			IF (key3 = '0') THEN									-- key3 is used to specify the instruction of the debug
				IF dipswitches = "00000000" THEN
					instr_view_byte_on_address 		<= '1';			-- view byte on address is accessed with 00000000 on dip0 to dip7
				ELSIF dipswitches = "00000001" THEN
					instr_write_byte_on_address 	<= '1';			-- write byte on address is accessed with 00000001 on dip0 to dip7
				ELSIF dipswitches = "00000010" THEN
					instr_view_byte_next_address 	<= '1';			-- view byte on the next address is accessed with 00000010 on dip0 to dip7
				ELSIF dipswitches = "00000011" THEN
					instr_write_byte_next_address 	<= '1';			-- write byte on the next address is accessed with 00000011 on dip0 to dip7
				ELSIF dipswitches = "00000100" THEN
					instr_execute_and_wait  		<= '1';			-- execute one instruction and wait is accessed with 00000100 on dip0 to dip7
				END IF;
				
			-- this count assumes that fingers are slower then 2 clockcycles
			ELSIF key2 = '1' THEN
				counter <= 0;
			ELSIF key2 = '0' THEN										-- key2 is used to specify the address (and the input for the address)
				counter <= counter +1;
				IF counter = 2 THEN
					IF instr_view_byte_on_address = '1' THEN			-- instruction view byte on address
						IF part = 0 THEN									-- key2 is pressed
							address(7 DOWNTO 0) 		<= dipswitches;		-- the dipswitches will be transferred to bit 7 downto 0 of the address
							address_intern(7 DOWNTO 0) 	<= dipswitches;
							part 						<= 1;
							--counter <= 0;
						ELSIF part = 1 THEN									-- key2 is pressed again
							address(15 DOWNTO 8) 		<= dipswitches;		-- the dipswitches will be transferred to bit 15 downto 0 of the address
							address_intern(15 DOWNTO 8) <= dipswitches;
							b_read 						<= '1';				-- byte read is be enabled (this is necesary for memory access)
							b_read_intern 				<= '1';
							wait_for_byte 				<= 0;				-- so that the program will wait for 2 rising edges for the byte to be accessed from memory
							instr_view_byte_on_address 	<= '0';
							part 						<= 0;
							--counter <= 0;
						END IF;
						
					ELSIF instr_write_byte_on_address = '1' THEN		-- instruction write byte on address
						IF part = 0 THEN									-- key2 is pressed
							address(7 DOWNTO 0) 		<= dipswitches;		-- the dipswitches will be transferred to bit 7 downto 0 of the address
							address_intern(7 DOWNTO 0) 	<= dipswitches;
							part 						<= 1;
							--counter <= 0;
						ELSIF part = 1 THEN									-- key2 is pressed again
							address(15 DOWNTO 8) 		<= dipswitches;		-- the dipswitches will be transferred to bit 15 downto 0 of the address
							address_intern(15 DOWNTO 8) <= dipswitches;
							part 						<= 2;
							--counter <= 0;
						ELSIF part = 2 THEN									-- key2 is pressed again
							byte_out 					<= dipswitches;		-- the byte that will be written into the memory
							byte_out_intern 			<= dipswitches;
							b_write 					<='1';				-- byte write is enabled (which is necesary for writing to memory)
							b_write_intern 				<= '1';
							wait_for_byte 				<= 0;				-- so that the program will wait for 2 rising edges for the byte to be accessed from memory
							instr_write_byte_on_address <= '0';
							part 						<= 0;
							--counter <= 0;
						END IF;
						
					ELSIF instr_view_byte_next_address = '1' THEN																			-- instruction view byte on the next address
						address 		<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(1), address'length));				-- the previous address will be added with 1 to get the next byte
						address_intern 	<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(1), address_intern'length));
						b_read 			<= '1';																									-- byte read is be enabled (this is necesary for memory access)
						b_read_intern 	<= '1';
						wait_for_byte 	<= 0;																									-- so that the program will wait for 2 rising edges for the byte to be accessed from memory
						instr_view_byte_next_address <= '0';
						--counter <= 0;
						
					ELSIF instr_write_byte_next_address = '1' THEN																			-- instruction write byte on the next address
						address 		<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(1), address'length));				-- the previous address will be added with 1 to get the next byte
						address_intern 	<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(1), address_intern'length));			
						byte_out 		<= dipswitches;																							-- the byte that will be written into the memory
						byte_out_intern <= dipswitches;
						b_write 		<= '1';																									-- byte write is enabled (which is necesary for writing to memory)
						b_write_intern 	<= '1';
						wait_for_byte 	<= 0;																									-- so that the program will wait for 2 rising edges for the byte to be accessed from memory
						instr_write_byte_on_address <= '0';
						--counter <= 0;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END PROCESS;
END;