;------------------------------------------------------------------------
;  string.asm 
;  See string.inc for description.
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global strlen, strcpy, streverse, utoa, atou
	include intmath.inc

;------------------------------------------------------------------------
; strlen 
; HL = addr; result in DE
;------------------------------------------------------------------------
strlen:
	PUSH	HL
	LD	DE, 0
.s_loop:
	LD	A, (HL)
	OR	A	
	JR	Z, .s_done
	INC	HL
	INC 	DE
	JR	.s_loop
.s_done:
	POP	HL
	RET

;------------------------------------------------------------------------
; strcpy
;------------------------------------------------------------------------
strcpy:
	PUSH	HL
	PUSH	DE
.sc_loop:
	LD	A, (HL)
	LD	(DE), A
	OR	A	
	JR	Z, .sc_done
	INC	HL
	INC 	DE
	JR	.sc_loop
.sc_done:
	POP 	DE	
	POP	HL
	RET

;------------------------------------------------------------------------
; streverse
;------------------------------------------------------------------------
streverse:
	; HL = start of string, DE = count

	PUSH 	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	; If DE == 0, we must calculate the string length
	LD	A, D
	OR	E
	JR	NZ, .st_hasl
	CALL	strlen

.st_hasl:
	; Don't try to reverse a string of length 1 -- it goes
	;   horribly wrong
	LD	A, D
	OR	A
	JR	NZ, .st_nzl
	LD	A, E
	CP	1	
	JR	NZ, .st_nzl
	JR	.st_done	
.st_nzl:
	PUSH	HL
	ADD	HL, DE
	DEC	HL
	POP	BC
	; BC = start, HL = end 

	; Divide DE (the count) by two, once we've used it to 
	;  calculate the address of the end of the string. Otherwise
	;  we'll reverse the string and then reverse it back
	SRL	D
	RR	E

.strv0:	
	PUSH	DE
	LD	A, (BC)
	LD	E, A
	LD	A, (HL)
	LD	(BC), A
	LD	(HL), E
	POP	DE

	DEC	HL
	INC	BC
	
	DEC 	DE
	LD	A, D
	OR	E
	JR	NZ, .strv0 
.st_done:
	POP	AF
	POP	BC
	POP	DE
	POP	HL

	RET

;------------------------------------------------------------------------
; utoa 
; HL = buff, DE = num
;------------------------------------------------------------------------
utoa:
	PUSH	BC	
	PUSH	DE
	PUSH	HL	

	LD	B, H
	LD	C, L
	; BC now = start address

	LD	H, D
	LD	L, E
	; HL now = running total

.ut_loop:
	LD	DE, 10
	call	div16	
	; HL = quotient, DE = remainder

	LD	A, E
	ADD	A, '0'
	LD	(BC), A
	INC	BC
	LD	A, 0
	LD	(BC), A
	
	LD	A, H
	OR	L
	JR 	Z, .ut_done
	JR	.ut_loop

.ut_done:
	POP	HL	
	LD	DE, 0
	CALL	streverse
	POP	DE
	POP	BC	

	RET

;------------------------------------------------------------------------
; atou 
; HL = buff, result in DE
;------------------------------------------------------------------------
atou:
	PUSH	HL
	PUSH 	BC	

	LD	DE, 0h	; DE is the running total

.atol_next:
	LD	A, (HL)
	OR	A
	JR	Z, .atol_ok

	; Multiply running total in DE by 10
	PUSH	HL	
	LD	HL, 10
	CALL	mul16	
	LD	D, H
	LD	E, L
	POP	HL

	; Add current digit to running total
	SUB	'0' 
	; Check that digit val is < 10
	CP 	10	
	JR	NC, .atol_err

	PUSH	HL
	PUSH	BC	
	LD	H, D
	LD	L, E
	LD	B, 0
	LD	C, A
	ADD	HL, BC 
	LD	D, H
	LD	E, L
	POP	BC
	POP	HL

	INC 	HL
	JR	.atol_next
.atol_ok:
	LD	A, 1
.atol_done:
	POP	BC
	POP	HL
	RET

.atol_err:
	LD	DE, 0
	LD	A, 0
	JR	.atol_done



END


