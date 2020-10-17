#include <vector>
#include <memory>
#include <iostream>
#include "parser.hpp"
#include "tokens.hpp"
#include "ast.hpp"

bool Parser::expect(std::vector<Token>::iterator &it,TOK id)
{
	if(it->id!=id)
	{
		error++;
		std::cerr<<"Error: Expected "<<id<<" not"<<it->id<<"on line "<<it->linenumber<<"\n";
		return false;
	}
	++it;
	return true;
}

std::vector<ASTLine> Parser::parse(std::vector<Token> tokens)
{
	std::vector<ASTLine> assembly;
	std::vector<Token>::iterator it;
	for(it=tokens.begin();(it!=tokens.end())&&(it->id!=TOK::END);)
	{
		//std::cerr<<"parse\n";
		if(it->id==TOK::EOL)
		{
			++it;
			continue;
		}
		assembly.push_back(parse_line(it));
	}
	return assembly;
}
		
ASTLine Parser::parse_line(std::vector<Token>::iterator &it)
{
	//std::cerr<<"parse line\n";
	int linenumber=it->linenumber;
	bool labeled=false;
	ASTLabel label(0,"");
	if(it->id==TOK::IDENTIFIER)
	{
		label=ASTLabel(it->linenumber,it->str);
		++it;
		expect(it,TOK::COLON);
		labeled=true;
	}
	std::unique_ptr<ASTInstruction> instruction=nullptr;
	if(it->id==TOK::EOL||it->id==TOK::END)
		instruction=std::make_unique<ASTInsNone>(linenumber);
	else
		instruction=parse_instruction(it);
	//std::cerr<<"parse line 2 "<<labeled<<"\n";
	if(labeled)
		return ASTLine(linenumber,std::move(instruction),label);
	else 
		return ASTLine(linenumber,std::move(instruction));
}

std::unique_ptr<ASTInstruction> Parser::parse_instruction(std::vector<Token>::iterator &it)
{
	//std::cerr<<"parse instruction\n";
	switch(it->id)
	{
		case TOK::ADD:
		case TOK::SUB:
		case TOK::MUL:
		case TOK::AND:
		case TOK::OR:
		case TOK::XOR:
		case TOK::SLA:
		case TOK::SRA:
		case TOK::MOVE:
		{
			TOK type=it->id;
			++it;
			ASTReg Rd=parse_reg(it);
			expect(it,TOK::COMMA);
			if(it->id==TOK::REG)
			{
				ASTReg Rb=parse_reg(it);
				return std::make_unique<ASTInsRegReg>(it->linenumber,type,Rd,Rb);
			}
			else 
			{
				auto imm=parse_expression(it);
				return std::make_unique<ASTInsRegImm>(it->linenumber,type,Rd,std::move(imm));
			}
		}		
		case TOK::JP:
		{
			TOK type=TOK::JP;
			++it;
			auto imm=parse_expression(it);
			
			return std::make_unique<ASTInsRegImm>(it->linenumber,type,ASTReg(it->linenumber,0),std::move(imm));
		}
		case TOK::JR:
		{
			TOK type=TOK::JP;
			++it;
			ASTReg Rb=parse_reg(it);
			return std::make_unique<ASTInsRegReg>(it->linenumber,type,ASTReg(it->linenumber,0),Rb);
		}
		case TOK::JAL:
		{
			TOK type=TOK::JP;
			++it;
			ASTReg Rd=parse_reg(it);
			expect(it,TOK::COMMA);
			auto imm=parse_expression(it);
			return std::make_unique<ASTInsRegImm>(it->linenumber,type,Rd,std::move(imm));
		}
		case TOK::JALR:
		{
			TOK type=TOK::JP;
			++it;
			ASTReg Rd=parse_reg(it);
			expect(it,TOK::COMMA);
			ASTReg Rb=parse_reg(it);
			return std::make_unique<ASTInsRegReg>(it->linenumber,type,Rd,Rb);
		}
		
		case TOK::BEQ:
		case TOK::BNE:
		case TOK::BLT:
		case TOK::BLTU:
		{
			TOK type=it->id;
			++it;
			ASTReg Rd=parse_reg(it);
			expect(it,TOK::COMMA);
			ASTReg Rb=parse_reg(it);
			expect(it,TOK::COMMA);
			auto imm=parse_expression(it);
			return std::make_unique<ASTInsRegRegImm>(it->linenumber,type,Rd,Rb,std::move(imm));
		}
		
		case TOK::LW:
		case TOK::LB:
		{
			TOK type=it->id;
			++it;
			ASTReg Rd=parse_reg(it);
			expect(it,TOK::COMMA);
			expect(it,TOK::LBRACKET);
			if(it->id==TOK::REG)
			{
				ASTReg Rb=parse_reg(it);
				expect(it,TOK::RBRACKET);
				return std::make_unique<ASTInsRegReg>(it->linenumber,type,Rd,Rb);
			}
			else 
			{
				auto imm=parse_expression(it);
				expect(it,TOK::RBRACKET);
				return std::make_unique<ASTInsRegImm>(it->linenumber,type,Rd,std::move(imm));
			}
		}
		case TOK::SW:
		case TOK::SB:
		{
			TOK type=it->id;
			++it;
			expect(it,TOK::LBRACKET);
			if(it->id==TOK::REG)
			{
				ASTReg Rb=parse_reg(it);
				expect(it,TOK::RBRACKET);
				expect(it,TOK::COMMA);
				ASTReg Rd=parse_reg(it);
				return std::make_unique<ASTInsRegReg>(it->linenumber,type,Rd,Rb);
			}
			else 
			{
				auto imm=parse_expression(it);
				expect(it,TOK::RBRACKET);
				expect(it,TOK::COMMA);
				ASTReg Rd=parse_reg(it);
				return std::make_unique<ASTInsRegImm>(it->linenumber,type,Rd,std::move(imm));
			}
		}
		default:
		{
			int linenumber=it->linenumber;
			error++;
			std::cerr<<"Error: Expected instruction not "<<it->id<<"on line "<<linenumber<<"\n";
			++it;
			return std::make_unique<ASTInsNone>(it->linenumber);
		}
	}
}

ASTReg Parser::parse_reg(std::vector<Token>::iterator &it)
{
	if(it->id==TOK::REG)
	{
		ASTReg reg(it->linenumber,it->value);
		++it;
		return reg;
	}
	else 
	{
		error++;
		std::cerr<<"Error: Expected register not "<<it->id<<"on line "<<it->linenumber<<"\n";
		return ASTReg(it->linenumber,-1);
	}
}

std::unique_ptr<ASTExpression> Parser::parse_expression(std::vector<Token>::iterator &it)
{
	//std::cerr<<"Parse expression\n";
	switch(it->id)
	{
		case TOK::NUMBER:
		{
			auto ret=std::make_unique<ASTNumber>(it->linenumber,it->value);
			++it;
			return ret;
		}
		case TOK::IDENTIFIER:
		{
			auto ret=std::make_unique<ASTIdentifier>(it->linenumber,it->str);
			++it;
			return ret;
		}
		default:
		{
			error++;
			std::cerr<<"Error: Expected expression not "<<it->id<<"on line "<<it->linenumber<<"\n";
			return std::make_unique<ASTBadExpr>(it->linenumber);
		}
	}
}
		