start:
	lb %r2,[0xff04]
	add %r2,-1
	sw [0xff00],%r2
	jp start
	