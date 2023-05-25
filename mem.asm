;------------------------------------------------------------------------
;  mem.asm 
;  See mem.inc for descriptions
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global memset, memcpy

;------------------------------------------------------------------------
; memset	 
;------------------------------------------------------------------------
memset:
	PUSH	BC
	PUSH	HL	
	PUSH	DE
	LD	E, A 
.ms_next:
	LD	A, B
	OR	C
	JR	Z, .ms_done
	LD	(HL), E 
	DEC 	BC
	INC	HL
	JR	.ms_next
.ms_done:
	POP	DE
	POP	HL
	POP	BC
	RET

;------------------------------------------------------------------------
; memcpy
;------------------------------------------------------------------------
memcpy:
	LD	A, B
	OR	C
	JR	Z, .mcp1
	LD	A, (HL)
	LD	(DE), A
	DEC	BC
	INC	HL
	INC	DE
	JR	memcpy
.mcp1:
	RET

END
