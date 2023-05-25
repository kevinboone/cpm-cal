;------------------------------------------------------------------------
;  intmath.inc
; 
;  16-bit integer multiplication and division
;  Be aware that these functions can overflow, and no error is raised.
; 
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

; mul16 
; Multiply HL by DE, result in HL 
external mul16 

; div16 
; Divide HL by DE, result in HL, remainder in DE
external div16 


