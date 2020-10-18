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
	if((c=='\n')||(c==EOF))
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
			case '-': return Token(TOK::MINUS,linenumber);
			case '%': 
			{
				if(peekc()!='r')
				{
					error++;
					std::cerr<<"Error: Bad register on line "<<linenumber<<"\n";
				}
				else 
				{
					popc();
					uint32_t num=lex_number().value;
					if(num>31)
					{
						error++;
						std::cerr<<"Error: Bad register on line "<<linenumber<<"\n";
					}
					else 
					{
						return Token(TOK::REG,linenumber,num);
					}
				}

			}
			default:
				error++;
				std::cerr<<"Error: Unkown punctuation '"; std::cerr.put(c); std::cerr<<"' on line "<<linenumber<<"\n";
		}
	}
	else
	{
		error++;
		std::cerr<<"Error: Unkown symbol '"<<popc()<<"' on line "<<linenumber<<"\n";
	}
	return Token(TOK::EOL,linenumber);
}

Token Lexer::lex_number()
{
	uint32_t n=0;
	if(peekc()=='0')
	{
		popc();
		if((peekc()=='x')||(peekc()=='X'))
		{
			popc();
			for(int c=peekc();std::isxdigit(c);c=peekc())
			{
				popc();
				if(isdigit(c))
					n=16*n+c-'0';
				else if(islower(c))
					n=16*n+10+c-'a';
				else if(isupper(c))
					n=16*n+10+c-'A';
			}
		}
		else 
		{
			for(int c=peekc();std::isdigit(c);c=peekc())
			{
				popc();
				n=10*n+c-'0';
			}
		}
	}
	else 
	{
		for(int c=peekc();std::isdigit(c);c=peekc())
		{
			popc();
			n=10*n+c-'0';
		}
	}
	return Token(TOK::NUMBER,linenumber,n);
}

Token Lexer::lex_id()
{
	std::string str;
	for(int c=peekc();std::isalnum(c)||(c=='_');c=peekc())
	{
		popc();
		str.push_back(c);
	}
	if(string2TOK.count(str))
	{
		return Token(string2TOK[str],linenumber);
	}
	else
		return Token(TOK::IDENTIFIER,linenumber,str);
}

std::map<std::string,TOK> Lexer::string2TOK
{
	{"ADD",TOK::ADD},
	{"add",TOK::ADD},
	{"SUB",TOK::SUB},
	{"sub",TOK::SUB},
	{"MUL",TOK::MUL},
	{"mul",TOK::MUL},
	{"AND",TOK::AND},
	{"and",TOK::AND},
	{"OR",TOK::OR},
	{"or",TOK::OR},
	{"XOR",TOK::XOR},
	{"xor",TOK::XOR},
	{"SLA",TOK::SLA},
	{"sla",TOK::SLA},
	{"SRA",TOK::SRA},
	{"sra",TOK::SRA},
	{"MOV",TOK::MOVE},
	{"mov",TOK::MOVE},
	{"JP",TOK::JP},
	{"jp",TOK::JP},
	{"JALR",TOK::JALR},
	{"jalr",TOK::JALR},
	{"JAL",TOK::JAL},
	{"jal",TOK::JAL},
	{"JR",TOK::JR},
	{"jr",TOK::JR},
	{"BEQ",TOK::BEQ},
	{"beq",TOK::BEQ},
	{"BNE",TOK::BNE},
	{"bne",TOK::BNE},
	{"BLT",TOK::BLT},
	{"blt",TOK::BLT},
	{"BLTU",TOK::BLTU},
	{"bltu",TOK::BLTU},
	{"LW",TOK::LW},
	{"lw",TOK::LW},
	{"LB",TOK::LB},
	{"lb",TOK::LB},
	{"SW",TOK::SW},
	{"sw",TOK::SW},
	{"SB",TOK::SB},
	{"sb",TOK::SB},
	{"DW",TOK::DW},
	{"dw",TOK::DW},
	{"DB",TOK::DB},
	{"db",TOK::DB},
	{"ADDRESS",TOK::ADDRESS},
	{"address",TOK::ADDRESS},
};