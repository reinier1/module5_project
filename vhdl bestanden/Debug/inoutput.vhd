LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--this code is the inoutput for normal operation. For debug mode an outer input output file is used.
ENTITY inoutput IS
	PORT (
		clk 				: IN  std_logic; -- 50MHz clock
		reset 				: IN  std_logic; 
		write_enable		: IN  std_logic;
		read_enable			: IN  std_logic;
		byte0_enable 		: IN  std_logic;  --come from the memory controller select the byte in a word
		byte1_enable 		: IN  std_logic;
		byte2_enable 		: IN  std_logic;
		byte3_enable 		: IN  std_logic;
		data_in				: IN  std_logic_vector(31 DOWNTO 0); --get 64 bits in probably not all are used.
		data_out			: OUT std_logic_vector(31 DOWNTO 0);
		adress_lines 		: IN  std_logic_vector(7 DOWNTO 0); --lowest 8 bits of the adress line
		hex0 				: OUT std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point
		hex1				: OUT std_logic_vector(7 DOWNTO 0);
		hex2				: OUT std_logic_vector(7 DOWNTO 0);
		hex3				: OUT std_logic_vector(7 DOWNTO 0);
		buttons				: IN  std_logic_vector(2 downto 0); -- button 0 is the reset
		dip_switches 		: IN  std_logic_vector(8 downto 0); -- dip9 is set debug
		leds 				: OUT std_logic_vector(9 DOWNTO 0)
	);
END inoutput;

ARCHITECTURE bhv of inoutput IS
		SIGNAL hex0_internal			: std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point 
		SIGNAL hex1_internal			: std_logic_vector(7 DOWNTO 0);
		SIGNAL hex2_internal 			: std_logic_vector(7 DOWNTO 0);
		SIGNAL hex3_internal 			: std_logic_vector(7 DOWNTO 0);
		SIGNAL leds_internal 			: std_logic_vector(9 DOWNTO 0);
		--useful for reading those values
		
		
		--The following is used to prevent metastability
		SIGNAL buttons_internal			:  std_logic_vector(2 DOWNTO 0); -- button 0 is the reset
		SIGNAL dip_switches_internal 	: std_logic_vector(8 DOWNTO 0); -- dip9 is set debug
	BEGIN
		
	PROCESS(clk, reset)
		BEGIN
		IF (reset = '0') THEN
			hex0 			<= (others => '0');
			hex1 			<= (others => '0');
			hex2 			<= (others => '0');
			hex3 			<= (others => '0');
			hex0_internal 	<= (others => '0');
			hex1_internal 	<= (others => '0');
			hex2_internal 	<= (others => '0');
			hex3_internal 	<= (others => '0');
			leds_internal 	<= (others => '0');
			leds 			<= (others => '0');
		ELSIF rising_edge(clk) THEN
			hex0 					<= hex0_internal; --this is nececcary to return the value when it is read.
			hex1 					<= hex1_internal;
			hex2 					<= hex2_internal;
			hex3 					<= hex3_internal;
			leds 					<= leds_internal;
			dip_switches_internal 	<= dip_switches; --to prevent metastability
			buttons_internal 		<= buttons;
			
			IF write_enable = '1' THEN
				data_out <= (others => '0'); --this has advantages when using byte read. With this after two byte read from hardwire no specified numbers are not 0. Otherwise in the first read this is the case. 
				IF adress_lines	= "00010000" THEN--adress_lines FF10
				
					IF byte0_enable = '1' THEN
						hex3_internal 		<=  data_in(7 downto 0);  
					ELSIF byte3_enable = '1' THEN
						leds_internal(9) 	<=  data_in(31);
					END IF; 
				
				ELSIF adress_lines = "00010100" THEN --adress lines FF14
				
					IF byte0_enable = '1' THEN
						hex2_internal 		<=  data_in(7 downto 0);  
					ELSIF byte3_enable = '1' THEN
						leds_internal(8) 	<=  data_in(31);
					END IF; 
				
				ELSIF adress_lines = "00011000" THEN --adress lines FF18
				
					IF byte0_enable = '1' THEN
						hex1_internal 		<=  data_in(7 downto 0);  
					END IF; 
				
				ELSIF adress_lines = "00011100" THEN --adress lines FF1C
				
					IF byte0_enable = '1' THEN
						hex0_internal 		<=  data_in(7 downto 0);  
					END IF; 
				
				ELSIF adress_lines = "00000000" THEN -- adress FF00
				
					IF byte0_enable = '1' THEN
						leds_internal(7 DOWNTO 0) <= data_in( 7 DOWNTO 0);
					END IF;
					
				END IF;
			
			ELSIF read_enable = '1' THEN
				
				IF adress_lines = "00001000" THEN --FF08
				
					IF byte0_enable = '1' THEN
						data_out(2 DOWNTO 0) <= buttons_internal(2 DOWNTO 0);
					END IF;
					IF byte3_enable = '1' THEN
						data_out(31) 			<= dip_switches_internal(8);
						data_out(30 DOWNTO 3) 	<= (OTHERS => '0');
					END IF;
					
				ELSIF adress_lines = "00000100" THEN --FF04
				
					data_out(7 DOWNTO 0) 	<= dip_switches_internal(7 DOWNTO 0);
					data_out(31 DOWNTO 8) 	<= (OTHERS => '0');
					
					--if you tried to read adess you writen to you get back the values of the output you writen to. The other values are quite random
				ELSIF adress_lines	= "00010000" THEN--adress_lines FF10
					
					IF byte0_enable = '1' THEN
						 data_out(7 downto 0) 	<= hex3_internal;  
					ELSIF byte3_enable = '1' THEN
						 data_out(31) 			<=  leds_internal(9);
					END IF; 
				
				ELSIF adress_lines = "00010100" THEN --adress lines FF14
				
					IF byte0_enable = '1' THEN
						data_out(7 downto 0) 	<= hex2_internal ;  
					ELSIF byte3_enable = '1' THEN
						data_out(31) 			<= leds_internal(8);
					END IF; 
				
				ELSIF adress_lines = "00011000" THEN --adress lines FF18
				
					IF byte0_enable = '1' THEN
						 data_out(7 downto 0) 	<= hex1_internal;  
					END IF; 
				
				ELSIF adress_lines = "00011100" THEN --adress lines FF1C
				
					IF byte0_enable = '1' THEN
						data_out(7 downto 0) 	<= hex0_internal;  
					END IF; 
				
				ELSIF adress_lines = "00000000" THEN -- adress FF00
				
					IF byte0_enable = '1' THEN
						data_out(7 DOWNTO 0) 	<= leds_internal(7 DOWNTO 0); 
					END IF;
					
				END IF;	
			END IF;
		END IF;
	END PROCESS; 
END bhv;