start:
	lb %r2,[0xff04]
	add %r2,
	sw [0xff00],%r2
	jp start

	