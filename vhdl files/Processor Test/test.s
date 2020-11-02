	mov %r8,3
	mov %r9,-1
loop:
	mul %r9,%r8
	sub %r8,1
	blt %r0,%r8,loop
	mov %r8,%r9
	mov %r1,b
	jalr %r28,%r1
	mov %r8,%r28
a:	jp a

b: 	jr %r28