;------------------------------------------------------------------------
;  intmath.asm 
;  See intmath.inc for descriptions
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global mul16, div16

;------------------------------------------------------------------------
; mul16 
;------------------------------------------------------------------------
mul16:
	PUSH 	DE 
	PUSH	BC
	PUSH 	AF	
	LD 	B, H
	LD 	C, L
    	LD 	A, 16 ; No. of bits to process    
    	LD 	HL, 0 ; Cumulative result
.m16_loop:
	SRL 	B
	RR 	C        
	JR 	NC, .m16_no 
	ADD 	HL, DE   
.m16_no:
	EX 	DE, HL    
	ADD 	HL, HL   
	EX 	DE, HL    
	DEC 	A
	JR 	NZ, .m16_loop 
	POP	AF
	POP 	BC 
	POP	DE
	RET

;------------------------------------------------------------------------
; div16 
;------------------------------------------------------------------------

div16:
	PUSH	BC
	PUSH	AF	
	LD 	B, H
	LD 	C, L
	LD 	HL, 0
	LD 	A, B
	LD 	B, 8
.d16_l1:
	RLA
	ADC HL, HL
	SBC HL, DE
	JR NC, .D16_NO1
	ADD HL,DE
.d16_no1:
	DJNZ .d16_l1
	RLA
	CPL
	LD B ,A
	LD A, C
	LD C, B
	LD B, 8
.d16_l2:
	RLA
	ADC HL,HL
	SBC HL,DE
	JR NC, .d16_no2
	ADD 	HL, DE
.d16_no2:
	DJNZ .d16_l2
	RLA
	CPL
	LD 	B, C
	LD 	C, A
	POP	AF
	LD 	D, H
	LD 	E, L
	LD 	H, B
	LD 	L, C
	POP 	BC
	RET

END



