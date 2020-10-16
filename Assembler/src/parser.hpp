#ifndef PARSER_HPP
#define PARSER_HPP
#include <vector>
#include "tokens.hpp"
class Parser
{
	public:
		std::vector<ASTLine> parse(std::vector<Token> tokens);
};
#endif