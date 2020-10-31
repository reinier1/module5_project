#include <mod5/io.h>
void wait(int n);
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
		wait(500);
		IO_LED=0;
		wait(500);
		IO_LED=1;
	}
	return 4;
}

