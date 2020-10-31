start:
	lb %r2,[0xff04]
	sw [0xff00],%r2
	jp start

	