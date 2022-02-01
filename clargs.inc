;------------------------------------------------------------------------
;  clargs.inc
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; This module implements a very simple command-line argument parser. 
; The caller calls clinit first, to set the parser up. Then it call
;   clnext until clnext returns with the zero flag set. At this point,
;   there is nothing left to parse.
; If the Z flag is not set, clinit returns a number in A. If this number
;   is non-zero, then it is the ASCII value of a switch character.
; Switches can be introduced using "/" or "-"; they can be combined into
;   the same argument. If clinit returns with A set to zero, then HL
;   points to a particular argument. 
; There is no support for switches that themselves take arguments, or for
;   arguments that contain spaces. The only whitespace recognized is
;   a plain ASCII space (' ').
; Callers should protect the HL and AF registers if necessary; other
;   registers should be unaffected.

	.Z80

external clinit
external clnext

