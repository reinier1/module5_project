LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--this code is the inoutput for normal operation. For debug mode an outer input output file is used.
ENTITY inoutput IS
	PORT (
		reset : IN std_logic; 
		write_enable: IN std_logic;
		read_enable: IN std_logic;
		clk : IN std_logic; -- 50MHz clock
		data_in: IN std_logic_vector(31 DOWNTO 0); --get 64 bits in probaly not all are used.
		data_out: OUT std_logic_vector(31 DOWNTO 0);
		byte0_enable, byte1_enable, byte2_enable, byte3_enable : IN std_logic;  --come from the memory controller select the byte in a word
		adress_lines : IN std_logic_vector(7 DOWNTO 0); --lowest 8 bits of the adress line
		hex0, hex1, hex2, hex3 : OUT std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point
		button1, button2, button3 : IN std_logic; -- button 0 is the reset
		dip0, dip1, dip2, dip3, dip4, dip5, dip6, dip7, dip8 : IN std_logic; -- dip9 is set debug
		led0, led1, led2, led3, led4, led5, led6, led7, led8, led9 : OUT std_logic
	);
END inoutput;

ARCHITECTURE bhv of inoutput IS
		SIGNAL	hex0_internal, hex1_internal, hex2_internal, hex3_internal : std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point
		SIGNAL	led0_internal, led1_internal, led2_internal, led3_internal, led4_internal, led5_internal, led6_internal, led7_internal, led8_internal, led9_internal :  std_logic;
		--useful for reading those values
		
		
		--The following is used to prevent metastability
		SIGNAL  button1_internal, button2_internal, button3_internal :  std_logic; -- button 0 is the reset
		SIGNAL dip0_internal, dip1_internal, dip2_internal, dip3_internal, dip4_internal, dip5_internal, dip6_internal, dip7_internal, dip8_internal : std_logic; -- dip9 is set debug
	BEGIN
		
		
	PROCESS(clk, reset)
		BEGIN
		
		IF (reset = '0') THEN
			hex0 <=(others => '0');
			hex1 <=(others => '0');
			hex2 <=(others => '0');
			hex3 <=(others => '0');
			hex0_internal <=(others => '0');
			hex1_internal <=(others => '0');
			hex2_internal <=(others => '0');
			hex3_internal <=(others => '0');
		ELSIF rising_edge(clk) THEN
			hex0 <= hex0_internal; --this is nececcary to return the value when it is read.
			hex1 <= hex1_internal;
			hex2 <= hex2_internal;
			hex3 <= hex3_internal;
			led0 <= led0_internal;
			led1 <= led1_internal;
			led2 <= led2_internal;
			led3 <= led3_internal;
			led4 <= led4_internal;
			led5 <= led5_internal;
			led6 <= led6_internal;
			led7 <= led7_internal;
			led8 <= led8_internal;
			led9 <= led9_internal;
			dip0_internal <= dip0;
			dip1_internal <= dip1;
			dip2_internal <= dip2;
			dip3_internal <= dip3;
			dip4_internal <= dip4;
			dip5_internal <= dip5;
			dip6_internal <= dip6;
			dip7_internal <= dip7;
			dip8_internal <= dip8;
			button1_internal <= button1;
			button2_internal <= button2;
			button3_internal <= button3;
						
				
			
			IF write_enable = '1' THEN
				data_out <= (others => '0'); --this has advantages when using byte read. With this after two byte read from hardwire no specified numbers are not 0. Otherwise in the first read this is the case. 
				IF adress_lines	= "00010000" THEN--adress_lines FF10
					IF byte0_enable = '1' THEN
						hex3_internal <=  data_in(7 downto 0);  
					ELSIF byte3_enable = '1' THEN
						led9_internal <=  data_in(31);
					END IF; 
				
				ELSIF adress_lines = "00010100" THEN --adress lines FF14
					IF byte0_enable = '1' THEN
						hex2_internal <=  data_in(7 downto 0);  
					ELSIF byte3_enable = '1' THEN
						led8_internal <=  data_in(31);
					END IF; 
				
				ELSIF adress_lines = "00011000" THEN --adress lines FF18
					IF byte0_enable = '1' THEN
						hex1_internal <=  data_in(7 downto 0);  
					END IF; 
				
				ELSIF adress_lines = "00011100" THEN --adress lines FF1C
					IF byte0_enable = '1' THEN
						hex0_internal <=  data_in(7 downto 0);  
					END IF; 
				
				ELSIF adress_lines = "00000000" THEN -- adress FF00
					if byte0_enable = '1' THEN
						led0_internal <=data_in(0);
						led1_internal <=data_in(1);
						led2_internal<= data_in(2);
						led3_internal<= data_in(3);
						led4_internal<= data_in(4);
						led5_internal<= data_in(5);
						led6_internal<= data_in(6);
						led7_internal<= data_in(7);
					END IF;
				END If;
			
			ELSIF read_enable = '1' THEN
				
				IF adress_lines = "00001000" THEN --FF08
					IF byte0_enable = '1' THEN
						data_out(0) <= button1_internal; --button 0 is the reset so that is not readable
						data_out(1) <= button2_internal;
						data_out(2) <= button3_internal;
					END IF;
					IF byte3_enable = '1' THEN
						data_out(31) <= dip8_internal;
					data_out(30 DOWNTO 3) <= (OTHERS => '0');
					END IF;
				ELSIF adress_lines = "00000100" THEN --FF04
					data_out(0) <= dip0_internal;
					data_out(1) <= dip1_internal;
					data_out(2) <= dip2_internal;
					data_out(3) <= dip3_internal;
					data_out(4) <= dip4_internal;
					data_out(5) <= dip5_internal;
					data_out(6) <= dip6_internal;
					data_out(7) <= dip7_internal;
					data_out(31 DOWNTO 7) <= (OTHERS => '0');
					
					--if you tried to read adess you writen to you get back the values of the output you writen to. The other values are quite random
				ELSIF adress_lines	= "00010000" THEN--adress_lines FF10
					
					IF byte0_enable = '1' THEN
						 data_out(7 downto 0) <= hex3_internal;  
					ELSIF byte3_enable = '1' THEN
						 data_out(31) <= led9_internal;
						  
					
					END IF; 
				
				ELSIF adress_lines = "00010100" THEN --adress lines FF14
					IF byte0_enable = '1' THEN
						data_out(7 downto 0) <= hex2_internal ;  
					ELSIF byte3_enable = '1' THEN
						data_out(31) <= led8_internal;
						
					END IF; 
				
				ELSIF adress_lines = "00011000" THEN --adress lines FF18
					IF byte0_enable = '1' THEN
						 data_out(7 downto 0) <= hex1_internal;  
					END IF; 
				
				ELSIF adress_lines = "00011100" THEN --adress lines FF1C
					IF byte0_enable = '1' THEN
						data_out(7 downto 0) <= hex0_internal;  
					END IF; 
				
				ELSIF adress_lines = "00000000" THEN -- adress FF00
					if byte0_enable = '1' THEN
						data_out(0) <= led0_internal;
						data_out(1) <= led1_internal;
						data_out(2) <= led2_internal;
						data_out(3) <= led3_internal;
						data_out(4) <= led4_internal;
						data_out(5) <= led5_internal;
						data_out(6) <= led6_internal;
						data_out(7) <= led7_internal;
					END IF;
				END If;	
			END IF;
		END IF;
			
		
		
	END PROCESS; 
END bhv;