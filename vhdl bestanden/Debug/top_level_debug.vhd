LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL
LIBRARY work;
USE work.memory_package.ALL;
ENTITY top_level_debug IS

	PORT
	(
		clk 				: IN std_logic;
		reset				: IN std_logic;
				
		addr_a_outm			: OUT std_logic_vector(ADDR_WIDTH-1 DOWNTO 0); -- address to memory
		addr_b_outm			: OUT std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		data_a_outm			: OUT std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a_outm			: OUT std_logic := '1';
		q_a_inm				: IN std_logic_vector((DATA_WIDTH -1) DOWNTO 0); -- input from memory
		q_b_inm				: IN std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		byte_enable_outm	: OUT std_logic_vector(3 DOWNTO 0);
		
		addr_a_inm			: IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		addr_b_inm			: IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		data_a_inm			: IN std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a_inm			: IN std_logic := '1';
		q_a_outm			: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		q_b_outm			: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		byte_enable_inm		: IN std_logic_vector(3 DOWNTO 0);
		
		dipswitches			: IN std_logic_vector(9 DOWNTO 0);
		hex0				: OUT std_logic_vector(7 DOWNTO 0);
		hex1				: OUT std_logic_vector(7 DOWNTO 0);
		hex2				: OUT std_logic_vector(7 DOWNTO 0);
		hex3				: OUT std_logic_vector(7 DOWNTO 0);
		hex4				: OUT std_logic_vector(7 DOWNTO 0);
		hex5				: OUT std_logic_vector(7 DOWNTO 0);
		leds				: OUT std_logic_vector(9 DOWNTO 0);
		buttons				: IN std_logic_vector(2 DOWNTO 0);  -- buttons does not include reset button
		
		debug_onof			: OUT std_logic;
		
	);
END top_level_debug;

ARCHITECTURE plof OF top_level_debug IS

	TYPE state_t IS 
	( 
		state_normal, 				-- just normal operation
		state_inoutput, 			-- inoutput is used
		state_beginning_debug, 		-- debug state
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
			hex4			=> hex4_inout_int,
			hex5			=> hex5_inout_int,
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
			address		=> address_debug,					-- keihard negeren voor debug hardware
			hex0		=> hex0_debug_int,
			hex1		=> hex1_debug_int,
			hex2		=> hex2_debug_int,
			hex3		=> hex3_debug_int,
			hex4		=> hex4_debug_int,
			hex5		=> hex5_debug_int		
		);
			
	
PROCESS
BEGIN
	IF state_signal = state_normal THEN
		addr_a_outm 		<= addr_a_inm;
		addr_b_outm 		<= addr_b_inm;
		we_a_outm 			<= we_a_inm;
		data_a_outm 		<= data_a_inm;
		q_a_outm			<= q_a_inm;
		q_b_outm			<= q_b_inm;
		byte_enable_outm	<= byte_enable_inm;
		
	ELSIF state_signal = state_inoutput THEN
		we_a_outm <= '0';
		IF we_a_inm = '1' THEN
			write_enable_inout_int	<= we_a_inm;
			address_lines_inout		<= addr_a_inm(7 DOWNTO 0);				-- if write enable is one, then use port a
			data_in_inout_int		<= data_a_inm;
			read_enable_inout_int	<= '0';
		ELSE 
			read_enable_inout_int	<= '1';
			address_lines_inout		<= addr_b_inm(7 DOWNTO 0);				-- for reading from memory, port b is used
			q_b_outm				<= data_out_inout_int;
			write_enable_inout_int	<= '0';
		END IF;
		byte_enable_inout_int		<= byte_enable_inm;
		
	ELSIF state_signal = state_beginning_debug THEN
		IF write_enable_debug_int = '1' THEN
			IF address_debug(1 DOWNTO 0) = "00" THEN
				byte_enable_outm	<= "0001";
			ELSIF address_debug(1 DOWNTO 0) = "01" THEN
				byte_enable_outm	<= "0010";
			ELSIF address_debug(1 DOWNTO 0) = "10" THEN
				byte_enable_outm	<= "0100";
			ELSIF address_debug(1 DOWNTO 0) = "11" THEN
				byte_enable_outm	<= "1000";
			END IF;
			addr_a_outm				<= address_debug(31 DOWNTO 2) & "00";
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

PROCESS(clk, reset)

--process on clk or reset

BEGIN