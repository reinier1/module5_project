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
		
		WAIT UNTIL  rising_edge(clk);
		reset				<= '1';
		write_enable		<= '1';
		register_in			<= x"12345678";
		select_register_a	<= "01100";
		select_register_b	<= "10110";
		WAIT FOR 10 ms;
		
		WAIT UNTIL  rising_edge(clk);
		reset				<= '1';
		write_enable		<= '0';
		register_in			<= x"FF04BA56";
		select_register_a	<= "10101";
		select_register_b	<= "10010";
		WAIT FOR 10 ms;
		
		WAIT UNTIL  rising_edge(clk);
		reset				<= '1';
		write_enable		<= '0';
		register_in			<= x"12345678";
		select_register_a	<= "00000";
		select_register_b	<= "11111";
		WAIT FOR 10 ms;
		
		
		WAIT FOR 10 ms;
		ASSERT FALSE REPORT "done" SEVERITY note;
		finished<=TRUE;
		WAIT;
	END PROCESS;
END bhv;