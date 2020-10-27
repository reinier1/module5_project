LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY registers_testbench IS
END registers_testbench;
ARCHITECTURE bhv OF registers_testbench IS 
	SIGNAL clk 					: std_logic := '0';
	SIGNAL reset 				: std_logic := '0';
	SIGNAL register_in			: std_logic_vector(31 DOWNTO 0);
	SIGNAL select_register_a 	: std_logic_vector(4 DOWNTO 0);
	SIGNAL select_register_b 	: std_logic_vector(4 DOWNTO 0);
	SIGNAL write_enable			: std_logic;
	SIGNAL register_a_out		: std_logic_vector(31 DOWNTO 0);
	SIGNAL register_b_out		: std_logic_vector(31 DOWNTO 0);
	SIGNAL finished				: boolean 	:= FALSE;
	
	PROCEDURE store 
	(
		  reg_sel_a 				:   std_logic_vector(4 DOWNTO 0);
		  reg_val					:   std_logic_vector(31 DOWNTO 0);
		  SIGNAL write_enable		: OUT std_logic;
		  SIGNAL select_register_a	: OUT std_logic_vector(4 DOWNTO 0);
		  SIGNAL register_a_out		: IN  std_logic_vector(31 DOWNTO 0);
		  SIGNAL register_in		: OUT std_logic_vector(31 DOWNTO 0)
	)		  
	IS
	BEGIN
		write_enable<='1';
		select_register_a<=reg_sel_a;
		register_in<=reg_val;
		WAIT FOR 3 ms;
		WAIT UNTIL rising_edge(clk);
		write_enable<= '0';
		ASSERT register_a_out=reg_val REPORT "Bad store " & integer'image(to_integer(unsigned(reg_sel_a))) & " " & integer'image(to_integer(unsigned(reg_val))) SEVERITY error;
	END store; 
	
BEGIN
	clk <= not clk AFTER 1 ms when not finished;
	tc: ENTITY work.registers
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
		
	
	
	PROCESS
	BEGIN
		WAIT FOR 10 ms;
		reset<='1';
		WAIT FOR 10 ms;
		
		WAIT UNTIL  rising_edge(clk);
		reset				<= '1';
		write_enable		<= '0';
		register_in			<= x"12345678";
		select_register_a	<= "00001";
		select_register_b	<= "10110";
		WAIT FOR 10 ms;
		
		FOR I IN 0 TO 31 LOOP
			store(std_logic_vector(to_unsigned(I,5)),std_logic_vector(to_unsigned(I+5,32)),write_enable,select_register_a,register_a_out,register_in);
		END LOOP;
		WAIT FOR 2 ms;
		WAIT UNTIL rising_edge(clk);
		store("00100",x"deadbeef",write_enable,select_register_a,register_a_out,register_in);
		
		FOR I IN 0 TO 31 LOOP
			select_register_a<=std_logic_vector(to_unsigned(I,5));
			WAIT FOR 1 ms;
			ASSERT std_logic_vector(to_unsigned(I+5,32))=register_a_out REPORT "Bad register a " & integer'image(I) SEVERITY error;
		END LOOP;
		
		FOR I IN 0 TO 31 LOOP
			select_register_b<=std_logic_vector(to_unsigned(I,5));
			WAIT FOR 1 ms;
			ASSERT std_logic_vector(to_unsigned(I+5,32))=register_b_out REPORT "Bad register b " & integer'image(I) SEVERITY error;
		END LOOP;
		
		WAIT FOR 10 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;