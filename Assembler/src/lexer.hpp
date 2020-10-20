#ifndef LEXER_HPP
#define LEXER_HPP
#include <vector>
#include <fstream>
#include <map>
#include "tokens.hpp"
/*******************************************************************************
** Lexer class definition
** Contains
**	- Amount of errors produced during lexing
** 	- Current line number of lexer
** 	- Public lex method, which returns a list of tokens 
**	- Private methods to acces a new character
**	- Private methods to lex specific types of tokens
**	- Private map for string to instruction token conversion
*******************************************************************************/
class Lexer
{
	public:
		Lexer(std::ifstream &stream) : error(0) , stream{&stream} , linenumber(1) {};
		
		int error;
		
		std::vector<Token> lex();
		
	private:
		static std::map<std::string,TOK> string2TOK;
		std::ifstream *stream;
		int linenumber;
		
		int popc();
		inline int peekc() {return stream->peek();};
		
		Token lex_token();
		Token lex_number();
		Token lex_id();
};
#endif