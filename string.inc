;------------------------------------------------------------------------
;  string.inc
; 
;  Functions for working with C-style, zero-terminated strings
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

; MAX_DEC_STR is the size of buffer needed to store a decimal 
;   representation of a signed 16-bit integer, including the
;   terminating zero. "-32767[0]" 
	MAX_DEC_STR	equ	7

;------------------------------------------------------------------------
; strlen 
; Length returned in DE of a zero-terminated string in HL. The result
;  does not include the zero terminator (just like in C)
;------------------------------------------------------------------------
external strlen 

;------------------------------------------------------------------------
; strcpy
; Copy the zero-terminated string at HL to the location pointed to
;   by DE. This routine can overrun the output buffer; the caller
;   need to ensure there is space
;------------------------------------------------------------------------
external strcpy

;------------------------------------------------------------------------
; streverse
; Reverse the zero-termnated string whose starting address is in HL.
; The length (not including terminator) is in DE. If DE == 0,
;   calculate the length by counting (slow).
;------------------------------------------------------------------------
external streverse

;------------------------------------------------------------------------
; utoa
; Unsigned 16-bit integer in DE, to a zero-terminated decimal string stored
;   at HL. The buffer at HL must have room to fit the converted number. 
;------------------------------------------------------------------------
external utoa

;------------------------------------------------------------------------
; atou 
; Read the zero-terminated digit string addressed by HL as an unsigned
;  16-bit number, with value returned in DE. Unlike C functions with
;  similar names, atou expects all characters in the string to be
;  digits. If the conversion succeeds, A is returned as 1, otherwise
;  0. ALl registers except AF and HL are preserved. 
;------------------------------------------------------------------------
external atou 


