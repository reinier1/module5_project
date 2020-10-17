#ifndef PARSER_HPP
#define PARSER_HPP
#include <vector>
#include <memory>
#include "tokens.hpp"
#include "ast.hpp"
class Parser
{
	public:
		int error;
		Parser() : error(0) {};
		std::vector<ASTLine> parse(std::vector<Token> tokens);
	private:
		ASTLine parse_line(std::vector<Token>::iterator &it);
		std::unique_ptr<ASTInstruction> parse_instruction(std::vector<Token>::iterator &it);
		ASTReg parse_reg(std::vector<Token>::iterator &it);
		std::unique_ptr<ASTExpression> parse_expression(std::vector<Token>::iterator &it);
		bool expect(std::vector<Token>::iterator &it, TOK id);
};
#endif