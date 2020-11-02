library ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE memory_package IS

	CONSTANT ADDR_WIDTH : integer	:= 14;
	-- Build a 2-D ARRAY TYPE for the RAM
	SUBTYPE word_t IS std_logic_vector(7 DOWNTO 0);
	TYPE memory_t IS ARRAY(2**ADDR_WIDTH-1 DOWNTO 0) OF word_t;
	
	constant ROM0 : memory_t := (
		0   => X"00",
		1   => X"74",
		2   => X"ef",
		5 	=> X"3e",
		10 	=> X"0f",
		15 	=> X"f0",
		others => X"00"
	);
	constant ROM1 : memory_t := (
		0   => X"01",
		1   => X"74",
		2   => X"ef",
		5 	=> X"3f",
		10 	=> X"0f",
		15 	=> X"f0",
		others => X"01"
	);
	constant ROM2 : memory_t := (
		0   => X"02",
		1   => X"74",
		2   => X"ef",
		5 	=> X"3a",
		10 	=> X"0f",
		15 	=> X"f0",
		others => X"02"
	);
	constant ROM3 : memory_t := (
		0   => X"03",
		1   => X"74",
		2   => X"ef",
		5 	=> X"3d",
		10 	=> X"0f",
		15 	=> X"f0",
		others => X"03"
	);
	
END PACKAGE memory_package;

PACKAGE BODY memory_package IS 
END PACKAGE BODY memory_package;