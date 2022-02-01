;------------------------------------------------------------------------
;  mem.inc
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in mem.asm

	.Z80


; Set BC bytes starting at HL to the value of A
external memset 

; Copy BC bytes from HL to DE. All registers preserved. 
external memcpy

