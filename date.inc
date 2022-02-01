;------------------------------------------------------------------------
;  string.inc
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in string.asm

	.Z80

;------------------------------------------------------------------------
; day_of_week
; Calculates the day of week for a given day, month, and year. On entry
; H = day (1-based), L = month (1-based), DE=year. The result is returned
; in A, and is _zero_ based, with 0 = sunday. All other registers
; are preserved.
;------------------------------------------------------------------------
external day_of_week 

;------------------------------------------------------------------------
; is_leap_year
; Returns with A=1 if the number in HL is a leap year, and A=0 otherwise.
; All registers other than AF are preserved. 
;------------------------------------------------------------------------
external is_leap_year

;------------------------------------------------------------------------
;  days in month 
;  HL=year, D=month, return in A 
;------------------------------------------------------------------------
external days_in_month 

external monthname

