#include <vector>
#include <cctype>
#include "lexer.hpp"
int Lexer::popc()
{
	int c=stream->get();
	if(c=='\n')
		linenumber++;
	return c;
}

std::vector<Token> Lexer::lex()
{
	std::vector<Token> vec;
	while(peekc()!=EOF)
	{
		vec.push_back(lex_token());
	}
	vec.push_back(Token(TOK::END,linenumber));
	return vec;
}

Token Lexer::lex_token()
{
	int c;
	for(c=peekc();(std::isspace(c))&&(c!='\n');c=peekc())
		popc();
	if(c=='\n')
	{
		popc();
		return Token(TOK::EOL,linenumber);
	}
	else if(std::isdigit(c))
		return lex_number();
	else if(std::isalpha(c))
		return lex_id();
	else if(std::ispunct(c))
	{
		switch(popc())
		{
			case ',': return Token(TOK::COMMA,linenumber);
			case ':': return Token(TOK::COLON,linenumber);
			case '[': return Token(TOK::LBRACKET,linenumber);
			case ']': return Token(TOK::RBRACKET,linenumber);
			case '%': return Token(TOK::PERCENT,linenumber);
			default:
				std::cerr<<"Error: Unkown punctuation '"; std::cerr.put(c); std::cerr<<"' on line "<<linenumber<<"\n";
		}
	}
	else
	{
		std::cerr<<"Error: Unkown symbol '"; std::cerr.put(popc()); std::cerr<<"' on line "<<linenumber<<"\n";
	}
	return Token(TOK::EOL,linenumber);
}

Token Lexer::lex_number()
{
	int n=0;
	for(int c=peekc();isdigit(c);c=peekc())
	{
		popc();
		n=10*n+c-'0';
	}
	return Token(TOK::NUMBER,linenumber,n);
}

Token Lexer::lex_id()
{
	std::string str;
	for(int c=peekc();isalnum(c)||(c=='_');c=peekc())
	{
		popc();
		str.push_back(c);
	}
	if(str=="ADD"||str=="add")
		return Token(TOK::ADD,linenumber);
	else if(str=="SUB"||str=="sub")
		return Token(TOK::SUB,linenumber);
	else if(str=="MUL"||str=="mul")
		return Token(TOK::MUL,linenumber);
	else if(str=="AND"||str=="and")
		return Token(TOK::AND,linenumber);
	else if(str=="OR"||str=="or")
		return Token(TOK::OR,linenumber);
	else if(str=="XOR"||str=="xor")
		return Token(TOK::XOR,linenumber);
	else if(str=="SLA"||str=="sla")
		return Token(TOK::SLA,linenumber);
	else if(str=="SRA"||str=="sra")
		return Token(TOK::SRA,linenumber);
	else if(str=="MOV"||str=="mov")
		return Token(TOK::MOVE,linenumber);
	else if(str=="JP"||str=="jp")
		return Token(TOK::JP,linenumber);
	else if(str=="JALR"||str=="jalr")
		return Token(TOK::JALR,linenumber);
	else if(str=="JAL"||str=="jal")
		return Token(TOK::JAL,linenumber);
	else if(str=="JR"||str=="jr")
		return Token(TOK::JR,linenumber);
	else if(str=="BEQ"||str=="beq")
		return Token(TOK::BEQ,linenumber);
	else if(str=="BNE"||str=="bne")
		return Token(TOK::BNE,linenumber);
	else if(str=="BLT"||str=="blt")
		return Token(TOK::BLT,linenumber);
	else if(str=="BLTU"||str=="bltu")
		return Token(TOK::BLTU,linenumber);
	else if(str=="LW"||str=="lw")
		return Token(TOK::LW,linenumber);
	else if(str=="LB"||str=="lb")
		return Token(TOK::LB,linenumber);
	else if(str=="SW"||str=="sw")
		return Token(TOK::SW,linenumber);
	else if(str=="SB"||str=="sb")
		return Token(TOK::SB,linenumber);
	else
		return Token(TOK::IDENTIFIER,linenumber,str);
}