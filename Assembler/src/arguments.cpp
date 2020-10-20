#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>

/*******************************************************************************
** Argument parser. Takes the program arguments and opens the correct files.
** For arg in arguments 
**   if input then overwrite input file name 
**   if output then overwrite output file name 
** If output file unspecified then output file <= ./a.out
** Open input file 
** Open output file 
** If opening file fails then print error and exit
*******************************************************************************/

std::ifstream input;
std::ofstream output;

void parse_arguments(int argc,char **argv)
{
	std::string input_path="";
	std::string output_path="";
	
	for(int i=1;i<argc;i++)
	{
		std::string arg=argv[i];
		if(arg=="-o")
		{
			if(i+1<argc)
			{
				output_path=argv[++i];
			}
			else
			{
				std::cerr<<"Please specify filename after -o\n";
				std::exit(1);
			}
		}
		else 
		{
			input_path=arg;
		}
	}
	
	if(output_path=="")
		output_path="./a.out";
	
	input.open(input_path);
	output.open(output_path);
	
	if(!input.is_open())
	{
		std::cerr<<"Input file could not be opened\n";
		std::exit(1);
	}
	
	if(!output.is_open())
	{
		std::cerr<<"Output file could not be opened\n";
		std::exit(1);
	}
	
}