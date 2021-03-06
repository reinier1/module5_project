LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY top_level IS
	PORT 
	(
		CLOCK_50 	: IN  std_logic;
		
		KEY			: IN  std_logic_vector(3 DOWNTO 0);
		SW			: IN  std_logic_vector(9 DOWNTO 0);
		
		HEX0		: OUT std_logic_vector(6 DOWNTO 0);
		HEX1		: OUT std_logic_vector(6 DOWNTO 0);
		HEX2		: OUT std_logic_vector(6 DOWNTO 0);
		HEX3		: OUT std_logic_vector(6 DOWNTO 0);
		HEX4		: OUT std_logic_vector(6 DOWNTO 0);
		HEX5		: OUT std_logic_vector(6 DOWNTO 0);
		
		LEDR		: OUT std_logic_vector(9 DOWNTO 0)
	);
	
END top_level;
ARCHITECTURE bhv OF top_level IS
	SIGNAL debug					: std_logic;

	SIGNAL data_from_memory			: std_logic_vector(31 DOWNTO 0);
	SIGNAL instruction_in			: std_logic_vector(31 DOWNTO 0);

	SIGNAL read_enable_out			: std_logic;
	SIGNAL write_enable_out 		: std_logic;
	SIGNAL output_address			: std_logic_vector(13 DOWNTO 0);

	SIGNAL byte_enable 				: std_logic_vector( 3 DOWNTO 0);
	SIGNAL data_to_memory 			: std_logic_vector(31 DOWNTO 0);

	SIGNAL read_enable_instruction	: std_logic;
	SIGNAL instruction_address_out	: std_logic_vector(13 DOWNTO 0);
						  
	SIGNAL addr_a_outm			: std_logic_vector(13 DOWNTO 0); -- address to memory
	SIGNAL addr_b_outm			: std_logic_vector(13 DOWNTO 0);
	SIGNAL data_a_outm			: std_logic_vector((31) DOWNTO 0);
	SIGNAL we_a_outm			: std_logic := '1';
	SIGNAL q_a_inm				: std_logic_vector((31) DOWNTO 0); -- input from memory
	SIGNAL q_b_inm				: std_logic_vector((31) DOWNTO 0);
	SIGNAL byte_enable_outm		: std_logic_vector(3 DOWNTO 0);
	SIGNAL HEX0_internal		: std_logic_vector(7 DOWNTO 0);		
	SIGNAL HEX1_internal		: std_logic_vector(7 DOWNTO 0);	
	SIGNAL HEX2_internal		: std_logic_vector(7 DOWNTO 0);		
	SIGNAL HEX3_internal		: std_logic_vector(7 DOWNTO 0);	
	SIGNAL HEX4_internal		: std_logic_vector(7 DOWNTO 0);		
	SIGNAL HEX5_internal		: std_logic_vector(7 DOWNTO 0);	
BEGIN
	HEX0 <= HEX0_internal(6 DOWNTO 0);
	HEX1 <= HEX1_internal(6 DOWNTO 0);
	HEX2 <= HEX2_internal(6 DOWNTO 0);
	HEX3 <= HEX3_internal(6 DOWNTO 0);
	HEX4 <= HEX4_internal(6 DOWNTO 0);
	HEX5 <= HEX5_internal(6 DOWNTO 0);
	
	cpu: ENTITY work.top_level_processor
		PORT MAP
		(
			clk						=> CLOCK_50,
			reset					=> KEY(0),
			debug					=> debug,
			data_from_memory		=> data_from_memory,
			
			instruction_in			=> instruction_in,
			
			read_enable_out			=> read_enable_out,
			write_enable_out 		=> write_enable_out,
			output_address			=> output_address,
			
			byte_enable 			=> byte_enable,
			data_to_memory 			=> data_to_memory,
			
			read_enable_instruction	=> read_enable_instruction,
			instruction_address_out	=> instruction_address_out
		);
		
	io: ENTITY work.top_level_debug
		PORT MAP 
		(
			clk 				=> CLOCK_50,		
			reset				=> KEY(0),
					
			addr_a_outm			=> addr_a_outm,
			addr_b_outm			=> addr_b_outm,	
			data_a_outm			=> data_a_outm,		
			we_a_outm			=> we_a_outm,	
			q_a_inm				=> q_a_inm,		
			q_b_inm				=> q_b_inm,		
			byte_enable_outm	=> byte_enable_outm,
								   
			addr_a_inm			=> output_address,
			addr_b_inm			=> instruction_address_out,
			data_a_inm			=> data_to_memory,
			we_a_inm			=> write_enable_out,
			q_a_outm			=> data_from_memory,
			q_b_outm			=> instruction_in,
			byte_enable_inm		=> byte_enable,
								   
			dipswitches			=> SW,
			hex0				=> HEX0_internal,
			hex1				=> HEX1_internal,
			hex2				=> HEX2_internal,
			hex3				=> HEX3_internal,
			hex4				=> HEX4_internal,
			hex5				=> HEX5_internal,
			leds				=> LEDR,
			buttons				=> KEY(3 DOWNTO 1),
								   
			debug_on_of_out		=> debug
		);
		
	mem: ENTITY work.four_byte_enable_memory
		PORT MAP 
		(
			clk			=> CLOCK_50,	
			addr_a		=> addr_a_outm,
			addr_b		=> addr_b_outm,	
			data_a		=> data_a_outm,
			we_a		=> we_a_outm,
							
			q_a			=> q_a_inm,
			q_b			=> q_b_inm,
			byte_enable	=> byte_enable_outm
		);
	
END bhv;