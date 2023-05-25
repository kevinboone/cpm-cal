;------------------------------------------------------------------------
;  conio.inc
;  
;  Functions for working with the ROMWBW BIOS. At present, I've only 
;    implemented functions to check with ROMWBW is installed, and to
;    read the RTC.
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

;------------------------------------------------------------------------
; rwbw_chk
; Check whether we are running on a ROMWBW machine 
; If ROMWBW is present, the A register will return the major and minor
;   versions in the upper and lower four bits. If the return value in
;   A is zero, it's safe to assume that we aren't running on ROMWBW
;------------------------------------------------------------------------
	external rwbw_chk 


;------------------------------------------------------------------------
; rwbw_getrtc
; 
; Gets the date/time information from the RTC, if fitted. On entry, HL;
;   points to a buffer six byte capacity. The bytes are interpreted as
;   follows:
;   0 - years since 2000
;   1 - month (1-12)
;   2 - day (1-31)
;   3 - hour
;   4 - minute
;   5 - second
; Although the RTC hardware returns values in BCD, this function converts
;   them to decimal. Any 8-bit BCD value will fit into an 8-bit binary
;   value.
; On exit, A contains zero on success, 0xFF if there is no ROMWBW, and
;   some other error code if there is a hardware error. At present, there
;   is no general way to interpret these error codes.
; Note that ROMWBW may have a fallback clock if there is no RTC. 
; 
;------------------------------------------------------------------------
	external rwbw_getrtc


