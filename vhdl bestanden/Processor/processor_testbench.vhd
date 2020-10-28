LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.alu_package.ALL;
USE work.control_package.ALL;
ENTITY processor_testbench IS
END processor_testbench;
ARCHITECTURE bhv OF processor_testbench IS
	SIGNAL clk						: std_logic						:= '1';
	SIGNAL reset					: std_logic						:= '0';
	SIGNAL debug					: std_logic						:= '0';

	SIGNAL data_from_memory			: std_logic_vector(31 DOWNTO 0)	:= x"00000000";
	SIGNAL instruction_in			: std_logic_vector(31 DOWNTO 0)	:= x"00000000";

	SIGNAL read_enable_out			: std_logic;
	SIGNAL write_enable_out 		: std_logic;
	SIGNAL output_address			: std_logic_vector(13 DOWNTO 0);

	SIGNAL byte_enable 				: std_logic_vector( 3 DOWNTO 0);
	SIGNAL data_to_memory 			: std_logic_vector(31 DOWNTO 0);

	SIGNAL read_enable_instruction	: std_logic;
	SIGNAL instruction_address_out	: std_logic_vector(31 DOWNTO 0);

	SIGNAL finished				: boolean 	:= FALSE;
BEGIN
	clk <= not clk AFTER 500 us when not finished;
	cu: ENTITY work.top_level_processor
		PORT MAP
		(
			clk						=> clk,
			reset					=> reset,
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
		WAIT FOR 500 us;
		debug<='1';
		WAIT FOR 5 ms;
		debug<='0';
		WAIT UNTIL rising_edge(clk);
		WAIT FOR 1 ms;
		instruction_in	<= x"ac000001"; --sb [1],%r0		
		WAIT FOR 1 ms;
		
		WAIT FOR 3 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;