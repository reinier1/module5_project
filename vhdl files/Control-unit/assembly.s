	mov %r1,1
	mul %r1,%r1
	jal %r3,256
	beq %r31,%r0,512 
	bne %r31,%r0,1024
	lw %r1,[%r31]
	sw [128],%r1
	lb %r1,[0xff00]
	
	sb [1],%r0