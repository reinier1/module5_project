#comment
		address IO,0xFFF0
test: #comment
start:	lw %r1, [IO]
		sw [data], %r2
		bne %r0,%r0,data
here:	jp here #comment
		
data:	dw 0xfffff
		db 0xfff 
		dw 0xf0f00f0f
#comment