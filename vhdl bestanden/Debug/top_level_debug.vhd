LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--top level debug vhdl file
ENTITY top_level_debug IS
	GENERIC 
	(
		DATA_WIDTH : natural := 32;	--this only update the output and input ports no the rest if changed
		ADDR_WIDTH : natural := 14
	);

	PORT
	(
		clk 				: IN std_logic;
		reset				: IN std_logic;
				
		addr_a_outm			: OUT std_logic_vector(ADDR_WIDTH-1 DOWNTO 0); -- address to memory
		addr_b_outm			: OUT std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		data_a_outm			: OUT std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a_outm			: OUT std_logic := '1';
		q_a_inm				: IN  std_logic_vector((DATA_WIDTH -1) DOWNTO 0); -- input from memory
		q_b_inm				: IN  std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		byte_enable_outm	: OUT std_logic_vector(3 DOWNTO 0);
		
		addr_a_inm			: IN  std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		addr_b_inm			: IN  std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		data_a_inm			: IN  std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a_inm			: IN  std_logic := '1';
		q_a_outm			: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		q_b_outm			: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		byte_enable_inm		: IN  std_logic_vector(3 DOWNTO 0);
		
		dipswitches			: IN  std_logic_vector(9 DOWNTO 0);
		hex0				: OUT std_logic_vector(7 DOWNTO 0);
		hex1				: OUT std_logic_vector(7 DOWNTO 0);
		hex2				: OUT std_logic_vector(7 DOWNTO 0);
		hex3				: OUT std_logic_vector(7 DOWNTO 0);
		hex4				: OUT std_logic_vector(7 DOWNTO 0);
		hex5				: OUT std_logic_vector(7 DOWNTO 0);
		leds				: OUT std_logic_vector(9 DOWNTO 0);
		buttons				: IN  std_logic_vector(2 DOWNTO 0);  -- buttons does not include reset button		
		debug_on_of_out		: OUT std_logic		
		
	);
END top_level_debug;

ARCHITECTURE plof OF top_level_debug IS

	TYPE state_t IS 
	( 
		state_normal, 				-- just normal operation
		state_inoutput, 			-- inoutput is used
		state_debug					-- debug 		
	);

-- internal signals
	SIGNAL dipswitch_internal		: std_logic_vector(9 DOWNTO 0);
	SIGNAL dipswitches_debug		: std_logic_vector(7 DOWNTO 0);
	SIGNAL byte_in_debug_int		: std_logic_vector(7 DOWNTO 0);
	SIGNAl byte_out_debug_int		: std_logic_vector(7 DOWNTO 0);
	SIGNAL read_enable_debug_int	: std_logic;
	SIGNAL write_enable_debug_int	: std_logic;
	SIGNAL address_debug			: std_logic_vector(15 DOWNTO 0);
	SIGNAL hex0_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL hex1_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL hex2_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL hex3_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL hex4_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL hex5_debug_int			: std_logic_vector(6 DOWNTO 0);
	SIGNAL write_enable_inout_int	: std_logic;
	SIGNAL read_enable_inout_int	: std_logic;
	SIGNAL data_in_inout_int		: std_logic_vector(31 DOWNTO 0);
	SIGNAL data_out_inout_int		: std_logic_vector(31 DOWNTO 0);
	SIGNAL byte_enable_inout_int	: std_logic_vector(3 DOWNTO 0);
	SIGNAL address_lines_inout		: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex0_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex1_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex2_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex3_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex4_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL hex5_inout_int			: std_logic_vector(7 DOWNTO 0);
	SIGNAL dipswitches_inout		: std_logic_vector(8 DOWNTO 0);
	SIGNAL leds_internal			: std_logic_vector(9 DOWNTO 0);
	SIGNAL state_signal				: state_t;
	SIGNAL clock_cycles_passed		: std_logic;
	SIGNAL debug_on_of_internal		: std_logic;
	SIGNAL data_a_imn_debug			: std_logic_vector(31 DOWNTO 0);
	SIGNAL byte_enable_intern 		: std_logic_vector(3 DOWNTO 0);
	SIGNAL byte_in_debug_int_extra  : std_logic_vector(7 DOWNTO 0);
	SIGNAL addr_b_outm_intern  		: std_logic_vector(13 DOWNTO 0);
BEGIN
	inoutput_label: ENTITY work.inoutput
	PORT MAP
		(
			clk				=> clk,
			reset 			=> reset,
			write_enable 	=> write_enable_inout_int,
			read_enable		=> read_enable_inout_int,
			data_in			=> data_in_inout_int,
			data_out		=> data_out_inout_int,
			byte0_enable	=> byte_enable_inout_int(0),
			byte1_enable	=> byte_enable_inout_int(1),
			byte2_enable	=> byte_enable_inout_int(2),
			byte3_enable	=> byte_enable_inout_int(3),
			address_lines	=> address_lines_inout,
			hex0			=> hex0_inout_int,
			hex1			=> hex1_inout_int,
			hex2			=> hex2_inout_int,
			hex3			=> hex3_inout_int,
			
			buttons			=> buttons,
			dip_switches	=> dipswitches_inout,
			leds			=> leds_internal
		);


	debug_label: ENTITY work.debug
	PORT MAP 
		(
			clk	=> clk,
			dipswitches => dipswitches_debug,
			key1 		=> buttons(0),
			key2		=> buttons(1),
			key3 		=> buttons(2),
			byte_in		=> byte_in_debug_int,				-- TODO: zorgt dat hij de juiste byte pakt
			byte_out	=> byte_out_debug_int,
			b_read		=> read_enable_debug_int,
			b_write		=> write_enable_debug_int,
			address		=> address_debug,					
			hex0		=> hex0_debug_int,
			hex1		=> hex1_debug_int,
			hex2		=> hex2_debug_int,
			hex3		=> hex3_debug_int,
			hex4		=> hex4_debug_int,
			hex5		=> hex5_debug_int,
			debug_out	=> debug_on_of_internal,
			debug_in	=> dipswitches(9)
		);
		 	-- SELECTs debug mode. Most of the time this value is the same as debug. 
	dipswitches_inout  		<=dipswitches(8 DOWNTO 0); 		-- inoutput uses 9 dip switches
	dipswitches_debug		<=dipswitches(7 DOWNTO 0); 		-- debug uses 8 dip switches
	debug_on_of_out			<= debug_on_of_internal;
	
	--putting lines together for the inoutput file
	byte_enable_inout_int	<=byte_enable_inm;	
	WITH we_a_inm SELECT address_lines_inout <=
		addr_b_inm(5 DOWNTO 0)&"00" WHEN '0',
		addr_a_inm(5 DOWNTO 0)&"00" WHEN OTHERS;
	data_in_inout_int <= data_a_inm;	
	-- the processor should be able to finish the instruction before going to debug mode
	PROCESS(clk, reset)
	BEGIN
		IF reset = '0' THEN
			clock_cycles_passed <= '0';
			
		ELSIF rising_edge(clk) THEN
			IF dipswitches(9) = '1' then 
				IF clock_cycles_passed = '0' THEN 
					clock_cycles_passed <= '1';
				END IF;
			ELSE
				clock_cycles_passed <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	-- debug mode: the last 2 bits of the address define which byte is addressed
	PROCESS(byte_out_debug_int, write_enable_debug_int, address_debug)
	BEGIN
		IF write_enable_debug_int = '1' THEN
			IF address_debug(1 DOWNTO 0) = "00" THEN
				data_a_imn_debug(7 DOWNTO 0) <= byte_out_debug_int;
			ELSE 
				data_a_imn_debug(7 DOWNTO 0) <= (OTHERS => '0');
			END IF;
			
			IF address_debug(1 DOWNTO 0) = "01" THEN				
				data_a_imn_debug(15 DOWNTO 8) 	<= byte_out_debug_int;
			ELSE 
				data_a_imn_debug(15 DOWNTO 8) <=  (OTHERS  => '0');
			END If;
			
			IF address_debug(1 DOWNTO 0) = "10" THEN				
				data_a_imn_debug(23 DOWNTO 16) 	<= byte_out_debug_int;
			ELSE 
				data_a_imn_debug(23 DOWNTO 16) <=  (OTHERS  => '0');
			END IF;
			
			IF address_debug(1 DOWNTO 0) = "11" THEN				
				data_a_imn_debug(31 DOWNTO 24) 	<= byte_out_debug_int;
			ELSE 
				data_a_imn_debug(31 DOWNTO 24) <=  (OTHERS  => '0');				
			END IF;
		ELSE
			data_a_imn_debug <= (OTHERS => '0');
		END IF;
	END PROCESS;
	
	PROCESS(we_a_inm)
	BEGIN
		read_enable_inout_int <= not we_a_inm;
		write_enable_inout_int <= we_a_inm;			
	END PROCESS;
	
	
	PROCESS(read_enable_debug_int, q_b_inm, address_debug)
	BEGIN 		
		IF read_enable_debug_int = '1' THEN
			IF address_debug(1 DOWNTO 0) = "00" THEN
				byte_enable_intern 	<= "0001";
				byte_in_debug_int_extra 	<= q_b_inm(7 DOWNTO 0);	
			ELSIF address_debug(1 DOWNTO 0) = "01" THEN
				byte_enable_intern 	<= "0010";
				byte_in_debug_int_extra 	<= q_b_inm(15 DOWNTO 8);
			ELSIF address_debug(1 DOWNTO 0) = "10" THEN
				byte_enable_intern 	<= "0100";
				byte_in_debug_int_extra 	<= q_b_inm(23 DOWNTO 16);
			ELSIF address_debug(1 DOWNTO 0) = "11" THEN
				byte_enable_intern 	<= "1000";
				byte_in_debug_int_extra 	<= q_b_inm(31 DOWNTO 24);
			ELSE 
				byte_in_debug_int_extra	<= (OTHERS => '0');
				byte_enable_intern 	<= "0000";
			END IF;
			addr_b_outm_intern 			<= address_debug(15 DOWNTO 2);
		ELSE
			byte_in_debug_int_extra <= (OTHERS=> '0');
			byte_enable_intern  <= (OTHERS => '0');
			addr_b_outm_intern <= (OTHERS => '0');
		END IF;	
	END PROCESS;
	
	PROCESS(addr_a_inm, addr_b_inm, debug_on_of_internal, clock_cycles_passed)
	BEGIN
		IF ((clock_cycles_passed = '1') and (debug_on_of_internal = '1')) THEN
			state_signal <= state_debug;
			
		ELSIF ((addr_a_inm(13 DOWNTO 6) = "11111111" )or (addr_b_inm(13 DOWNTO 6) = "11111111")) then --if one of both adress is higher then FF00 then it is for in output
			state_signal <= state_inoutput;
			
		ELSE
			state_signal <= state_normal;
			
		END IF;
	END PROCESS;
	
	WITH state_signal SELECT addr_a_outm <=
		addr_a_inm WHEN state_normal,
		address_debug(15 DOWNTO 2) WHEN state_debug,
		(OTHERS => '0') WHEN OTHERS;
	WITH state_signal SELECT addr_b_outm <=
		addr_b_inm WHEN state_normal,
		addr_b_outm_intern WHEN state_debug,
		(OTHERS => '0') WHEN OTHERS;
		
	WITH state_signal SELECT we_a_outm <=
		we_a_inm WHEN state_normal,
		write_enable_debug_int WHEN state_debug,
		'0' WHEN OTHERS;
		
	WITH state_signal SELECT data_a_outm <= --
		data_a_inm WHEN state_normal,
		data_a_imn_debug WHEN state_debug,  --comes from a process
		(OTHERS => '0') WHEN OTHERS;
		
	WITH state_signal SELECT q_a_outm <=
		q_a_inm WHEN state_normal,
		(OTHERS => '0') WHEN OTHERS;
	
	WITH state_signal SELECT q_b_outm <=
		q_b_inm WHEN state_normal,
		data_out_inout_int WHEN state_inoutput,
		(OTHERS => '0') WHEN OTHERS;
		
	WITH state_signal SELECT byte_enable_outm <=
		byte_enable_inm WHEN state_normal,
		byte_enable_intern WHEN state_debug, --comes from a process
		(OTHERS => '0') WHEN OTHERS;
		
	WITH state_signal SELECT leds <=
		leds_internal WHEN state_normal,
		leds_internal WHEN state_inoutput,
		(OTHERS => '0') WHEN OTHERS;
		
	-- hexadecimal displays	
	WITH state_signal SELECT hex0 <=
		hex0_inout_int WHEN state_normal,
		hex0_inout_int WHEN state_inoutput,
		'0'& hex0_debug_int WHEN OTHERS;
	WITH state_signal SELECT hex1 <=
		hex1_inout_int WHEN state_normal,
		hex1_inout_int WHEN state_inoutput,
		'0'& hex1_debug_int WHEN OTHERS;
	WITH state_signal SELECT hex2 <=
		hex2_inout_int WHEN state_normal,
		hex2_inout_int WHEN state_inoutput,
		'0'& hex2_debug_int WHEN OTHERS;
	WITH state_signal SELECT hex3 <=
		hex3_inout_int WHEN state_normal,
		hex3_inout_int WHEN state_inoutput,
		'0'& hex3_debug_int WHEN OTHERS;
	WITH state_signal SELECT hex4 <=
		(OTHERS => '0') WHEN state_normal,
		(OTHERS => '0') WHEN state_inoutput,
		'0'& hex4_debug_int WHEN OTHERS;
	WITH state_signal SELECT hex5 <=
		(OTHERS => '0') WHEN state_normal,
		(OTHERS => '0') WHEN state_inoutput,
		'0'& hex5_debug_int WHEN OTHERS;
		
	WITH state_signal SELECT byte_in_debug_int <=
		(OTHERS => '0') WHEN state_normal,
		(OTHERS => '0') WHEN state_inoutput,
		byte_in_debug_int_extra WHEN OTHERS; -- byte_in_debug_int_extra is specified in a process. And it is better

	
	

	
	
	
END plof;	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



