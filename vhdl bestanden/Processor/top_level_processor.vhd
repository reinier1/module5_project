LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY top_level_processor IS
	PORT
	(
		clk						: IN  std_logic;					--
		reset					: IN  std_logic;					--
		debug					: IN  std_logic;					--
		data_from_memory		: IN  std_logic_vector(31 DOWNTO 0);--
		
		instruction_in			: IN  std_logic_vector(31 DOWNTO 0);--
		
		read_enable_out			: OUT std_logic;					--
		write_enable_out 		: OUT std_logic;					--
		output_address			: OUT std_logic_vector(13 DOWNTO 0);--
		
		byte_enable 			: OUT std_logic_vector( 3 DOWNTO 0);--
		data_to_memory 			: OUT std_logic_vector(31 DOWNTO 0);--
		
		read_enable_instruction	: OUT std_logic;					--
		instruction_address_out	: OUT std_logic_vector(13 DOWNTO 0)	--
	);
END top_level_processor;

ARCHITECTURE bhv OF top_level_processor IS

	SIGNAL register_in				: std_logic_vector(31 DOWNTO 0);
	SIGNAL select_register_a 		: std_logic_vector(4 DOWNTO 0);
	SIGNAL select_register_b 		: std_logic_vector(4 DOWNTO 0);
	SIGNAL register_b_out			: std_logic_vector(31 DOWNTO 0);
				
	SIGNAL data_to_processor 		: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL alu_opcode              	: alu_op;  --defined in alu_testbench
	SIGNAL register_a			   	: std_logic_vector(31 DOWNTO 0);
	SIGNAL register_b			   	: std_logic_vector(31 DOWNTO 0);
	SIGNAL register_out			   	: std_logic_vector(31 DOWNTO 0);

	SIGNAL alu_flags				: std_logic_vector(3 DOWNTO 0);

	--Register control
	SIGNAL register_write_enable	: std_logic;

	--Memory control
	SIGNAL byte_operation			: std_logic;
	SIGNAL memory_write_enable		: std_logic;
	SIGNAL read_enable_data			: std_logic;

	--Mux control
	SIGNAL select_bmux				: std_logic;
	SIGNAL select_dmux				: mux_t;
	SIGNAL immediate_out			: std_logic_vector(31 DOWNTO 0);
	SIGNAL program_counter_out		: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL instruction_address_i	: std_logic_vector(31 DOWNTO 0);
	
BEGIN
	instruction_address_out<=instruction_address_i(15 DOWNTO 2);
cu: ENTITY work.control_unit
		PORT MAP
		(
			clk						=> clk,						--
			reset					=> reset,					--
			debug					=> debug,					--

			alu_flags				=> alu_flags,				--

			jump_address			=> register_b,				--
			instruction_in			=> instruction_in,			--

			--ALU control
			alu_opcode              => alu_opcode,				--

			--Register control
			register_write_enable	=> register_write_enable,	--
			select_register_a 		=> select_register_a,		--
			select_register_b 		=> select_register_b,		--

			--Memory control
			byte_operation			=> byte_operation,			--
			memory_write_enable		=> memory_write_enable,		--
			read_enable_data		=> read_enable_data,		--
			read_enable_instruction	=> read_enable_instruction,	--
			instruction_address_out	=> instruction_address_i,	--

			--Mux control
			select_bmux				=> select_bmux,				--
			select_dmux				=> select_dmux,				--
			immediate_out			=> immediate_out,			--
			program_counter_out		=> program_counter_out		--
		);

al: ENTITY work.alu 
		PORT MAP 
		(
			reset							=> reset,				--
			alu_opcode						=> alu_opcode,			--
			register_a						=> signed(register_a),	--
			register_b 						=> signed(register_b),	--
			std_logic_vector(register_out) 	=> register_out,		--
			flags							=> alu_flags			--
		);
		
mc: ENTITY work.memory_controller
		PORT MAP 
		(
			byte 				=> byte_operation,			--
			write_enable 		=> memory_write_enable,		--
			read_enable 		=> read_enable_data,		--
			address 			=> register_b,				--
			data_from_processor => register_a,				--
			data_from_memory	=> data_from_memory,		--
													
			read_enable_out		=> read_enable_out,			--	data
			write_enable_out 	=> write_enable_out,		--	data
			output_address		=> output_address,			--
								 					
			byte_enable 		=> byte_enable,				--
			data_to_processor 	=> data_to_processor,		--
			data_to_memory 		=> data_to_memory			--
		);

rg: ENTITY work.registers
		PORT MAP 
		(
			clk					=> clk,						--
			reset				=> reset,					--
			register_in			=> register_in,				--
			select_register_a 	=> select_register_a,		--
			select_register_b 	=> select_register_b,		--
			write_enable		=> register_write_enable,	--
			register_a_out		=> register_a,				--
			register_b_out		=> register_b_out			--
		);

--B MUX		
	register_b 	<= 	register_b_out 		WHEN select_bmux = '0' 		ELSE immediate_out;

--D MUX
	register_in <= 	register_out 		WHEN select_dmux = mux_alu 	ELSE
					program_counter_out	WHEN select_dmux = mux_pc  	ELSE
					data_to_processor;

END bhv;