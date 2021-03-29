;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data
LEDON	    equ	 $5B	  ; Value to write to Port B

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
          ldaa    #$FF
          staa    DDRB    ; Configure PORTB as output
          staa    DDRJ   ; Port J as output to enable LED
          ldaa    $37
          staa    DDRP
          ldaa    #00    ; need to write 0 to J0
          staa    PTJ    ; to enable LEDs
          
mainLoop:
          ldaa    #LEDON	; load accumulator with value for port B
          staa    PORTB	; write value to LED bank


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
