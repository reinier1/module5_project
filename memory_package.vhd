LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
PACKAGE memory_package IS
	CONSTANT ADDR_WIDTH : integer	:= 14;
	SUBTYPE word_t IS std_logic_vector(7 DOWNTO 0);
	TYPE memory_t IS ARRAY(2**ADDR_WIDTH-1 DOWNTO 0) OF word_t;
	constant ROM0 : memory_t :=
	(
		0 => X"04",
		1 => X"ff",
		2 => X"00",
		3 => X"00",
		others => X"00"
	);
	constant ROM1 : memory_t :=
	(
		0 => X"ff",
		1 => X"ff",
		2 => X"ff",
		3 => X"00",
		others => X"01"
	);
	constant ROM2 : memory_t :=
	(
		0 => X"40",
		1 => X"40",
		2 => X"40",
		3 => X"00",
		others => X"02"
	);
	constant ROM3 : memory_t :=
	(
		0 => X"8c",
		1 => X"04",
		2 => X"a4",
		3 => X"e4",
		others => X"03"
	);
END PACKAGE memory_package;
PACKAGE BODY memory_package IS
END PACKAGE BODY memory_package;

