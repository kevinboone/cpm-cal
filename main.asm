;------------------------------------------------------------------------
; 
;  CAL utility
;
;  main.asm 
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;
;------------------------------------------------------------------------

	.Z80

	ORG    0100H

	include conio.inc
	include clargs.inc
	include intmath.inc
	include date.inc
	include string.inc
	include romwbw.inc

	JP	main

;------------------------------------------------------------------------
;  prthelp 
;  Print the help message
;------------------------------------------------------------------------
prthelp:
	PUSH	HL
	LD 	HL, us_msg
	CALL	puts
	LD 	HL, hlpmsg
	CALL	puts
	POP	HL
	RET

;------------------------------------------------------------------------
;  prtversion
;  Print the version message
;------------------------------------------------------------------------
prtversion:
	PUSH	HL
	LD 	HL, ver_msg
	CALL	puts
	POP	HL
	RET

;------------------------------------------------------------------------
;  m_arg0 
; Parse the string at HL as a month. This is usually the zero'th command
;   line argument. Lazily jump out of the function to .badmonth if the
;   month is invalid.
;------------------------------------------------------------------------
m_arg0:
	PUSH	DE
	CALL	atou
	OR	A
	JP	Z, .badmonth 
	LD	A, E
	OR	A
	JP	Z, .badmonth 
	CP	13
	JP	NC, .badmonth 
	LD	(month), A
	POP	DE
	RET

;------------------------------------------------------------------------
;  m_arg1 
; Parse the string at HL as a year. This is usually the 1'th command-line
;   argument (starting at zero). Lazily jump out of the function to
;   .badyear if the year cannot be parsed as a number.
;------------------------------------------------------------------------
m_arg1:
	PUSH	DE
	CALL	atou
	OR	A
	JP	Z, .badyear
	LD	H, D
	LD	L, E
	LD	(year), HL
	POP	DE
	RET

;------------------------------------------------------------------------
;  putmonth
;  Print the month name for the month (1-based) in A.  
;------------------------------------------------------------------------
putmonth:
	PUSH	HL
	CALL	monthname
	; HL points to name
	CALL	puts
	POP	HL
	RET

;------------------------------------------------------------------------
;  putyear
;  Print the year, passed in HL 
;------------------------------------------------------------------------
putyear:
	PUSH	DE
	PUSH	HL
	PUSH	AF
	LD	D, H
	LD	E, L
	LD	HL, numbuff
	CALL	utoa
	CALL	puts
	CALL 	newline	
	POP	AF
	POP	HL
	POP	DE
	RET

;------------------------------------------------------------------------
;  prthdr 
;  Print the "Su Mo..." header
;------------------------------------------------------------------------
prthdr:
	PUSH	HL
	PUSH	AF
	LD	A, (wssun) 
	CP	1
	JR	Z, .prtsun
	LD	HL, hdr_m 
	JR	.prt2
.prtsun:
	LD	HL, hdr_s 
.prt2:
	CALL 	puts
	CALL    newline	
	POP	AF
	POP	HL
	RET

;------------------------------------------------------------------------
;  Start here 
;------------------------------------------------------------------------
main:
	; Initialize the command-line parser
	CALL	clinit
	LD	B, 0	; Arg count

	; Loop until all CL arguments have been seen
.nextarg:
	CALL	clnext
	JR	Z, .argsdone

	OR	A
	JR	Z, .notsw
	; A is non-zero, so this is a switch character 
	; The only switches we handle are /h, /v, and /s at present
	CP	'H'
	JR	NZ, .no_h
	CALL	prthelp
	JP	.done
.no_h:
	CP	'S'
	JR	NZ, .no_s
	LD	A, 1
	LD	(wssun), A
	JR	.nextarg
.no_s:
	CP	'V'
	JR	NZ, .no_v
	CALL	prtversion
	JP	.done
	JR	.nextarg
.no_v:
	JP	.badswitch

.notsw:
	; A was zero after clnext, so not a switch
	; Call m_arg0 for the first argument and m_arg1 for the 
	;   next. These arguments are the month and year
	LD	A, B
	CP	0
	JR	NZ, .not0
	CALL	m_arg0
.not0:	
	LD	A, B
	CP	1
	JR	NZ, .not1
	CALL	m_arg1
.not1:	
	INC	B
	jr	.nextarg

.argsdone:

	; Arguments are done. We should have seen exactly 2 non-switch
	;   arguments, if the user is specifying the date on the command
	;   line. If there is no date, then we will check the RTC, if there is
	;   one installed.

	LD	A, B
	CP	2
	JR	Z, .gotdate ; Two args -- skip the RTC check

	; No date args. Let's see if we'gve got an RTC installed

        LD 	HL, rtcbuf
	CALL	rwbw_getrtc
	CP	0
	JR	NZ, .badrtc ; No we haven't, so don't interpret the results

	LD	A, (rtcye)
	LD	L, A
	LD	H, 0
	; Note that rwbw_getrtc returns year-2000 in a single byte
	LD	DE, 2000
	ADD	HL, DE 
	LD	(year), HL
	LD	A, (rtcmo)
	LD	(month), A

	JR	.gotdate

.badrtc:	; If we get here, we have no RTC, and no command-line arguments.
	LD	HL, nortc_msg
	CALL	puts
	CALL	newline

	JR	.usage	

.gotdate:

	; At this point, we know we have plausible month and year
	; So print them as the first output
	LD	A, (month) 
	CALL	putmonth
	CALL 	space	
	LD	HL, (year)
	CALL	putyear
	LD	D, H
	LD	E, L
	LD	L, A
	LD	H, 1 ; D

	; Calculate the day-of-week (zero-based) corresponding
	;   to the first of the specified month in the 
	;   specified year.
	; To call day_of_week we need year in DE, month in L
	;  and day (always 1 here) in H
	CALL	day_of_week
	; DOW is now in A

	LD	H, A
	LD	A, (wssun) 
	CP	1
	LD	A, H
	JR	Z, .ws_sun

	CP	0
	JR	Z, .day0
	DEC A
	JR	.daydone
.day0:
	LD	A, 6
.daydone:

.ws_sun:

	; We need the number of days in the month, to know when
	;   to stop printing days.
	; days_in_month needs year in HL (currently in DE), and
	;   month in D (currently in L)
	PUSH	AF
	LD	H, D
	LD	D, L
	LD	L, E 
	call	days_in_month
	LD	B, A 
	POP	AF

	CALL	prthdr

	LD	C, 0	; cols written
	LD	D, 1	; current day

	; Loop for printing the first row of blanks, corresponding 
	;   to days that aren't actually in this month 
.fr:
	OR	A	
	JR	Z, .fst_done
	LD	HL, blank 
	call 	puts
	INC	C
	DEC	A
	JR	Z, .fst_done
	JR	.fr
	; At this point, we printed the blanks, so now we print
	;   the days. The current D number is held in the D reg
.fst_done:
	LD 	HL, numbuff 
	LD	A, D
	CP	10
	JR	NC, .nopad
	CALL 	space	
.nopad:			; Single-digit days need padding to align
	PUSH	DE
	LD	E, D 
	LD	D, 0
	CALL	utoa	; Convert the day number to a string...
	POP	DE
	CALL    puts	; ... and print it, followed by a space 
	CALL	space
	INC	C
	LD	A, C	; Check is we're at the end of a row...
	CP	7
	JR	NZ, .not_end	
	LD	C, 0	; ... and reset the column count
	CALL	newline
.not_end:
	LD	A, D
	CP	B	
	JR	Z, .days_done
	INC	D
	JR	.fst_done
	; We've printed all the days. Finish with a newline...
.days_done:
	call newline	

.done:
	; ...and exit cleanly
	CALL	exit

;-------------------------------------------------------------------------
; usage
; print usage message and exit
;-------------------------------------------------------------------------
.usage:
	LD	HL, us_msg
	CALL	puts
	CALL	newline
	JR	.done

;-------------------------------------------------------------------------
; badmonth 
; print "Bad month" message and exit. The month name is in HL on entry 
;-------------------------------------------------------------------------
.badmonth:
	PUSH	HL
	LD	HL, bm_msg
	CALL	puts
	POP	HL
	call 	puts
	CALL	newline
	JR	.done

;-------------------------------------------------------------------------
; badswitch
; print "Bad option" message and exit. 
;-------------------------------------------------------------------------
.badswitch:
	LD	HL, bs_msg
	CALL	puts
	CALL	newline
	LD	HL, us_msg
	CALL	puts
	CALL	newline
	JR	.done

;-------------------------------------------------------------------------
; badyear
; print "Bad year" message and exit. The year is in HL on entry 
;-------------------------------------------------------------------------
.badyear:
	PUSH	HL
	LD	HL, by_msg
	CALL	puts
	POP	HL
	call 	puts
	CALL	newline
	JR	.done

;------------------------------------------------------------------------
; Data 
;------------------------------------------------------------------------
hdr_m:
	db "Mo Tu We Th Fr Sa Su"
	db 0

hdr_s:
	db "Su Mo Tu We Th Fr Sa"
	db 0

blank:
	db "   "
	db 0

hlpmsg: 	
	db "/h show help text"
        db 13, 10
	db "/s week starts sunday"
        db 13, 10
	db "/v show version"
        db 13, 10
	db 0

; Scratch area for converting integers to strings
numbuff:
	db "12345678"
	db 0

us_msg:
	db "Usage: cal [/hsv] {month} {4-digit year}"
        db 13, 10, 0

ver_msg:
	db "cal 0.1c, copyright (c)2023 Kevin Boone, GPL v3.0"
        db 13, 10, 0

bm_msg:
	db "Bad month: ", 0

by_msg:
	db "Bad year: ", 0

bs_msg:
	db "Bad option.", 0 

nortc_msg:
	db "No RTC: give month and year", 0 

; Store month parsed from command line -- only one byte needed
month:
	db 0

; Store year parsed from command line -- this will need two bytes 
year:
	dw 0

; Flag to indicate user wants week to start on Sunday
wssun:	db 0

; Six-byte buffer for date/time from the RTC. We can refer to the start of
;   this buffer as rtcbuf, and the individual elements as rtcmo, rtcda, etc.
rtcbuf:
rtcye:  ; year
	db 0
rtcmo:  ; month
	db 0
rtcda:  ; day
	db 0
rtchr:  ; hour
	db 0
rtcmi:  ; min
	db 0
rtcse:  ; sec
	db 0

end 

