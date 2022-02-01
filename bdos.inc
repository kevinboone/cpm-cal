;------------------------------------------------------------------------
;  dbgutil.inc
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in dbgutl

	.Z80

	; BDOS call entry point
	BDOS	equ	5

	; Default FCB address 
	DEFFCB	equ	05Ch

	; Start of DMA buffer
	DMABUF  equ	80h
	
	; Console output character
	CONOUT equ 2 


