library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY control_unit_testbench IS
END control_unit_testbench;
ARCHITECTURE bhv OF control_unit_testbench IS
	SIGNAL clk						: std_logic						:='0';
	SIGNAL reset					: std_logic						:='0';
	SIGNAL debug					: std_logic						:='0';

	SIGNAL alu_flags				: std_logic_vector(3 DOWNTO 0)	:="0000";

	SIGNAL jump_address				: std_logic_vector(31 DOWNTO 0)	:=x"00000000";
	SIGNAL instruction_in			: std_logic_vector(31 DOWNTO 0)	:=x"00000000";

	--ALU control
	SIGNAL alu_opcode              	: alu_op;

	--Register control
	SIGNAL register_write_enable	: std_logic;
	SIGNAL select_register_a 		: std_logic_vector(4 DOWNTO 0);
	SIGNAL select_register_b 		: std_logic_vector(4 DOWNTO 0);

	--Memory control
	SIGNAL byte_operation			: std_logic;
	SIGNAL memory_write_enable		: std_logic;
	SIGNAL read_enable_data			: std_logic;
	SIGNAL read_enable_instruction	: std_logic;
	SIGNAL instruction_address_out	: std_logic_vector(31 DOWNTO 0);

	--Mux control
	SIGNAL select_bmux				: std_logic;
	SIGNAL select_dmux				: mux_t;
	SIGNAL immediate_out			: std_logic_vector(31 DOWNTO 0);
	SIGNAL program_counter_out		: std_logic_vector(31 DOWNTO 0);

	SIGNAL finished				: boolean 	:= FALSE;
BEGIN
	clk <= not clk AFTER 500 us when not finished;
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
	PROCESS
	BEGIN
		WAIT FOR 4 ms;
		reset<='1';
		WAIT FOR 4 ms;
		WAIT UNTIL rising_edge(clk);
		instruction_in	<=x"c4200002";--mov %r1,2
		WAIT FOR 1 ms;
		instruction_in	<=x"14210003";--mul %r1,3
		WAIT FOR 1 ms;
		instruction_in	<=x"e4600100";--jal %r3,256
		jump_address	<=x"00000100";
		WAIT FOR 1 ms;
		
		instruction_in	<= x"43e00200"; --beq %r31,%r0,512 	
		WAIT FOR 1 ms;
		instruction_in	<= x"4be00400"; --bne %r31,%r0,1024	
		WAIT FOR 1 ms;
		instruction_in	<= x"803f0000"; --lw %r1,[%r31]		
		WAIT FOR 2 ms;
		instruction_in	<= x"a4200080"; --sw [128],%r1		
		WAIT FOR 1 ms;
		instruction_in	<= x"8c20ff00"; --lb %r1,[0xff00]	
		WAIT FOR 2 ms;
		instruction_in	<= x"ac000001"; --sb [1],%r0		
		WAIT FOR 1 ms;

		WAIT FOR 3 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;