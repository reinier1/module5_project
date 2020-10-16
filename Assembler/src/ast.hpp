#ifndef AST_HPP
#define AST_HPP
#include <string>
#include <memory>
#include "tokens.hpp"
class AST;
class ASTLine;
class ASTLabel;
class ASTInstruction;

class AST
{
	
};

class ASTLine : public AST 
{
	public:
		ASTLine(std::unique_ptr<ASTInstruction> instruction) : labeled(false) , instruction{std::move(instruction)} {};
		ASTLine(std::unique_ptr<ASTInstruction> instruction, ASTLabel label) : 
				labeled(true) , label{label} , instruction(std::move(instruction)) {};
		
		bool labeled;
		ASTLabel label;
		std::unique_ptr<ASTInstruction> instruction;
};

class ASTLabel : public AST 
{
	public:
		ASTLabel(std::string str) : str{str} {};
		std::string str;
};

class ASTInstruction : public AST
{
	public:
		ASTInstruction(TOK type)
		TOK type;
};

class ASTInsNone : public ASTInstruction
{
	public:
		ASTInsNone() : ASTInstruction(TOK::NONE) {};
};

class ASTReg : public AST
{
	public:
		ASTReg(int reg) : reg{reg} {};
		int reg;
};

class ASTExpression : public AST
{
	public:
		
};

class ASTNumber : public ASTExpression
{
	public:
		ASTNumber(uint16_t value) : value{value} {};
		uint16_t value;
};

class ASTIdentifier : public ASTExpression
{
	public:
		ASTIdentifier(std::string id) : id{id} {};
		std::string id;
};

class ASTInsRegReg : public ASTInstruction
{
	public:
		ASTInsALU(TOK tok, ASTReg dest, ASTReg source) : ASTInstruction(tok) , dest{dest} , source{source} {};
		ASTReg dest;
		ASTReg source;
};

class ASTInsRegImm : public ASTInstruction
{
	public:
		ASTInsALU(TOK tok, ASTReg dest, std::unique_ptr<ASTExpression> source;) : 
					ASTInstruction(tok) , dest{dest} , source{std::move(source)} {};
		ASTReg dest;
		std::unique_ptr<ASTExpression> source;
};

class ASTRegRegImm : public ASTInstruction
{
	public:
		ASTInsALU(TOK tok, ASTReg left, ASTReg right, std::unique_ptr<ASTExpression> target) :
					ASTInstruction(tok), left{left} , right{right} , target{std::move(target)} {};
		ASTReg left;
		ASTReg right;
		std::unique_ptr<ASTExpression> target;
};
#endif