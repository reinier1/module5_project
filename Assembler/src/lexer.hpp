#ifndef LEXER_HPP
#define LEXER_HPP
#include <vector>
#include <fstream>
#include <map>
#include "tokens.hpp"
class Lexer
{
	public:
		int error;
		Lexer(std::ifstream &stream) : error(0) , stream{&stream} , linenumber(1) {};
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