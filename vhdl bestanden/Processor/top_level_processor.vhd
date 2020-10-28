LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY top_level_processor IS
	PORT
	(
		clk						: IN  std_logic;
		reset					: IN  std_logic;
		debug					: IN  std_logic;
		data_from_memory		: IN  std_logic_vector(31 DOWNTO 0);
		
		instruction_in			: IN  std_logic_vector(31 DOWNTO 0);
		
		read_enable_out			: OUT std_logic;
		write_enable_out 		: OUT std_logic;
		output_address			: OUT std_logic_vector(13 DOWNTO 0);
		
		byte_enable 			: OUT std_logic_vector( 3 DOWNTO 0);
		data_to_memory 			: OUT std_logic_vector(31 DOWNTO 0);
		
		read_enable_instruction	: OUT std_logic;
		instruction_address_out	: OUT std_logic_vector(31 DOWNTO 0); 
	);
END top_level_processor;

ARCHITECTURE bhv OF top_level_processor IS

	SIGNAL 	read_enable_out			: std_logic;
	SIGNAL 	output_address			: std_logic_vector(13 DOWNTO 0);

	SIGNAL	byte_enable 			: std_logic_vector( 3 DOWNTO 0);

	SIGNAL	read_enable_instruction	: std_logic;
	SIGNAL	instruction_address_out	: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL clk 						: std_logic := '0';
	SIGNAL reset 					: std_logic := '0';
	SIGNAL register_in				: std_logic_vector(31 DOWNTO 0);
	SIGNAL select_register_a 		: std_logic_vector(4 DOWNTO 0);
	SIGNAL select_register_b 		: std_logic_vector(4 DOWNTO 0);
	SIGNAL register_a_out			: std_logic_vector(31 DOWNTO 0);
	SIGNAL register_b_out			: std_logic_vector(31 DOWNTO 0);
		
	SIGNAL byte 					: std_logic						:= '0';
	SIGNAL write_enable 			: std_logic						:= '0';
	SIGNAL read_enable 				: std_logic						:= '0';
	SIGNAL address 					: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL data_from_processor 		: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL data_from_memory			: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
		  

	SIGNAL write_enable_out 		: std_logic;
				
	SIGNAL data_to_processor 		: std_logic_vector(31 DOWNTO 0);
	SIGNAL data_to_memory 			: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL alu_opcode              	: alu_op;  --defined in alu_testbench
	SIGNAL register_a			   	: signed(31 DOWNTO 0);
	SIGNAL register_b			   	: signed(31 DOWNTO 0);
	SIGNAL register_out			   	: signed(31 DOWNTO 0);
	SIGNAL flags				   	: std_logic_vector(3 downto 0); -- on this moment 4 flags are enough but fur futher expansion 4 bits are reserved	

	SIGNAL debug					: std_logic						:='0';

	SIGNAL alu_flags				: std_logic_vector(3 DOWNTO 0)	:="0000";

	SIGNAL jump_address				: std_logic_vector(31 DOWNTO 0)	:=x"00000000";
	SIGNAL instruction_in			: std_logic_vector(31 DOWNTO 0)	:=x"00000000";

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
	
BEGIN bhv OF top_level_processor

cu: ENTITY work.control_unit
		PORT MAP
		(
			clk						=> clk,
			reset					=> reset,
			debug					=> debug,

			alu_flags				=> alu_flags,

			jump_address			=> jump_address,
			instruction_in			=> instruction_in,

			--ALU control
			alu_opcode              => alu_opcode,

			--Register control
			register_write_enable	=> register_write_enable,
			select_register_a 		=> select_register_a,
			select_register_b 		=> select_register_b,

			--Memory control
			byte_operation			=> byte_operation,
			memory_write_enable		=> memory_write_enable,
			read_enable_data		=> read_enable_data,
			read_enable_instruction	=> read_enable_instruction,
			instruction_address_out	=> instruction_address_out,

			--Mux control
			select_bmux				=> select_bmux,
			select_dmux				=> select_dmux,
			immediate_out			=> immediate_out,
			program_counter_out		=> program_counter_out
		);

al: ENTITY work.alu 
		PORT MAP 
		(
			reset			=> reset,
			alu_opcode		=> alu_opcode,
			register_a		=> register_a,
			register_b 		=> register_b,
			register_out 	=> register_out,
			flags			=> flags
		);
		
mc: ENTITY work.memory_controller
		PORT MAP 
		(
			byte 				=> byte,
			write_enable 		=> write_enable,
			read_enable 		=> read_enable,
			address 			=> address,
			data_from_processor => data_from_processor,
			data_from_memory	=> data_from_memory,
													
			read_enable_out		=> read_enable_out,
			write_enable_out 	=> write_enable_out,
			output_address		=> output_address,
								 					
			byte_enable 		=> byte_enable,
			data_to_processor 	=> data_to_processor,
			data_to_memory 		=> data_to_memory
		);

rg: ENTITY work.registers
		PORT MAP 
		(
			clk					=> clk,
			reset				=> reset,
			register_in			=> register_in,		
			select_register_a 	=> select_register_a,
			select_register_b 	=> select_register_b,
			write_enable		=> write_enable,
			register_a_out		=> register_a_out,
			register_b_out		=> register_b_out
		);

--B MUX		
	op_b <= '1' WHEN select_bmux = '1' ELSE '0';
		CASE sel_b IS
			WHEN "00" => output <= a1 ; --from register_b
			WHEN "01" => output <= a2 ; --from control unit
		END CASE;
	
--D MUX
	op_d <= '1' WHEN select_dmux = '1' ELSE '0';
		CASE sel_d IS
			WHEN "00" => output <= a1 ; --register_out
			WHEN "01" => output <= a2 ; --from control_unit
			WHEN "10" => output <= a3 ; --from memory
		END CASE;



END bhv;