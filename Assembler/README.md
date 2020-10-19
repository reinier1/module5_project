# Assembler
For the project we have created an assembler, to make program writing easier. This specifically targets the processor and produces direct binary code(No linking). 

## Assembly
The assembler takes in a hybrid of intel and AT&T syntax assembly. A line can be empty, contain only a label, contain only an instruction or contain both. An instruction consists of the mnemonic(e.g. "add" for the add instruction) and 1 to three operands seperated by comma's. The instructions are laysed out below
Instruction | Operand 1 | Operand 2 | Operand 3| RTL
------------|-----------|-----------|----------|----------
LW | Register A | [ Register B or Immediate ] | - | Ra <- M[Operand 2]
LB | Register A | [Register B or Immediate ] | - | Ra <- sign extend 8->32(M[Operand 2])
SW |  [ Register B or Immediate ] | Register A | - | M[Operand 1] <- Ra
SB | [ Register B or Immediate ] | Register A | - | M[Operand 1] <- reduce 32->8(Ra)
ADD | Register A | Register B or Immediate | - | Ra <- Ra + Operand 2
SUB | Register A | Register B or Immediate | - | Ra <- Ra - Operand 2
MUL | Register A | Register B or Immediate | - | Ra <- Ra * Operand 2
AND | Register A | Register B or Immediate | - | Ra <- Ra and Operand 2
OR | Register A | Register B or Immediate | - | Ra <- Ra or Operand 2
XOR | Register A | Register B or Immediate | - | Ra <- Ra xor Operand 2
SLA | Register A | Register B or Immediate | - | Ra <- Ra << Operand 2
SRA | Register A | Register B or Immediate | - | Ra <- Ra >> Operand 2
MOV | Register A | Register B or Immediate | - | Ra <- Operand 2
JP | Immediate | - | - | PC <- Operand 1
JR | Register B | - | - | PC <- Operand 1
JAL | Register A | Immediate | - | Ra <- PC+4; PC <- Operand 2
JALR | Register A | Register B | - | Ra <- PC+4; PC <- Operand 2
BEQ | Register A | Register B | Immediate | IF Ra == Rb THEN PC <- IMM16
BNE | Register A | Register B | Immediate | IF Ra != Rb THEN PC <- IMM16
BLTU | Register A | Register B | Immediate | IF Ra unsigned < Rb THEN PC <- IMM16
BLT | Register A | Register B | Immediate | IF Ra signed < Rb THEN PC <- IMM16
ADDRES | Label | Immediate | - | Label=Immediate (For constant IO addresses)
DW | Immediate | - | - | Immediate (Data at location)
DB | Immediate | - | - | Immediate byte (Data at location)

Registers are specified with %r(number), labels are in the same format as c identifiers and immediate can be a label, number, or negative number
## Installing
Tested and setup for linux or WSL. Expects working make and g++ compiler. A seperate ./obj folder needs to be created.
Either execute make all or run.sh. This will compile everything. ./install.sh will store it to a safe location (you might want to that yourself)

## Use
Using the assembler is simple 

` mod5asm input_file [ -o output_file ] ` 

## Assembler internals
The assembler is itself written in C++14. It makes use of RAII for memory management. The actual assembling itself is implemented in two passes, though internally there is also a lexing and parsing pass, which first go through the entire file too.
First the arguments are parsed by arguments.cpp. This safes the input and output files for later use and emits an error if something is wrong with them.
The Lexer (described in lexer.hpp and lexer.cpp) will turn the input into a stream of tokens (instruction mnemonics, labels, registers, numbers, punctuation) and store any necessary information about them for later use. Most importantly their linenumber for error signalling. The end result is a vector of tokens

The Parser (described in parser.hpp and parser.cpp) then uses the tokens to create an abstract syntax tree(AST) from the tokens. It will read the tokens one by one and check if they are in the correct format or in the case of the ALU instructions, checks wether there is a register or an immediate. The AST nodes(described in ast.hpp and ast.cpp) all inherent from a single class, which contains everything they all use. These are then seperated into registers, labels, lines, instructions and expressions. The last 2 of which are then split up into the various instructions according to their format and expressions needed to implement the grammar.
During this stage any format errors should pop up. These might lead to cascading errors if the compiler can't fix it immediately. Cascading errors should be limited to at maximum the end of the line in most circumstances. The end result of the parser is an AST

After the AST has been produced, the SymbolTable (described in symboltable.hpp and symboltable.cpp) is created, which checks all labels and saves their location. Any double defined labels will create errors during this stage. This stage also uses the `define` method of the instructions to check if the instruction defines a constant address. These are also computed and added to the symbol table. Internally a map is used. The end result of the symbol table is the symbol table itself
The Assembler class(described in assembler.hpp and assembler.cpp) will then be initialized and start its job. It will call the assemble class of each lines and these will perform callbacks to the writing methods of the assembler. The assembler also manages alignment. The end result is a vector of uint8_t unsigned bytes. 

At the moment no actual is actually written as the output format is as of yet undecided




