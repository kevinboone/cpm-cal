;------------------------------------------------------------------------
;  bdos.inc
;
;  Various constants related to BDOS
; 
;  Copyright (c)2021-3 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

	; BDOS call entry point
	BDOS	equ	5

	; Default FCB address 
	DEFFCB	equ	05Ch

	; Start of DMA buffer
	DMABUF  equ	80h
	
	; Console output character
	CONOUT equ 2 


