library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY control_unit IS
	PORT 
	(
		clk						: IN std_logic;
		reset					: IN std_logic;
		debug					: IN std_logic;
		
		alu_flags				: IN std_logic_vector(3 DOWNTO 0);	
		
		jump_address			: IN std_logic_vector(31 DOWNTO 0);
		instruction_in			: IN std_logic_vector(31 DOWNTO 0);
		
		--ALU control
		alu_opcode              : OUT alu_op;						
		
		--Register control
		register_write_enable	: OUT std_logic;
		select_register_a 		: OUT std_logic_vector(4 DOWNTO 0);
		select_register_b 		: OUT std_logic_vector(4 DOWNTO 0);
		
		--Memory control
		byte_operation			: OUT std_logic;
		memory_write_enable		: OUT std_logic;
		read_enable_data		: OUT std_logic;
		read_enable_instruction	: OUT std_logic;
		instruction_address_out	: OUT std_logic_vector(31 DOWNTO 0); 
		
		--Mux control
		select_bmux				: OUT std_logic;
		select_dmux				: OUT mux_t;
		immediate_out			: OUT std_logic_vector(31 DOWNTO 0);
		program_counter_out		: OUT std_logic_vector(31 DOWNTO 0)
	);
END control_unit;

ARCHITECTURE bhv OF control_unit IS
	TYPE state_t IS 
	( 
		state_reset, 		-- At startup: load new instruction and go to instruction
		state_instruction, 	-- Execute instruction and fetch new one if we are loading go to store_load
		state_store_load, 	-- Store loaded memory into register and fetch new instruction
		state_debug 		-- When we are currently debugging if we are done with debugging goto reset
	);
	
	SIGNAL next_state 			: state_t;
	SIGNAL state 				: state_t;
	SIGNAL program_counter		: unsigned(13 DOWNTO 0);
	SIGNAL next_pc				: unsigned(13 DOWNTO 0);
	
	SIGNAL internal_flags		: unsigned(3 DOWNTO 0);
	
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
	instruction_load		<= (ins_op = OP_LB) OR (ins_op = OP_LW);
	instruction_store		<= (ins_op = OP_SB) OR (ins_op = OP_SW);
	instruction_alu			<= ins_op(4 DOWNTO 3)="00";
	instruction_branch		<= ins_op(4 DOWNTO 3)="01";
	instruction_finished	<= (instruction_load and state=state_store_load) OR 
								(not instruction_load and state=state_instruction);
	
	--Outputs constructed from internal signals
	program_counter_out		<= std_logic_vector(x"0000" & program_counter & "00");
	immediate_out			<= std_logic_vector(resize(signed(ins_imm16),32));
	select_register_a		<= ins_reg_a;
	select_register_b		<= ins_reg_b;
	
	--Memory output signals
	read_enable_instruction	<= '1' WHEN instruction_finished OR (state=state_reset AND reset='1') ELSE '0';
	read_enable_data		<= '1' WHEN instruction_load and state=state_instruction ELSE '0';
	memory_write_enable		<= '1' WHEN instruction_store and state=state_instruction ELSE '0';
	byte_operation			<= '1' WHEN (ins_op=OP_LB OR ins_op=OP_SB) ELSE '0';
	
	--Internal instruction is normally directly taken from memory. This can be faster then storing it first
	instruction				<= instruction_in WHEN state=state_instruction ELSE 
								instruction_register WHEN state=state_store_load ELSE
								(OTHERS=>'0');
	instruction_address_out	<= std_logic_vector(x"0000" & next_pc & "00");
								
	--The Bmux aka operand B select is normally directly affected by immediate enable, accept for branching
	--The input to the registers is either the alu output, the memory output or the program_counter depending on the instruction
	select_bmux				<= ins_imm_en WHEN not instruction_branch ELSE '0';
	select_dmux				<= mux_alu WHEN instruction_alu OR ins_op=OP_MOV ELSE 
								mux_mem WHEN instruction_load ELSE
								mux_pc WHEN ins_op=OP_JAL ELSE
								mux_alu;
	--Write to register when ALU instruction, jump and link instruction, move instruction and second cycle of load instruction
	register_write_enable	<= '1' WHEN (instruction_load and state=state_store_load) OR
										(instruction_alu and state=state_instruction) OR
										(ins_op=OP_JAL and state=state_instruction) OR
										(ins_op=OP_MOV and state=state_instruction)
									ELSE '0';
	--Internal flags. These line up directly with the branch instruction flags
	internal_flags			<= (alu_flags(3) , alu_flags(2) , not alu_flags(0) , alu_flags(0));
	
	--Advance state
	PROCESS(clk,reset)
	BEGIN
		IF reset='0' THEN
			state<=state_reset;
		ELSIF rising_edge(clk) THEN 
			state<=next_state;
		END IF;
	END PROCESS;
	
	--Create next state
	PROCESS(debug,state,instruction_finished)
	BEGIN 
		IF debug='1' and ( instruction_finished OR state=state_debug ) THEN
			next_state<=state_debug;
		ELSE
			CASE state IS 
				WHEN state_reset 		=> 	next_state<=state_instruction;
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
	
	--Update Program Counter
	PROCESS(clk,reset)
	BEGIN
		IF reset='0' THEN 
			program_counter<=(OTHERS=>'0');
		ELSIF rising_edge(clk) THEN 						--TODO: ALU flag documentation
			IF instruction_finished THEN 
				program_counter<=next_pc;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(ins_op,instruction_branch,instruction_finished,internal_flags,ins_imm16,jump_address,program_counter)
	BEGIN
		IF  instruction_branch AND internal_flags(to_integer(unsigned(ins_op(1 DOWNTO 0))))='1' THEN	
			--If we are executing a branch we want to branch only if the condition is true
			next_pc<=unsigned(ins_imm16(15 DOWNTO 2));
		ELSIF ins_op = OP_JAL THEN --IF we jump we want to get the jump address from the bus
			next_pc<=unsigned(jump_address(15 DOWNTO 2));
		ELSE --Under normal circumstances we just fetch a new instruction
			IF instruction_finished THEN 
				next_pc<=program_counter+to_unsigned(1,14);
			ELSE
				next_pc<=program_counter;
			END IF;
		END IF;
	END PROCESS;
	
	--Set instruction register
	PROCESS(clk,reset)
	BEGIN 
		IF reset='0' THEN
			instruction_register<=(OTHERS=>'0');
		ELSIF rising_edge(clk) THEN 
			instruction_register<=instruction;
		END IF;
	END PROCESS;
	
	PROCESS(ins_op,instruction_alu,instruction_branch)
	BEGIN
		IF instruction_alu THEN 
			CASE ins_op IS 
				WHEN OP_ADD	=> alu_opcode<=alu_add;
				WHEN OP_SUB	=> alu_opcode<=alu_sub;
				WHEN OP_MUL	=> alu_opcode<=alu_mul;
				WHEN OP_AND	=> alu_opcode<=alu_and;
				WHEN OP_OR 	=> alu_opcode<=alu_or;
				WHEN OP_XOR	=> alu_opcode<=alu_xor;
				WHEN OP_SLA	=> alu_opcode<=alu_sll;
				WHEN OP_SRA	=> alu_opcode<=alu_sra;
				WHEN OTHERS => alu_opcode<=alu_move;
			END CASE;
		ELSIF instruction_branch THEN
			alu_opcode<=alu_set_flag;
		ELSIF ins_op=OP_MOV THEN 
			alu_opcode<=alu_move;
		ELSE
			alu_opcode<=alu_move;
		END IF;
	END PROCESS;
END bhv;