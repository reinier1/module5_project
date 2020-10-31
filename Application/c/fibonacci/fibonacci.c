#include <mod5/io.h>
int fibonnaci(int n)
{
	if(n<1)
		return 0;
	if(n==1)
		return 1;
	return fibonnaci(n-1)+fibonnaci(n-2);
}
int main()
{
	while(1)
	{
		while(IO_KEY&2);
		IO_LED=fibonnaci(IO_SWITCH);
	}
	return 4;
}

