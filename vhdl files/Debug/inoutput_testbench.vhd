
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;

ARCHITECTURE bhv OF testbench IS 
	
	SIGNAL reset 					: std_logic						:= '0'; 
	SIGNAL write_enable				: std_logic						:= '0';
	SIGNAL read_enable				: std_logic						:= '0';
	SIGNAL clk 						: std_logic 					:= '1'; -- 50MHz clock
	SIGNAL data_in					: std_logic_vector(31 DOWNTO 0)	:= x"00000000"; --get 32 bits in probaly not all are used.
	SIGNAL data_out					: std_logic_vector(31 DOWNTO 0);
	SIGNAL byte0_enable 			: std_logic						:= '0';  --come from the memory controller select the byte in a word 
	SIGNAL byte1_enable 			: std_logic						:= '0';  
	SIGNAL byte2_enable 			: std_logic						:= '0';  
	SIGNAL byte3_enable 			: std_logic						:= '0';  
	SIGNAL adress_lines 			: std_logic_vector(7 DOWNTO 0)	:= x"00"; --lowest 8 bits of the adress line
	SIGNAL hex0						: std_logic_vector(7 DOWNTO 0); --the 7 segment hex display has a point
	SIGNAL hex1						: std_logic_vector(7 DOWNTO 0); 
	SIGNAL hex2 					: std_logic_vector(7 DOWNTO 0); 
	SIGNAL hex3 					: std_logic_vector(7 DOWNTO 0); 
	SIGNAL buttons					: std_logic_vector(2 DOWNTO 0)	:= "000"; -- button 0 is the reset
	SIGNAL dip_switches				: std_logic_vector(8 DOWNTO 0)	:= '0' & x"00"; -- dip9 is set debug
	SIGNAL dip_switches_internal 	: std_logic_vector(8 DOWNTO 0)	:= '0' & x"00"; --necessary to compare expected and read values
	SIGNAL leds						: std_logic_vector (9 DOWNTO 0);
	SIGNAL leds_internal 			: std_logic_vector (9 DOWNTO 0)	:= "00" & x"00"; --necessary to compare expected and read values
	SIGNAL hex0_internal 			: std_logic_vector (7 DOWNTO 0)	:= x"00"; 
	SIGNAL hex1_internal 			: std_logic_vector (7 DOWNTO 0)	:= x"00"; 
	SIGNAL hex2_internal 			: std_logic_vector (7 DOWNTO 0)	:= x"00";
	SIGNAL hex3_internal 			: std_logic_vector (7 DOWNTO 0)	:= x"00";
	
	SIGNAL button1_internal 		: std_logic						:='0'; 
	SIGNAL button2_internal 		: std_logic						:='0';
	SIGNAL button3_internal 		: std_logic						:='0';
	
	SIGNAL finished	: boolean 	:= FALSE;
	
	PROCEDURE check_read_buttons(
		SIGNAL data_out: IN std_logic_vector(31 DOWNTO 0);
		SIGNAL buttons : IN std_logic_vector(2 DOWNTO 0);
		SIGNAL button1_internal, button2_internal, button3_internal :  INOUT std_logic;
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL adress_lines : INOUT std_logic_vector(7 DOWNTO 0) --this are the last 8 bits of the addres line
	)
	IS
	BEGIN
		wait for 1 ms; 
		adress_lines <=  "00001000"; --08
		wait for 5 ms; 
		byte0_enable <= '1';
		button1_internal <= data_out(0);
		button2_internal <= data_out(1);
		button3_internal <= data_out(2);
		wait for 1 ms;
		ASSERT button1_internal = buttons(0) REPORT "button1 went wrong" severity error;
		ASSERT button2_internal = buttons(1) REPORT "button2 went wrong" severity error;
		ASSERT button3_internal = buttons(2) REPORT "button3 went wrong" severity error;
		
	END check_read_buttons;
	
	PROCEDURE check_read_dip_switches
	(
		SIGNAL data_out: IN std_logic_vector(31 DOWNTO 0);		
		SIGNAL dip_switches : INOUT std_logic_vector(8 DOWNTO 0);
		SIGNAL dip_switches_internal : INOUT std_logic_vector(8 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;		
		SIGNAL adress_lines : INOUT std_logic_vector(7 DOWNTO 0) --this are the last 8 bits of the addres line
	)
	IS BEGIN
		wait for 1 ms; 
		adress_lines <=  "00000100"; --FF04
		wait for 3 ms; 
		byte0_enable <= '1';
		dip_switches_internal(0) <= data_out(0);
		dip_switches_internal(1) <= data_out(1);
		dip_switches_internal(2) <= data_out(2);
		dip_switches_internal(3) <= data_out(3);
		dip_switches_internal(4) <= data_out(4);
		dip_switches_internal(5) <= data_out(5);
		dip_switches_internal(6) <= data_out(6);
		dip_switches_internal(7) <= data_out(7);
		wait for 5 ms;
		byte3_enable <= '1';
		adress_lines <=  "00001000"; --FF08
		wait for 3 ms;
		dip_switches_internal(8) <= data_out(31);
		wait for 1 ms;
		ASSERT dip_switches_internal = dip_switches REPORT "dipswitches went wrong" severity error;
		
	END check_read_dip_switches;
	
	PROCEDURE check_write_to_leds
	(
		SIGNAL data_in   : INOUT std_logic_vector(31 DOWNTO 0);
		SIGNAL leds 		: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL leds_internal : IN std_logic_vector(9 DOWNTO 0);
		SIGNAL adress_lines: INOUT std_logic_vector( 7 DOWNTO 0)
	)
	IS BEGIN
		byte0_enable <= '0';
		byte1_enable <= '0';
		byte2_enable <= '0';
		byte3_enable <= '0';
		
		wait for 2 ms; --to prevent problems from other procedures
		adress_lines <=  "00010100";
		data_in(31) <= leds_internal(8);
		byte3_enable <= '1'; 
		wait for 3 ms;
		adress_lines <=  "00010000";
		data_in(31) <= leds_internal(9);
		byte3_enable <= '1'; 
		wait for 3 ms;
		adress_lines <=  "00000000";
		data_in(7 DOWNTO 0) <= leds_internal(7 DOWNTO 0 );
		byte0_enable <= '1'; 
		wait for 5 ms;
				
		ASSERT leds = leds_internal REPORT "the leds went wrong" severity error;
	END check_write_to_leds; 
	
	
	PROCEDURE check_write_to_hex0
	(
		SIGNAL data_in   : INOUT std_logic_vector(31 DOWNTO 0);
		SIGNAL hex0 		: IN std_logic_vector(7 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL hex0_internal : IN std_logic_vector(7 DOWNTO 0);
		SIGNAL adress_lines: INOUT std_logic_vector( 7 DOWNTO 0)
	)
	IS BEGIN
		byte0_enable <= '0';
		byte1_enable <= '0';
		byte2_enable <= '0';
		byte3_enable <= '0';
		wait for 1 ms;
		byte0_enable <= '1';
		adress_lines <=  "00011100"; --FF1C
		data_in(7 downto 0) <= hex0_internal;	
		wait for 8 ms;
		ASSERT hex0 = hex0_internal REPORT "hex0 went wrong" severity error;
	END check_write_to_hex0; 
	
	
	PROCEDURE check_write_to_hex1
	(
		SIGNAL data_in   : INOUT std_logic_vector(31 DOWNTO 0);
		SIGNAL hex1 		: IN std_logic_vector(7 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL hex1_internal : IN std_logic_vector(7 DOWNTO 0);
		SIGNAL adress_lines: INOUT std_logic_vector( 7 DOWNTO 0)
	)
	IS BEGIN
		byte0_enable <= '0';
		byte1_enable <= '0';
		byte2_enable <= '0';
		byte3_enable <= '0';
		wait for 1 ms;
		byte0_enable <= '1';
		adress_lines <=  "00011000"; --FF1C
		data_in(7 downto 0) <= hex1_internal;	
		wait for 8 ms;
		ASSERT hex1 = hex1_internal REPORT "hex1 went wrong" severity error;
	END check_write_to_hex1; 
	
	PROCEDURE check_write_to_hex2
	(
		SIGNAL data_in   : INOUT std_logic_vector(31 DOWNTO 0);
		SIGNAL hex2 		: IN std_logic_vector(7 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL hex2_internal : IN std_logic_vector(7 DOWNTO 0);
		SIGNAL adress_lines: INOUT std_logic_vector( 7 DOWNTO 0)
	)
	IS BEGIN
		byte0_enable <= '0';
		byte1_enable <= '0';
		byte2_enable <= '0';
		byte3_enable <= '0';
		wait for 1 ms;
		byte0_enable <= '1';
		adress_lines <=  "00010100"; --FF1C
		data_in(7 downto 0) <= hex2_internal;	
		wait for 8 ms;
		ASSERT hex2 = hex2_internal REPORT "hex2 went wrong" severity error;
	END check_write_to_hex2; 
		
	PROCEDURE check_write_to_hex3
	(
		SIGNAL data_in   : INOUT std_logic_vector(31 DOWNTO 0);
		SIGNAL hex3	: IN std_logic_vector(7 DOWNTO 0);
		SIGNAL byte0_enable : INOUT std_logic;
		SIGNAL byte1_enable : INOUT std_logic;
		SIGNAL byte2_enable : INOUT std_logic;
		SIGNAL byte3_enable : INOUT std_logic;
		SIGNAL hex2_internal : IN std_logic_vector(7 DOWNTO 0);
		SIGNAL adress_lines: INOUT std_logic_vector( 7 DOWNTO 0)
	)
	IS BEGIN
		byte0_enable <= '0';
		byte1_enable <= '0';
		byte2_enable <= '0';
		byte3_enable <= '0';
		wait for 1 ms;
		byte0_enable <= '1';
		adress_lines <=  "00010000"; --FF1C
		data_in(7 downto 0) <= hex3_internal;	
		wait for 8 ms;
		ASSERT hex3 = hex3_internal REPORT "hex3 went wrong" severity error;
	END check_write_to_hex3; 
		
BEGIN
	
	tc: ENTITY work.inoutput 
		PORT MAP 
		(
			write_enable 	=> write_enable,
			read_enable 	=> read_enable,
			clk 			=> clk,
			reset 			=> reset,
			data_in 		=> data_in,
			data_out 		=> data_out,
			byte0_enable 	=> byte0_enable,
			byte1_enable 	=> byte1_enable,
			byte2_enable 	=> byte2_enable,
			byte3_enable 	=> byte3_enable,
			address_lines	=> adress_lines,
			hex0 			=> hex0,
			hex1 			=> hex1,
			hex2 			=> hex2,
			hex3 			=> hex3,
			buttons 		=> buttons,
			dip_switches 	=> dip_switches,
			leds 			=> leds
			
		);
		
	clk<= not clk AFTER 1 ms when not finished;
	PROCESS
		BEGIN
			reset <= '0';
			data_in <= (others => '0');
			WAIT FOR 1 ms;
			reset<='1';
			WAIT FOR 4 ms;
			write_enable <= '1';
			read_enable <= '0';
			--check the leds with different input strings
			wait FOR 1 ms;
			leds_internal <= "0000000001";
			check_write_to_leds(data_in, leds, byte0_enable, byte1_enable, byte2_enable, byte3_enable,  leds_internal, adress_lines);
			wait FOR 1 ms;
			leds_internal <= "1100000001";
			check_write_to_leds(data_in, leds, byte0_enable, byte1_enable, byte2_enable, byte3_enable,  leds_internal, adress_lines);
			read_enable <= '0';
			WAIT FOR 1 ms;
			-- checking the hex displays, hex internal signal is used to compare the outcome with the expected outcome
			hex0_internal <= "00000010";
			hex1_internal <= "00000100";
			hex2_internal <= "00001000";
			hex3_internal <= "00010000";
			
			write_enable <= '1';
			 check_write_to_hex0(
			data_in, hex0, byte0_enable, byte1_enable, byte2_enable, byte3_enable, hex0_internal, adress_lines);
			
			check_write_to_hex1(
			data_in, hex1, byte0_enable, byte1_enable, byte2_enable, byte3_enable, hex1_internal, adress_lines);
			
			check_write_to_hex2(
			data_in, hex2, byte0_enable, byte1_enable, byte2_enable, byte3_enable, hex2_internal, adress_lines);
			
			check_write_to_hex3(
			data_in, hex3, byte0_enable, byte1_enable, byte2_enable, byte3_enable, hex3_internal, adress_lines);
			--hereunder is checking the read functions
			
			write_enable <= '0';
			read_enable <=  '1';
			buttons(0) <= '0';
			buttons(1) <= '1';
			buttons(2) <= '0';
			dip_switches <= "000000000";
			wait for 6 ms; --give time to go through the metastability filter
			check_read_buttons( data_out , buttons, button1_internal, button2_internal, button3_internal, byte0_enable, byte1_enable, byte2_enable, byte3_enable, adress_lines);
			wait for 4 ms;
			check_read_dip_switches(data_out, dip_switches, dip_switches_internal, byte0_enable, byte1_enable, byte2_enable, byte3_enable, adress_lines);
			finished <= TRUE;
			WAIT;
		END PROCESS;
END bhv;