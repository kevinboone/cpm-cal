;------------------------------------------------------------------------
;  clargs.asm 
;  See clargs.inc for description
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	include mem.inc
	global clinit, clnext 

;------------------------------------------------------------------------
clinit
;------------------------------------------------------------------------
clinit:
	LD	HL, 080h
	LD	DE, clbuf
	LD	BC, 128
	CALL	memcpy
	LD	HL, clbuf	; HL contains start of cmdline area
	LD	A, (HL)		; A contains cmdline length	
	INC	HL		; HL contains start of cmdline
	LD	(clpos), HL	; Store init parser position
	LD	(clrem), A 	; Store init cmdline length
	LD	A, 0
	LD	(clmode), A	; Say we are in "normal" (not switch) mode
	RET

; clslurp
; moves clpos and clrem so that clpos is pointing to a non-space
; character. Returns with the Z flag set if the end of the 
; command line is reached. On exit, HL contains the same value
; as clpos. The caller should protect the A register if necessary.
clslurp: 
	LD 	HL, (clpos);
	LD 	A, (clrem) 
	OR 	A
	RET	Z		; clem == 0; no more data	

	LD	A, (HL)
	CP	' '
	JR	NZ, .clnosp
	LD	A, (clrem)
	DEC	A
	LD 	(clrem), A
	LD	A, 0
	LD 	(clmode), A
	LD	HL, (clpos)
	INC	HL
	LD	(clpos), HL 
	JR	clslurp
.clnosp:
	LD 	(clpos), HL;
	RET

;------------------------------------------------------------------------
clnext
;------------------------------------------------------------------------
clnext: ; Ret Z if no more data
	CALL	clslurp
	
        ; Check whether we are already at the end of input.
	; If so, return with Z flag set
	LD 	A, (clrem)
	OR	A
	RET	Z

	; Are we in a switch right now?
	LD 	A, (clmode)
	OR	A
	JR	Z, .clnonswmode

	; Yes we are, and (clpos) should be pointing either
	; at the next switch character, or a space
	LD	HL, (clpos)
	LD	A, (HL)
	CP	' '
	; The current position points at a space. So we can just
	;  restart the scan, knowing that this space will be
	;  slurped up. First, we must set outselves back out of switch
	; mode
	JR	NZ, .clmoresw 

	; It's a space 
	LD 	A, 0
	LD 	(clmode), A
	JR 	clnext

.clmoresw:
	LD	A, (clrem)
	DEC	A
	LD	(clrem), A
 	LD 	A, (HL)	
	INC	HL
	LD	(clpos), HL
	OR A	; We know A is non-zero so OR-A will clear the Z flag
	RET

.clnonswmode:	
	LD	HL, (clpos)
	LD	A, (HL)
	CP	'/'
	JR	Z, .clstsw
	CP	'-'
	JR	Z, .clstsw
	JR	.clnotsw

.clstsw:
	; We have encountered the start of a switch. Just skip the
	;   switch character
	LD	A, 1
	LD	(clmode), A
	INC	HL
	PUSH	BC
	LD	B, (HL)
	INC	HL
	LD	(clpos), HL
	LD	A, (clrem)
	DEC	A
	LD	(clrem), A
	LD	A, 1
	OR	A
	LD	A, B 
	POP	BC
	RET

.clnotsw:

	PUSH	HL	; Store the start of the token on the stack

	; Iterate until we run out of chars, or find a sp
	; In either case, write a to (HL)
.slptok:
	LD	A, (HL)
	CP	' '
	JR	NZ, .clnospc 
	; We've hit a space
	LD	(HL), 0
	INC	HL      ; Skip the space, which is now a zero
	LD	(clpos), HL 
	LD	A, 1
	OR	A
	POP	HL	; Restore the token start position to HL for ret
	LD	A, 0
	RET		; Return with Z flag clear, as we have a token
.clnospc:
	LD	A, (clrem)
	DEC	A
	LD	(clrem), A
	OR	A
	JR	NZ, .clnotout
			; We've run out of characters. Terminate the 
			; cmdline, and set clpos to the end of input
	LD	(clpos), HL 
	LD	(HL), 0
	LD	A, 1
	OR	A
	POP	HL	; Restore the token start position to HL for ret
	LD	A, 0
	RET		; Return with Z flag clear, as we have a token

.clnotout:
	INC	HL
	JR	.slptok
		

;------------------------------------------------------------------------
; Data 
;------------------------------------------------------------------------
clpos:
	dw 0

clrem:
	db 0

clbuf:
	ds 129

clmode:
	dw 0

END


