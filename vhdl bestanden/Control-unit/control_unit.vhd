library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY debug IS
	PORT 
	(
		clk						: IN std_logic;
		reset					: IN std_logic;
		debug					: IN std_logic;
		
		alu_flags				: IN std_logic_vector(3 DOWNTO 0);
		
		jump_address			: IN std_logic_vector(31 DOWNTO 0);
		--ALU control
		alu_opcode              : OUT alu_op;
		--Register control
		write_enable			: OUT std_logic;
		select_register_a 		: OUT std_logic_vector(4 DOWNTO 0);
		select_register_b 		: OUT std_logic_vector(4 DOWNTO 0);
		--Memory control
		byte_operation			: OUT std_logic;
		write_enable 			: OUT std_logic;
		read_enable_data		: OUT std_logic;
		read_enable_instruction	: OUT std_logic;
		instruction_address_out	: OUT std_logic_vector(31 DOWNTO 0);
		--Mux control
		select_bmux				: OUT std_logic;
		select_dmux				: OUT mux_t;
		immediate_out			: OUT std_logic_vector(31 DOWNTO 0);
		program_counter_out		: OUT std_logic_vector(31 DOWNTO 0);
	);
END debug;

ARCHITECTURE bhv OF debug IS
	TYPE state_t IS 
	( 
		state_reset, 		-- At startup: load new instruction and go to instruction
		state_instruction, 	-- Execute instruction and fetch new one if we are loading go to store_load
		state_store_load, 	-- Store loaded memory into register and fetch new instruction
		state_debug 		-- When we are currently debugging if we are done with debugging goto reset
	);
	
	SIGNAL next_state 			: state_t;
	SIGNAL state 				: state_t;
	SIGNAL program_counter		: std_logic_vector(13 DOWNTO 0);
	
	SIGNAL instruction_register	: std_logic_vector(31 DOWNTO 0);
	SIGNAL instruction			: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL ins_op				: std_logic_vector(4 DOWNTO 0);
	SIGNAL ins_reg_a			: std_logic_vector(4 DOWNTO 0);
	SIGNAL ins_reg_b			: std_logic_vector(4 DOWNTO 0);
	SIGNAL ins_imm16			: std_logic_vector(15 DOWNTO 0);
	SIGNAL ins_imm_en			: std_logic;
	
	SIGNAL instruction_load		: boolean;
	SIGNAL instruction_store	: boolean;
	SIGNAL instruction_alu		: boolean;
	SIGNAL instruction_branch	: boolean;
	SIGNAL instruction_finished	: boolean;
BEGIN
	--Seperate different part of the instruction
	ins_op	 				<= instruction(31 DOWNTO 27);
	ins_imm_en				<= instruction(26);
	ins_reg_a				<= instruction(25 DOWNTO 21);
	ins_reg_b				<= instruction(20 DOWNTO 16);
	ins_imm16				<= instruction(15 DOWNTO 0);
	
	--Internal signals when specific instruction are executing/done
	instruction_load		<= ins_op = OP_LB | ins_op = OP_LW;
	instruction_store		<= ins_op = OP_SB | ins_op = OP_SW;
	instruction_alu			<= ins_op(4 DOWNTO 3)="00";
	instruction_branch		<= ins_op(4 DOWNTO 3)="01";
	instruction_finished	<= (instruction_load and state=state_store_load) | 
								(not instruction_load and state=state_instruction) 
	
	program_counter_out		<= x"0000" & program_counter & "00";
	immediate_out			<= std_logic_vector(resize(signed(ins_imm16),32));
							
	
		
	
	
	PROCESS(clk,reset)
	BEGIN
		IF reset='0' THEN
			state<=state_reset;
		ELSIF rising_edge(clk) THEN 
			state<=next_state;
		END IF;
	END PROCESS;
	
	PROCESS
	BEGIN 
		IF debug='1' and ( instruction_finished | state=state_debug THEN
			next_state<=state_debug;
		ELSE
			CASE state IS 
				WHEN state_reset 		=> 	next_state<=state_reset;
				WHEN state_debug 		=> 	next_state<=state_reset;
				WHEN state_instruction 	=> 	IF instruction_finished 
												THEN next_state<=state_instruction; 
												ELSE next_state<=state_store_load;
											END IF;	
				WHEN state_store_load	=> 	next_state<=state_instruction;
				WHEN OTHERS				=> 	next_state<=state_reset;
			END CASE;
		END IF;
	END PROCESS;
	
END bhv;