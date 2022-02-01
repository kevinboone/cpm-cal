;------------------------------------------------------------------------
;  conio.asm 
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	include bdos.inc

	global putch, puts, space, newline, exit

;------------------------------------------------------------------------
; exit
; Return to BDOS
;------------------------------------------------------------------------
exit:
       LD C, 0
       CALL  BDOS 

;------------------------------------------------------------------------
;  newline
;  Output CR+LF; all registers preserved
;------------------------------------------------------------------------
newline:
       PUSH   AF
       LD     A, 13
       CALL   putch
       LD     A, 10
       CALL   putch
       POP    AF
       RET

;------------------------------------------------------------------------
;  putch
;  Output the character in A; other registers preserved.
;------------------------------------------------------------------------
putch:
       PUSH   HL        ; We must preserve HL, as the BDOS call sets it
       PUSH   BC
       PUSH   AF
       PUSH   DE 
       LD     C, CONOUT 
       LD     E, A 
       CALL   BDOS 
       POP    DE
       POP    AF
       POP    BC
       POP    HL
       RET

;------------------------------------------------------------------------
;  puts 
;  Output a zero-terminated string whose address is in HL; other
;  registers preserved.
;------------------------------------------------------------------------
puts:
       PUSH   AF
       PUSH   BC 
       PUSH   DE 
puts_next:
       LD     A,(HL) 
       OR     0 
       JR     Z, puts_done

       LD     C, 2
       LD     E, A 
       PUSH   HL
       CALL   BDOS 
       POP    HL

       INC    HL
       JR     puts_next
puts_done:
       POP    DE 
       POP    BC 
       POP    AF
       RET

;------------------------------------------------------------------------
;  space 
;  Output a space; all registers preserved
;------------------------------------------------------------------------
space:
       PUSH   AF
       LD     A,' ' 
       CALL   putch
       POP    AF
       RET

end

