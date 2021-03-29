

;*************************************************
;*       Program for Laboratory 
;*
;*       A line starting with a ';' is treated as
;*       a comment. Also, anything after ";" will
;*       be considered a comment. 
;*       Please comment your code.
;*       It is assessable!
;*
;*************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
    INCLUDE 'derivative.inc' 

ROMStart  EQU  $4000  ; absolute address to place my code/constant data
LEDON	    equ	 $5B	  ; Value to write to Port B

; variable/data section

          ORG RAMStart
 ; Insert here your data definition.
Counter   DS.W 1


; code section
          ORG   ROMStart


Entry:
_Startup:
          LDS   #RAMEnd+1       ; initialize the stack pointer


;**** you may want to write your own equates here *****

          ldaa    #$FF
          staa    DDRB    ; Configure PORTB as output
          staa    DDRJ   ; Port J as output to enable LED
          staa    DDRP
          ldaa    #00    ; need to write 0 to J0
          staa    PTJ    ; to enable LEDs

                              
start:    ldaa    #LEDON	; load accumulator with value for port B

          ldab    #$06
          jsr     digit_0
          
          ldab    #$5B
          jsr     digit_1
         
          ldab    #$4F
          jsr     digit_2
          
          ldab    #$66
          jsr     digit_3  
                                      
          ;clr     PORTB	; now turn the LED(s) off
          
          bra     start	; loop back to beginning


delay:
          LDAA #20              
          
      Outer:
             
             LDX #65
       Loop:
       
            LDAB #1
            DEX 
            
            BNE Loop
            
            
             DECA
             BNE Outer
            
          rts		; return from subroutine
          
          
digit_0:
          ldaa    #$07    ; need to write  to PORTP
          staa    PTP    ; to enable first LED
          stab    PORTB
          BSR     delay
          rts

digit_1:
          ldaa    #$0B    ; need to write  to PORTP
          staa    PTP    ; to enable second LED
          stab    PORTB
          BSR     delay
          rts
          
digit_2:
          ldaa    #$0D    ; need to write  to PORTP
          staa    PTP    ; to enable third LED
          stab    PORTB
          BSR     delay
          rts
          
digit_3:
          ldaa    #$0E    ; need to write  to PORTP
          staa    PTP    ; to enable fourth LED  
          stab    PORTB
          BSR     delay
          rts

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
          ORG   $FFFE
          DC.W  Entry           ; Reset Vector