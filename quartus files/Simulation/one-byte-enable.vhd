-- Quartus Prime VHDL Template
-- True Dual-Port RAM with sINgle clock
--
-- Read-durINg-write on PORT A or B returns newly written data
-- 
-- Read-durINg-write between A and B returns either new or old data depENDINg
-- on the order IN which the simulator executes the PROCESS statements.
-- Quartus Prime will consider thIS read-durINg-write scenario as a 
-- don't care condition to optimize the performance OF the RAM.  If you
-- need a read-durINg-write between PORTs to return the old data, you
-- must INstantiate the altsyncram Megafunction directly.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.memory_package.ALL;
ENTITY one_byte_enable_memory IS

	GENERIC 
	(
		DATA_WIDTH 	: natural 	:= 8;
		RAM_INIT   	: memory_t	:= (OTHERS=>x"00")
	);

	PORT 
	(
		clk		: IN  std_logic;
		addr_a	: IN  natural RANGE 0 to 2**ADDR_WIDTH - 1;
		addr_b	: IN  natural RANGE 0 to 2**ADDR_WIDTH - 1;
		data_a	: IN  std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
		we_a	: IN  std_logic;
		
		q_a		: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0);
		q_b		: OUT std_logic_vector((DATA_WIDTH -1) DOWNTO 0)
	);

END one_byte_enable_memory;

ARCHITECTURE rtl OF one_byte_enable_memory IS
	-- Shared variable, because it is accesible from two different ports simultaniously
	SHARED VARIABLE ram : memory_t := RAM_INIT;
BEGIN
 
	-- Port A for Data
	PROCESS(clk)
	BEGIN
		IF(rising_edge(clk)) THEN 
			IF(we_a = '1') THEN
				ram(addr_a) := data_a;
			END IF;
			q_a <= ram(addr_a);
		END IF;
	END PROCESS;

	-- Port B for instructions
	PROCESS(clk)
	BEGIN
		IF(rising_edge(clk)) THEN 
			q_b <= ram(addr_b);
		END IF;
	END PROCESS;

END rtl;
