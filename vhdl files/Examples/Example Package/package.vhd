PACKAGE alu_package IS

	TYPE alu_op IS 
	(
		alu_add,
		alu_sub,
		alu_mul,
		alu_or,
		alu_and,
		alu_xor,
		alu_sra,
		alu_sla,
		
		alu_move,
		
		alu_eq,
		alu_ne,
		alu_lt,
		alu_ltu,
		
		alu_dont_care
	);
	
END PACKAGE alu_package;

PACKAGE BODY alu_package IS 
END PACKAGE BODY alu_package;