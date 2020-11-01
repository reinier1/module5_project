	mov %r31,0x4000 #Setup stack pointer
loop:				#Wait for button to be pressed
	lb %r1,[0xff08] 
	and %r1,2
	bne %r1,%r0,loop
	
	mov %r1,-1		#Signal that calculation has begon(For debugging)
	sb [0xff13],%r1
	
	lb %r8,[0xff04] 	#Load switches as input
	jal %r28,fibonacci	#Calculate Fibonacci of N
	sb [0xff00],%r8		#Store output to leds
	mov %r1,-1			#Signal that calculation is finished
	sb [0xff17],%r1
end:jp loop				#Wait for next button press

fibonacci:				#Recursive fibonacci function. Input is %r8
	mov %r1,1				#Base cases for fibonacci
	blt %r8,%r1,return_zero	#if N<1 return 0
	beq %r8,%r1,return_one 	#if N==1 return 1
	
	sub %r31,4		
	sw [%r31],%r28		#Push link register
	sub %r31,4
	sw [%r31],%r8		#Push Register 8
	
	sub %r8,1
	jal %r28,fibonacci	#Calculate fibonacci(N-1)
	mov %r9,%r8			#Safe value
	
	lw %r8,[%r31]		#Pop Register 8
	add %r31,4
	lw %r28,[%r31]		#Pop link register
	add %r31,4
	
	sub %r31,4
	sw [%r31],%r28		#Push link register
	sub %r31,4
	sw [%r31],%r8		#Push Register 8
	sub %r31,4
	sw [%r31],%r9		#Push Register 9
	
	sub %r8,2
	jal %r28,fibonacci	#Calculate fibonacci(N-2)
	mov %r10,%r8		#Safe value
	
	lw %r9,[%r31]		#Pop Register 9
	add %r31,4
	lw %r8,[%r31]		#Pop Register 8
	add %r31,4
	lw %r28,[%r31]		#Pop link register
	add %r31,4
	
	mov %r8,%r10
	add %r8,%r9			#Return sum
	jr %r28
	
return_zero:	#Return 0
	mov %r8,0
	jr %r28
	
return_one:		#Return 1
	mov %r8,1
	jr %r28