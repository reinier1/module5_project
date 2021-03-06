	mov %r31,0x4000
loop:
	lb %r1,[0xff08]
	and %r1,2
	bne %r1,%r0,loop
	
	mov %r1,-1
	sb [0xff13],%r1
	
	lb %r8,[0xff04]
	jal %r28,factorial
	sb [0xff00],%r8
	mov %r1,-1
	sb [0xff17],%r1
end:jp loop

factorial:
	mov %r1,2
	blt %r8,%r1,return_one
	
	sub %r31,4
	sw [%r31],%r28
	sub %r31,4
	sw [%r31],%r8
	
	sub %r8,1
	jal %r28,factorial
	mov %r9,%r8
	
	lw %r8,[%r31]
	add %r31,4
	lw %r28,[%r31]
	add %r31,4
	
	mul %r8,%r9
	jr %r28
	
return_zero:
	mov %r8,0
	jr %r28
	
return_one:
	mov %r8,1
	jr %r28