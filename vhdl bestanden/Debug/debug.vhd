library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY debug IS
	PORT 
	(
		clk		: IN std_logic;
		dip0	: IN std_logic;
		dip1	: IN std_logic;
		dip2	: IN std_logic;
		dip3	: IN std_logic;
		dip4	: IN std_logic;
		dip5	: IN std_logic;
		dip6	: IN std_logic;
		dip7	: IN std_logic;
		key1	: IN std_logic;
		key2	: IN std_logic;
		key3	: IN std_logic;
		byte_in	: IN std_logic_vector(7 DOWNTO 0);
		byte_out: OUT std_logic_vector(7 DOWNTO 0);
		b_read	: OUT std_logic;
		b_write	: OUT std_logic;
		address	: OUT std_logic_vector(15 DOWNTO 0);
		hex0	: OUT std_logic_vector(6 DOWNTO 0);
		hex1	: OUT std_logic_vector(6 DOWNTO 0);
		hex2	: OUT std_logic_vector(6 DOWNTO 0);
		hex3	: OUT std_logic_vector(6 DOWNTO 0);
		hex4	: OUT std_logic_vector(6 DOWNTO 0);
		hex5	: OUT std_logic_vector(6 DOWNTO 0)
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

	SIGNAL dipswitches 					: std_logic_vector(7 DOWNTO 0);
	SIGNAL instr_view_byte_on_address 	: std_logic := '0';
	SIGNAL instr_write_byte_on_address 	: std_logic := '0';
	SIGNAL instr_view_byte_next_address : std_logic := '0';
	SIGNAL instr_write_byte_next_address: std_logic := '0';
	SIGNAL instr_execute_and_wait 		: std_logic := '0';
	SIGNAL byte							: std_logic_vector(7 DOWNTO 0);
	SIGNAL counter_key2					: integer 	:= 0;
	SIGNAL part							: integer 	:= 0;
	SIGNAL byte_signal					: std_logic_vector(7 DOWNTO 0);
	SIGNAL wait_for_byte				: integer 	:= 5;
	SIGNAL b_read_intern				: std_logic := '0';
	SIGNAL b_write_intern				: std_logic := '0';
	SIGNAL address_intern				: std_logic_vector(15 DOWNTO 0);
	SIGNAL byte_out_intern				: std_logic_vector(7 DOWNTO 0);

BEGIN
PROCESS(clk)
BEGIN
	
	IF rising_edge(clk) THEN
		dipswitches(0) <= dip0;
		dipswitches(1) <= dip1;
		dipswitches(2) <= dip2;
		dipswitches(3) <= dip3;
		dipswitches(4) <= dip4;
		dipswitches(5) <= dip5;
		dipswitches(6) <= dip6;
		dipswitches(7) <= dip7;
		wait_for_byte  <= wait_for_byte+1;
		IF wait_for_byte = 2 THEN
			IF b_read_intern = '1' THEN
				byte_signal 	<= byte_in;
				b_read 			<= '0';
				b_read_intern 	<= '0';
			ELSIF b_write_intern = '1' THEN
				byte_signal 	<= byte_out_intern;
				b_write 		<= '0';
				b_write_intern 	<= '0';
			END IF;
		END IF;
		hex0 <= hex2display(byte_signal(3 DOWNTO 0));
		hex1 <= hex2display(byte_signal(7 DOWNTO 4));
		hex2 <= hex2display(address_intern(3 DOWNTO 0));
		hex3 <= hex2display(address_intern(7 DOWNTO 4));
		hex4 <= hex2display(address_intern(11 DOWNTO 8));
		hex5 <= hex2display(address_intern(15 DOWNTO 12));
		IF (key3 = '0') THEN
			IF dipswitches = "00000000" THEN
				instr_view_byte_on_address 		<= '1';
			ELSIF dipswitches = "00000001" THEN
				instr_write_byte_on_address 	<= '1';
			ELSIF dipswitches = "00000010" THEN
				instr_view_byte_next_address 	<= '1';
			ELSIF dipswitches = "00000011" THEN
				instr_write_byte_next_address 	<= '1';
			ELSIF dipswitches = "00000100" THEN
				instr_execute_and_wait  		<= '1';
			END IF;
		ELSIF key2 = '1' THEN
			counter_key2 <= 0;
		ELSIF key2 /= '1' THEN
			counter_key2 <= counter_key2+1;
			IF counter_key2 = 5 THEN
				counter_key2 <= 0;
				IF instr_view_byte_on_address = '1' THEN
					IF part = 0 THEN
						address(7 DOWNTO 0) 		<= dipswitches;
						address_intern(7 DOWNTO 0) 	<= dipswitches;
						part 						<= 1;
					ELSIF part = 1 THEN
						address(15 DOWNTO 8) 		<= dipswitches;
						address_intern(15 DOWNTO 8) <= dipswitches;
						b_read 						<= '1';
						b_read_intern 				<= '1';
						wait_for_byte 				<= 0;
						instr_view_byte_on_address 	<= '0';
						part 						<= 0;
					END IF;
				ELSIF instr_write_byte_on_address = '1' THEN	
					IF part = 0 THEN
						address(7 DOWNTO 0) 		<= dipswitches;
						address_intern(7 DOWNTO 0) 	<= dipswitches;
						part 						<= 1;
					ELSIF part = 1 THEN
						address(15 DOWNTO 8) 		<= dipswitches;
						address_intern(15 DOWNTO 8) <= dipswitches;
						part 						<= 2;
					ELSIF part = 2 THEN
						byte_out 					<= dipswitches;
						byte_out_intern 			<= dipswitches;
						b_write 					<='1';
						b_write_intern 				<= '1';
						wait_for_byte 				<= 0;
						instr_write_byte_on_address <= '0';
						part 						<= 0;
					END IF;
				ELSIF instr_view_byte_next_address = '1' THEN
					address 		<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(4), address'length));
					address_intern 	<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(4), address_intern'length));
					b_read 			<= '1';
					b_read_intern 	<= '1';
					wait_for_byte 	<= 0;
					instr_view_byte_next_address <= '0';
				ELSIF instr_write_byte_next_address = '1' THEN
					address 		<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(4), address'length));
					address_intern 	<= std_logic_vector(unsigned(address_intern) + to_unsigned(integer(4), address_intern'length));
					byte_out 		<= dipswitches;
					byte_out_intern <= dipswitches;
					b_write 		<= '1';
					b_write_intern 	<= '1';
					wait_for_byte 	<= 0;
					instr_write_byte_on_address 	<= '0';
				ELSIF instr_execute_and_wait = '1' THEN
					null;
					-- still to be made
				END IF;
			END IF;
		END IF;
	END IF;
END PROCESS;
END;