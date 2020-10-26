#include <iostream>
#include <vector>
#include "lexer.hpp"
#include "parser.hpp"
#include "symbol_table.hpp"
#include "assembler.hpp"
#include "codegen.hpp"

/*************************************************************
** Program entry point main. Calls all other routines.
** 	- Parse Arguments
**	- Lex input file
**	- Print all tokens 					- Could use flag
**	- Parse Tokens into AST
**	- Create symbol table 
**	- Assemble AST into byte array
**	- Print byte array per word			- Could use flag
** 	- TODO output to readable format
*************************************************************/

extern std::ifstream input;
extern std::ofstream output;
void parse_arguments(int argc,char **argv);

int main(int argc,char **argv)
{
	parse_arguments(argc,argv);
	
	Lexer lexer(input);
	auto tokens=lexer.lex();
	
	for(auto it : tokens)
		std::cerr<<" "<<it;
	if(lexer.error)
		return lexer.error;
	
	Parser parser;
	auto assembly=parser.parse(std::move(tokens));
	if(parser.error)
		return parser.error;
	
	SymbolTable symbol_table(assembly);
	if(symbol_table.error)
		return symbol_table.error;
	
	Assembler assembler;
	auto data=assembler.assemble(assembly,symbol_table);
	
	std::cerr<<assembler;
	
	VHDLGenerator VHDLGen(output);
	VHDLGen.generate(data);
	
	return 0;
}