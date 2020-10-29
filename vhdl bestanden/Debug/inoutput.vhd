LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--this code is the inoutput for normal operation. For debug mode an outer input output file is used.
ENTITY inoutput IS
	PORT (
		reset 			: IN std_logic; 
		clk 			: IN std_logic; 							-- 50MHz clock
		write_enable	: IN std_logic;
		read_enable		: IN std_logic;
		data_in			: IN std_logic_vector(31 DOWNTO 0); 		-- get 32 bits in probaly not all are used.
		data_out		: OUT std_logic_vector(31 DOWNTO 0);
		byte0_enable, byte1_enable, byte2_enable, byte3_enable : IN std_logic;  --come from the memory controller select the byte in a word
		address_lines 	: IN std_logic_vector(7 DOWNTO 0); 			-- lowest 8 bits of the address line
		hex0, hex1, hex2, hex3 : OUT std_logic_vector(7 DOWNTO 0); 	-- the 7 segment hex display has a point
		buttons			: IN std_logic_vector(2 downto 0); 			-- button 0 is the reset
		dip_switches 	: IN std_logic_vector(8 downto 0); 			-- dip9 is set debug
		leds 			: OUT std_logic_vector(9 DOWNTO 0)
	);
END inoutput;

ARCHITECTURE bhv of inoutput IS
		-- These signals are useful for reading those values
		SIGNAL	hex0_internal, hex1_internal, hex2_internal, hex3_internal 	: std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point
		SIGNAL leds_internal 												: std_logic_vector(9 DOWNTO 0);
		
		--The following is used to prevent metastability
		SIGNAL buttons_internal:  std_logic_vector(2 DOWNTO 0); 		-- button 0 is the reset
		SIGNAL dip_switches_internal : std_logic_vector(8 DOWNTO 0); 	-- dip9 is set debug
		
	BEGIN
		
		
	PROCESS(clk, reset)
		BEGIN
		
		IF (reset = '0') THEN						-- If the reset is on then everything is set to 0
			hex0 <=(others => '0');
			hex1 <=(others => '0');
			hex2 <=(others => '0');
			hex3 <=(others => '0');
			hex0_internal <=(others => '0');
			hex1_internal <=(others => '0');
			hex2_internal <=(others => '0');
			hex3_internal <=(others => '0');
			leds_internal <=(others => '0');
			leds <= (others => '0');
			data_out <= (others => '0');
		ELSIF rising_edge(clk) THEN					-- the hexadecimal displays, leds and dipswitches and buttons will be 1 clockcycle later
			hex0 <= hex0_internal; 					-- this is nececcary to return the value when it is read.
			hex1 <= hex1_internal;
			hex2 <= hex2_internal;
			hex3 <= hex3_internal;
			leds <= leds_internal;
			dip_switches_internal <= dip_switches; 	-- to prevent metastability
			buttons_internal <= buttons;
						
			IF write_enable = '1' THEN
				data_out <= (others => '0'); 					-- this has advantages when using byte read. With this after two byte read from hardwire no specified numbers are not 0. Otherwise in the first read this is the case. 
				IF address_lines	= "00010000" THEN			-- address_lines FF10
					IF byte0_enable = '1' THEN
						hex3_internal <=  data_in(7 DOWNTO 0);  
					ELSIF byte3_enable = '1' THEN
						leds_internal(9) <=  data_in(31);
					END IF; 
				
				ELSIF address_lines = "00010100" THEN 			-- address lines FF14
					IF byte0_enable = '1' THEN
						hex2_internal <=  data_in(7 DOWNTO 0);  
					ELSIF byte3_enable = '1' THEN
						leds_internal(8) <=  data_in(31);
					END IF; 
				
				ELSIF address_lines = "00011000" THEN 			-- address lines FF18
					IF byte0_enable = '1' THEN
						hex1_internal <=  data_in(7 DOWNTO 0);  
					END IF; 
				
				ELSIF address_lines = "00011100" THEN 			-- address lines FF1C
					IF byte0_enable = '1' THEN
						hex0_internal <=  data_in(7 DOWNTO 0);  
					END IF; 
				
				ELSIF address_lines = "00000000" THEN 			-- address lines FF00
					IF byte0_enable = '1' THEN
						leds_internal(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
					END IF;
				END IF;
			
			ELSIF read_enable = '1' THEN
				
				IF address_lines = "00001000" THEN 				-- address lines FF08
					IF byte0_enable = '1' THEN
						data_out(2 DOWNTO 0) <= buttons_internal(2 DOWNTO 0);
					END IF;
					IF byte3_enable = '1' THEN
						data_out(31) <= dip_switches_internal(8);
					data_out(30 DOWNTO 3) <= (OTHERS => '0');
					END IF;
				ELSIF address_lines = "00000100" THEN 			-- address lines FF04
					data_out(7 DOWNTO 0) <= dip_switches_internal(7 DOWNTO 0);
					data_out(31 DOWNTO 8) <= (OTHERS => '0');
					
					-- If you have written an output at a certain address, then you can later on read that output at that address.
					-- The values of addresses that have not been written to as of yet, can have quite random values.
				ELSIF address_lines	= "00010000" THEN			-- address_lines FF10
					IF byte0_enable = '1' THEN
						data_out(7 DOWNTO 0) <= hex3_internal;  
					ELSIF byte3_enable = '1' THEN
						data_out(31) <=  leds_internal(9);
					END IF; 
				
				ELSIF address_lines = "00010100" THEN 			-- address lines FF14
					IF byte0_enable = '1' THEN
						data_out(7 DOWNTO 0) <= hex2_internal ;  
					ELSIF byte3_enable = '1' THEN
						data_out(31) <= leds_internal(8);
					END IF; 
				
				ELSIF address_lines = "00011000" THEN 			-- address lines FF18
					IF byte0_enable = '1' THEN
						 data_out(7 DOWNTO 0) <= hex1_internal;  
					END IF; 
				
				ELSIF address_lines = "00011100" THEN 			-- address lines FF1C
					IF byte0_enable = '1' THEN
						data_out(7 DOWNTO 0) <= hex0_internal;  
					END IF; 
				
				ELSIF address_lines = "00000000" THEN 			-- address lines FF00
					IF byte0_enable = '1' THEN
						data_out(7 DOWNTO 0) <= leds_internal(7 DOWNTO 0); 
					END IF;
				END If;	
			END IF;
		END IF;
		
	END PROCESS; 
END bhv;