library ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.memory_package.ALL;
ENTITY four_byte_enable_memory IS

	GENERIC 
	(
		DATA_WIDTH : natural := 32
	);

	PORT 
	(
		clk		: IN std_logic;
		addr_a	: IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		addr_b	: IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		data_a	: IN std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		--data_b: IN std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a	: IN std_logic := '1';
		-- we_b	: IN std_logic := '1';
		q_a		: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		q_b		: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		byte_enable	: IN std_logic_vector(3 DOWNTO 0)
	);

END four_byte_enable_memory;

ARCHITECTURE kerst OF four_byte_enable_memory IS
	SIGNAL we_a_intern 	: std_logic_vector(3 DOWNTO 0); 
	SIGNAL addr_a_i	: IN natural RANGE 0 to 2**ADDR_WIDTH - 1;
	SIGNAL addr_b_i	: IN natural RANGE 0 to 2**ADDR_WIDTH - 1;
BEGIN
	addr_a_i <= to_integer(unsigned(addr_a));
	addr_b_i <= to_integer(unsigned(addr_b));
	one_byte_enable_zero: ENTITY work.one_byte_enable_memory
		GENERIC MAP ( RAM_INIT=>ROM0 )
		PORT MAP 
		(
			clk	=> clk,
			addr_a	=> addr_a,
			addr_b	=> addr_b,
			data_a	=> data_a(7 DOWNTO 0),
			--data_b => data_b,
			we_a	=> we_a_intern(0),
			-- we_b	=> we_b,
			q_a		=> q_a(7 DOWNTO 0),
			q_b		=> q_b(7 DOWNTO 0)
		);
		
	one_byte_enable_one: ENTITY work.one_byte_enable_memory
		GENERIC MAP ( RAM_INIT=>ROM1 )
		PORT MAP 
		(
			clk	=> clk,
			addr_a	=> addr_a,
			addr_b	=> addr_b,
			data_a	=> data_a(15 DOWNTO 8),
			--data_b => data_b,
			we_a	=> we_a_intern(1),
			-- we_b	=> we_b,
			q_a		=> q_a(15 DOWNTO 8),
			q_b		=> q_b(15 DOWNTO 8)
		);
		
	one_byte_enable_two: ENTITY work.one_byte_enable_memory
		GENERIC MAP ( RAM_INIT=>ROM2 )
		PORT MAP 
		(
			clk	=> clk,
			addr_a	=> addr_a,
			addr_b	=> addr_b,
			data_a	=> data_a(23 DOWNTO 16),
			--data_b => data_b,
			we_a	=> we_a_intern(2),
			-- we_b	=> we_b,
			q_a		=> q_a(23 DOWNTO 16),
			q_b		=> q_b(23 DOWNTO 16)
		);

	one_byte_enable_three: ENTITY work.one_byte_enable_memory
		GENERIC MAP ( RAM_INIT=>ROM3 )
		PORT MAP 
		(
			clk	=> clk,
			addr_a	=> addr_a,
			addr_b	=> addr_b,
			data_a	=> data_a(31 DOWNTO 24),
			--data_b => data_b,
			we_a	=> we_a_intern(3),
			-- we_b	=> we_b,
			q_a		=> q_a(31 DOWNTO 24),
			q_b		=> q_b(31 DOWNTO 24)
		);
	
	PROCESS(we_a, byte_enable)
	BEGIN
		IF we_a ='1' THEN
			we_a_intern <= byte_enable;
		ELSE we_a_intern <= "0000";
		END IF;
		
	END PROCESS;
END;