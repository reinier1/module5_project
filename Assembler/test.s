		address IO,0xFFF0
start:	lw %r1, [IO]
		sw [data], %r2
here:	jp here 
		
data:	dw 0xfffff
		db 0xfff 
		dw 0xf0f00f0f