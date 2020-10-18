IDIR =./src
CXXFLAGS=-I$(IDIR) -Wall  -Werror

ODIR=./obj
DIR =./src

_OBJ = tokens.o lexer.o main.o parser.o ast.o symbol_table.o assembler.o arguments.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

vpath %.hpp $(IDIR)
vpath %.cpp $(DIR)

all: mod5asm

$(ODIR)/tokens.o: tokens.cpp tokens.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/ast.o: ast.cpp ast.hpp tokens.hpp symbol_table.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/symbol_table.o: symbol_table.cpp symbol_table.hpp ast.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/arguments.o: arguments.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/lexer.o: lexer.cpp lexer.hpp tokens.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/parser.o: parser.cpp parser.hpp lexer.hpp tokens.hpp ast.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/assembler.o: assembler.cpp assembler.hpp tokens.hpp ast.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 
	
$(ODIR)/main.o: main.cpp lexer.hpp parser.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $< 

mod5asm: $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -f $(OBJ)