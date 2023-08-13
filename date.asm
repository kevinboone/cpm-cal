;------------------------------------------------------------------------
;  date.asm 
;  See date.inc for descriptions
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global day_of_week, is_leap_year, days_in_month, monthname
	include INTMATH.INC

;------------------------------------------------------------------------
;  day_of_week 
;------------------------------------------------------------------------
day_of_week:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH 	HL

	; If month (1-based) < 3, dec year
        LD	A, L
	CP	3
	JR	NC, .mgte3
	DEC	DE
.mgte3:
	LD	B, D
	LD	C, E
	; BC contains running total, starting with year 

	PUSH	DE
	LD	H, D
	LD	L, E
	LD	D, 0
	LD	E, 4	
	CALL	div16
	; HL contains Y / 4
	ADD	HL, BC
	LD	B, H
	LD	C, L
	POP	HL	
	; BC contains Y + Y / 4
	; HL contains Y
	LD	D, H
	LD	E, L
	PUSH	DE
	LD	D, 0 
	LD	E, 100
	CALL	div16
	; HL contains Y / 100 
	PUSH	HL
	LD	H, B
	LD	L, C
	POP	BC
	SBC	HL, BC 
	PUSH	HL
	POP	BC
	POP	DE
	; BC now contains Y + Y / 4 - Y / 100
	; DE now contains Y
	PUSH	BC
	PUSH	DE
	LD	H, D
	LD	L, E
	LD	DE, 400  
	CALL	div16
	POP	DE
	POP	BC
	; HL contains Y / 400
	ADD	HL, BC	
	LD	B, H
	LD	C, L	
	; BC now contains Y + y / 4 - Y / 100 + Y / 400
	POP 	HL

        DEC	L	; L contains mon, zero-based; H contains day	
			; BC still contains cumulative total
	PUSH	HL
	PUSH	HL
	PUSH	BC
	LD	C, L
	LD	B, 0
	LD	HL, t_mon
	ADD	HL, BC
	LD	A, (HL)
	POP	BC
	POP	HL
	; A now contains the t_mon value

	LD	H, B
	LD	L, C
	LD	E, A
	LD	D, 0
	ADD	HL, DE
	; HL now contains cumulative total
	POP	DE
	; E now contains 0, D contains day 
	LD 	E, D
	LD 	D, 0
	ADD 	HL, DE
	; HL now contains cumulative total

	LD	D, 0
	LD	E, 7
	CALL	div16

	LD	A, E
	; A has the final result, 0-6 = sunday-saturday
	
	POP	BC
	POP	DE
	POP	HL
	RET

;------------------------------------------------------------------------
;  is_leap_year 
;  HL = year, A = 0 or 1
;------------------------------------------------------------------------
is_leap_year:
	PUSH	HL
	PUSH	DE

	; Divisible by 400 is a leap year
	PUSH	HL
	LD	DE, 400
	CALL	div16
	POP	HL
	LD	A, D
	OR	E
	JR	Z, .is_leap

	; Divisible by 100 (other than 400) is not a leap year
	PUSH	HL
	LD	DE, 100
	CALL	div16
	POP	HL
	LD	A, D
	OR	E
	JR	Z, .not_leap

	; Divisible by 4 (other than 100) is a leap year
	PUSH	HL
	LD	DE, 4 
	CALL	div16
	POP	HL
	LD	A, D
	OR	E
	JR	Z, .is_leap

	JR	.not_leap

.is_leap:
	POP	DE
	POP	HL
	LD 	A, 1
	RET 
.not_leap:
	POP	DE
	POP	HL
	LD 	A, 0
	RET 

;------------------------------------------------------------------------
;  days in month 
;  HL=year, D=month, return in A 
;------------------------------------------------------------------------
days_in_month:
	CALL	is_leap_year
	OR	A
	JR	Z, .dim_nl
	; Leap year only relevant for February (D = 2)
	LD	A, D	
	CP	2
	JR	NZ, .dim_nfeb
	LD	A, 29
	JR	.dim_done

.dim_nfeb:
.dim_nl:
	LD	A, D	
	CP	1
	JR	Z, .dim_31
	CP	3
	JR	Z, .dim_31
	CP	4
	JR	Z, .dim_30
	CP	5
	JR	Z, .dim_31
	CP	6
	JR	Z, .dim_30
	CP	7
	JR	Z, .dim_31
	CP	8
	JR	Z, .dim_31
	CP	9
	JR	Z, .dim_30
	CP	10	
	JR	Z, .dim_31
	CP	11	
	JR	Z, .dim_30
	CP	12	
	JR	Z, .dim_31
	LD	A, 28
	JR	.dim_done
.dim_30:
	LD	A, 30
	JR	.dim_done
.dim_31:
	LD	A, 31
	JR	.dim_done
.dim_done:
  	RET

;------------------------------------------------------------------------
;  monthname
;  A=month (1-based), result in HL 
;------------------------------------------------------------------------
monthname:
	CP	1
	JR	NZ, .mn_2
	LD	HL, mn_jan
	RET
.mn_2:
	CP	2
	JR	NZ, .mn_3
	LD	HL, mn_feb
	RET
.mn_3:
	CP	3
	JR	NZ, .mn_4
	LD	HL, mn_mar
	RET
.mn_4:
	CP	4
	JR	NZ, .mn_5
	LD	HL, mn_apr
	RET
.mn_5:
	CP	5
	JR	NZ, .mn_6
	LD	HL, mn_may
	RET
.mn_6:
	CP	6
	JR	NZ, .mn_7
	LD	HL, mn_jun
	RET
.mn_7:
	CP	7
	JR	NZ, .mn_8
	LD	HL, mn_jul
	RET
.mn_8:
	CP	8
	JR	NZ, .mn_9
	LD	HL, mn_aug
	RET
.mn_9:
	CP	9
	JR	NZ, .mn_10
	LD	HL, mn_sep
	RET
.mn_10:
	CP	10	
	JR	NZ, .mn_11
	LD	HL, mn_oct
	RET
.mn_11:
	CP	11	
	JR	NZ, .mn_12
	LD	HL, mn_nov
	RET
.mn_12:
	CP	12	
	JR	NZ, .mn_13
	LD	HL, mn_dec
	RET
.mn_13:
	LD 	HL, oops 
	RET

;------------------------------------------------------------------------
;  data 
;------------------------------------------------------------------------
t_mon:
	db 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4

mn_jan: db " January", 0
mn_feb: db "February", 0
mn_mar: db "  March", 0
mn_apr: db "  April", 0
mn_may: db "   May", 0
mn_jun: db "  June", 0
mn_jul: db "  July", 0
mn_aug: db " August", 0
mn_sep: db "September", 0
mn_oct: db " October", 0
mn_nov: db "November", 0
mn_dec: db "December", 0

oops: db "???", 0

END

