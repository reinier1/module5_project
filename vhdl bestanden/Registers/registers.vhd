LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY registers IS
	PORT 
	(
		reset				: IN std_logic;
		clk					: IN std_logic;
		register_in			: IN std_logic_vector(31 DOWNTO 0);
		select_register_a 	: IN std_logic_vector(4 DOWNTO 0);
		select_register_b 	: IN std_logic_vector(4 DOWNTO 0);
		write_enable		: IN std_logic;
		register_a_out		: OUT std_logic_vector(31 DOWNTO 0);
		register_b_out		: OUT std_logic_vector(31 DOWNTO 0)
    );
END registers;

ARCHITECTURE bhv of registers IS
	SUBTYPE word_t IS std_logic_vector(31 DOWNTO 0);
	TYPE register_t IS ARRAY(31 DOWNTO 0) OF word_t;
	SIGNAL register_i : register_t;
BEGIN
	register_a_out <= register_i(to_integer(unsigned(select_register_a))) WHEN select_register_a/="00000" ELSE x"00000000";
	register_b_out <= register_i(to_integer(unsigned(select_register_b))) WHEN select_register_b/="00000" ELSE x"00000000";
	
	PROCESS(clk)
	BEGIN
		IF reset='0' THEN
			register_i <= (OTHERS=>x"00000000");
		ELSIF rising_edge(clk) THEN
			IF write_enable = '1' THEN
				register_i(to_integer(unsigned(select_register_a))) <= register_in;
			END IF;		
		END IF;
	END PROCESS;
END bhv;