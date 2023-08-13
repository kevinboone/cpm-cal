;------------------------------------------------------------------------
;  clargs.asm 
;  See clargs.inc for description
;  
;  See lines beginning with #### for compile-time configuration options
;  Updated July 16 2023
; 
;  Copyright (c)2022-3 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	include CONIO.INC
	include MEM.INC
	global clinit, clnext 

;------------------------------------------------------------------------
clinit
;------------------------------------------------------------------------
clinit:
	PUSH	HL
	PUSH	DE
	PUSH	BC

        ; Copy the CP/M command line buffer into working memory at clbuf,
	;   as this function modifies it
	LD	HL, 080h
	LD	DE, clbuf
	LD	BC, 128		; CP/M max command line is 128
	CALL	memcpy
	LD	HL, clbuf	; HL contains start of cmdline area
	LD	A, (HL)		; A contains cmdline length	
	INC	HL		; HL contains start of cmdline
	LD	(clpos), HL	; Store init parser position
	LD	(clrem), A 	; Store init cmdline length
	LD	A, 0
	LD	(clmode), A	; Say we are in "normal" (not switch) mode

	; ### Trim trailing space from end of the command line. Some CCP 
	; ###  implementations and (probably) all emulators do this 
	; ###  anyway, but it cannot be relied on. If the command line can
        ; ###  legitimately contain significant spaces, probably the following
	; ###  section could be removed.
	LD	HL, clbuf
	LD	A, (clrem)
	LD	B, A
	LD	E, A
	LD	D, 0
	ADD	HL, DE
.nexttrim:
	LD	A, (HL)
	CP	' '
	JR	NZ, .donetrim
	LD	A, 0
	LD	(HL), A
	DEC	HL
	DEC	B
	JR	NZ, .nexttrim

	; End of command-line trimming
.donetrim:
        ; Print the trimmed command line for debugging
	;LD	HL, clbuf
	;INC	HL
	;LD	A, '@'
	;call	putch
	;CALL	puts
	;call	putch
	;CALL	newline
	; End debugging section

	POP	BC
	POP	DE
	POP	HL
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
	RET	Z		; clrem == 0; no more data	

	LD	A, (HL)
	CP	' '
	JR	NZ, .clnosp
	; It's a space
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
clnext: ; Ret Z-flag set if no more data
	CALL	clslurp
	
        ; Check whether we are already at the end of input.
	; If so, return with Z flag set
	LD	HL, (clpos)
	LD 	A, (clrem)
	OR	A
	RET	Z

	; Are we in a switch right now?
	LD 	A, (clmode)
	OR	A
	JR	Z, .clnonswmode

	; Yes we are, and (clpos) should be pointing either
	;   at the next switch character, or a space, or the terminating
        ;   zero (which we put there)
	LD	HL, (clpos)
	LD	A, (HL)

	CP	0
	JR	NZ, .notnul
	; We are pointing at the terminating zero -- parse done
	LD	A, 0
	CP	0	; Ensure zero flag set
	RET

.notnul:
	; We are not pointing at the terminating zero. Is it a space?
	CP	' '
	JR	NZ, .clmoresw 

	; The current position points at a space. So we can just
	;  restart the scan, knowing that this space will be
	;  slurped up. First, we must set outselves back out of switch
	; mode
	LD 	A, 0
	LD 	(clmode), A
	JR 	clnext

.clmoresw:
	; We're not looking at a space or a zero, so this is a real switch
	LD	A, (clrem)
	DEC	A
	LD	(clrem), A
 	LD 	A, (HL)	
	INC	HL
	LD	(clpos), HL
	OR A	; We know A is non-zero so OR-A will clear the Z flag
	RET

.clnonswmode:	
	; We aren't in a switch at present. So check whether we're pointing
        ;   at the _start_ of a new switch
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
        ; #### The following three lines should only be included if the
        ; ####   caller intends to parse the non-switch arguments itself,
        ; ####   and will stop parsing as soon as this function returns
        ; ####   with A=0
	;LD 	A, 0
	;CP	0	; Ensure zero flag set
	;RET

	; We're not in a switch -- this is an ordinary argument
	PUSH	HL	; Store the start of the token on the stack
			;   because we need it later
	; Iterate until we run out of chars, or find a space
	; In either case, write a 0 to (HL)
.slptok:
	LD	A, (HL)
	CP	' '
	JR	NZ, .clnospc 
	; We've hit a space
	LD	(HL), 0
	INC	HL      ; Skip the space, which is now a zero
	LD	(clpos), HL 
	POP	HL	; Restore the token start position to HL for ret

	LD	A, 1
	OR	A
	LD	A, 0
	RET		; Return with Z flag clear, as we have a token
			; Return with A = 0, as it is not a switch
.clnospc:
	LD	A, (clrem)
	DEC	A
	LD	(clrem), A
	OR	A
	JR	NZ, .clnotout
			; We've run out of characters. Terminate the 
			; cmdline, and set clpos to the end of input
	LD	(clpos), HL 
	INC	HL
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
clpos:		; Parser current position in command line area
	dw 0

clrem:		; Amount of CL left to parse. Starts at length suppled
		;   by CP/M, and is decremented as we parse
	db 0

clbuf:		; Command line is copied here
	ds 129

clmode:         ; 0 = general, 1 = switch 
	dw 0

END


