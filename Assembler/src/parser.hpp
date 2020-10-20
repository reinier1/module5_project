#ifndef PARSER_HPP
#define PARSER_HPP
#include <vector>
#include <memory>
#include "tokens.hpp"
#include "ast.hpp"
/*******************************************************************************
** Parser class definition
** Contains
**	- Number of parsing errors
** 	- Public parse method, which returns list of Instruction lines
**	- Private helper method, for when a specific type of token is expected
**	- Private methods to parse specific grammar elements
*******************************************************************************/
class Parser
{
	public:
		Parser() : error(0) {};
		
		int error;
		
		std::vector<ASTLine> parse(std::vector<Token> tokens);
		
	private:
		bool expect(std::vector<Token>::iterator &it, TOK id);
	
		ASTLine parse_line(std::vector<Token>::iterator &it);
		std::unique_ptr<ASTInstruction> parse_instruction(std::vector<Token>::iterator &it);
		ASTReg parse_reg(std::vector<Token>::iterator &it);
		std::unique_ptr<ASTExpression> parse_expression(std::vector<Token>::iterator &it);
};
#endif