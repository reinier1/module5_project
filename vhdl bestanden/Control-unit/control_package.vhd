PACKAGE control_package IS
	
	CONSTANT OP_LW   : std_logic_vector(4 DOWNTO 0) := "10000";
	CONSTANT OP_LB   : std_logic_vector(4 DOWNTO 0) := "10001";
	CONSTANT OP_SW   : std_logic_vector(4 DOWNTO 0) := "10100";
	CONSTANT OP_SB   : std_logic_vector(4 DOWNTO 0) := "10101";
					 
	CONSTANT OP_ADD  : std_logic_vector(4 DOWNTO 0) := "00000";
	CONSTANT OP_SUB  : std_logic_vector(4 DOWNTO 0) := "00001";
	CONSTANT OP_MUL  : std_logic_vector(4 DOWNTO 0) := "00010";
	CONSTANT OP_AND  : std_logic_vector(4 DOWNTO 0) := "00011";
	CONSTANT OP_OR   : std_logic_vector(4 DOWNTO 0) := "00100";
	CONSTANT OP_XOR  : std_logic_vector(4 DOWNTO 0) := "00101";
	CONSTANT OP_SLA  : std_logic_vector(4 DOWNTO 0) := "00110";
	CONSTANT OP_SRA  : std_logic_vector(4 DOWNTO 0) := "00111";
					 
	CONSTANT OP_MOV  : std_logic_vector(4 DOWNTO 0) := "11000";
	CONSTANT OP_JAL  : std_logic_vector(4 DOWNTO 0) := "11100";
					 
	CONSTANT OP_BEQ  : std_logic_vector(4 DOWNTO 0) := "01000";
	CONSTANT OP_BNE  : std_logic_vector(4 DOWNTO 0) := "01001";
	CONSTANT OP_BLTU : std_logic_vector(4 DOWNTO 0) := "01010";
	CONSTANT OP_BLT  : std_logic_vector(4 DOWNTO 0) := "01011";

	
	TYPE mux_t IS 
	(
		mux_alu,
		mux_pc,
		mux_mem
	)
	
END PACKAGE control_package;

PACKAGE BODY control_package IS 
END PACKAGE BODY control_package;