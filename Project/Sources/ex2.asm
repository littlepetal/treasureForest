

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
            ABSENTRY Entry                  ; for absolute assembly: mark this as application entry point

; include derivative-specific definitions 
    INCLUDE 'derivative.inc' 

ROMStart  EQU  $4000  ; absolute address to place my code/constant data
LEDON	    EQU	 $5B	  ; value to write to Port B

; variable/data section
          ORG RAMStart
          
; insert here your data definition.
Counter   DS.W 1
ascii_value  DS.B 1   ; allocate one byte for the ascii value
output_digit  DS.B 1  ; allocate one byte for the output digit
length_count  DS.B 1
seven_seg_code DS.B 10 
terminating_character  FCC ""
digits_string  FCC "567891234"
               FCB $0D
; code section
          ORG   ROMStart

Entry:
_Startup:
          LDS   #RAMEnd+1       ; initialize the stack pointer


;**** you may want to write your own equates here *****

          LDAA    #$FF
          STAA    DDRB    ; configure PORTB as output
          STAA    DDRJ    ; configure PORTJ as output
          STAA    DDRP    ; configure PORTP as output
          LDAA    #00     
          STAA    PTJ     ; write 0 to J0 to enable LEDs
          STAA    DDRH
          
          LDAA    #56
          STAA    ascii_value
          
          ;JSR     checkLength
          
          ;BRA     staticFourDigits
          ;BRA     asciiToDigitOutput
          ;BRA     scroll  
          
          ;LDX    #digits_string
          ;BRA    moving
          JSR     readFromButton
                              
staticFourDigits:    ;LDAA    #LEDON	; load accumulator A with value for port B   (potentially redundant)
          
          LDAB    #$06    ; load accumulator B with value to be displayed
          JSR     digit_0          
          
          LDAB    #$5B    ; load accumulator B with value to be displayed
          JSR     digit_1
         
          LDAB    #$4F    ; load accumulator B with value to be displayed
          JSR     digit_2
          
          LDAB    #$66    ; load accumulator B with value to be displayed
          JSR     digit_3  
                                      
          ;CLR     PORTB	  ; now turn the LED(s) off
          
          BRA     staticFourDigits	   ; loop back to beginning
          
asciiToDigitOutput:

          LDX     #digits_string
          
          LDAA    0, x
          STAA    ascii_value
          JSR     getSevenSegCode               ; convert ascii value to decimal value to be displayed
          JSR     digit_0                    
          
          LDAA    1, x
          STAA    ascii_value
          JSR     getSevenSegCode               ; convert ascii value to decimal value to be displayed
          JSR     digit_1
                
          LDAA    2, x
          STAA    ascii_value
          JSR     getSevenSegCode               ; convert ascii value to decimal value to be displayed
          JSR     digit_2
                    
          LDAA    3, x
          STAA    ascii_value
          JSR     getSevenSegCode               ; convert ascii value to decimal value to be displayed
          JSR     digit_3 
          
          BRA     asciiToDigitOutput
          
readFromButton:
          LDAA    PTH
          RTS           
          
scroll:
          LDX     #digits_string
          ;LDY     length_count
          
          loop:
                  LDAA    0, x
                  
                  TAB
                  SUBB    #13
                  BEQ     scroll
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_0

                  LDAA    1, x
                  
                  TAB
                  SUBB    #13
                  BEQ     scroll                  
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_1

                  LDAA    2, x
                  
                  TAB
                  SUBB    #13
                  BEQ     scroll                  
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_2
  
                  LDAA    3, x
                  
                  TAB
                  SUBB    #13
                  BEQ     scroll                  
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_3          

                  INX     

                  BRA     loop
                  
          ;restart:
                  ;BRA     scroll        

delay:                     ; keeps the current display lit for approx. 0.5ms
          LDAA #200                        
          outerLoop:            
                  LDY #58
                  ;LDY #1000
                  
                  innerLoop:
                          DEY            
                          BNE innerLoop            
            
                  DECA
                  BNE outerLoop            
          RTS	
          
delayLong:                     ; keeps the current display lit for approx. 0.5ms
          LDAA #200                        
          outerLoopagain:            
                  ;LDY #58
                  LDY #10000
                  
                  innerLoopagain:
                          DEY            
                          BNE innerLoopagain            
            
                  DECA
                  BNE outerLoopagain            
          RTS	
          
digit_0:
          LDAA    #$07     ; need to write #$07 to PORTP
          STAA    PTP      ; to enable first LED
          STAB    PORTB
          BSR     delay
          RTS

digit_1:
          LDAA    #$0B     ; need to write #$0B to PORTP
          STAA    PTP      ; to enable second LED
          STAB    PORTB
          BSR     delay
          RTS
          
digit_2:
          LDAA    #$0D     ; need to write #$0D to PORTP
          STAA    PTP      ; to enable third LED
          STAB    PORTB
          BSR     delay
          RTS
          
digit_3:
          LDAA    #$0E     ; need to write #$0E to PORTP
          STAA    PTP      ; to enable fourth LED  
          STAB    PORTB
          BSR     delay
          RTS
          
asciiToDigitlookup:
          LDAA    ascii_value
          LDAB    #0
          
          SUBA    #47
          
          loopOne:                  
                  DECA
                  BEQ     found
                  INCB
                  BRA loopOne
          found:
                STAB    output_digit
                RTS
                
initialise_seven_seg_code:
          LDX     #seven_seg_code
          
          LDAB    #$7E
          STAB    0,x
          LDAB    #$30
          STAB    1,x
          LDAB    #$6D
          STAB    2,x
          LDAB    #$79
          STAB    3,x          
          LDAB    #$33
          STAB    4,x                    
          LDAB    #$5B
          STAB    5,x
          LDAB    #$5F
          STAB    6,x          
          LDAB    #$70
          STAB    7,x                              
          LDAB    #$7F
          STAB    8,x
          LDAB    #$7B
          STAB    9,x  
          
          RTS      
          
getSevenSegCode:                        ; ascii lookup table
          LDAA   ascii_value
          
          TAB
          SUBB   #48
          BEQ    found_0
                      
          TAB
          SUBB   #49
          BEQ    found_1
                           
          TAB
          SUBB   #50
          BEQ    found_2
                                             
          TAB
          SUBB   #51
          BEQ    found_3         
  
          TAB
          SUBB   #52
          BEQ    found_4          
                 
          TAB
          SUBB   #53
          BEQ    found_5                          
                 
          TAB
          SUBB   #54
          BEQ    found_6          
                 
          TAB
          SUBB   #55
          BEQ    found_7                 
                 
          TAB
          SUBB   #56
          BEQ    found_8           
                 
          TAB
          SUBB   #57
          BEQ    found_9
          
          ;TAB
          ;SUBB   #13
          ;BEQ    restart
          
          found_0:
                 LDAB   #$3F
                 RTS  
          found_1:
                 LDAB   #$06
                 RTS                  
          found_2:
                 LDAB   #$5B
                 RTS
          found_3:
                 LDAB   #$4F
                 RTS
          found_4:
                 LDAB   #$66
                 RTS  
          found_5:
                 LDAB   #$6D
                 RTS 
          found_6:
                 LDAB   #$7D
                 RTS 
          found_7:
                 LDAB   #$07
                 RTS                                   
          found_8:
                 LDAB   #$7F
                 RTS 
          found_9:
                 LDAB   #$6F
                 RTS                                                                 
                                                  
checkLength:
          LDAA  #0
          LDX   #digits_string
          
          loopTwo:
                LDAB  1, x+
                CMPB  terminating_character
                BEQ   finishLengthCount
                INCA               
                BRA loopTwo
                
          finishLengthCount:
                                            
                STAA  length_count
                RTS         
  
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
          ORG   $FFFE
          DC.W  Entry      ; reset Vector