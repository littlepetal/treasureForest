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
digits_string  FCC "0123456789"
               FCB $0D
               
port_h_value  DS.B  1
long_delay  DS.W  1
sevenSegEnabler DS.B 1
               
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
          
          LDY     #200
          STY     long_delay
                              
          ;JSR     staticFourDigits
          ;JSR     asciiToDigitOutput
          ;JSR     scroll  
          
          ;LDX    #digits_string
          ;JSR     choiceOfDigits
                              
staticFourDigits:   
          
          LDAB    #$06    ; load accumulator B with value to be displayed
          JSR     digit_0          
          
          LDAB    #$5B    ; load accumulator B with value to be displayed
          JSR     digit_1
         
          LDAB    #$4F    ; load accumulator B with value to be displayed
          JSR     digit_2
          
          LDAB    #$66    ; load accumulator B with value to be displayed
          JSR     digit_3  
                                                
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
          STAA    port_h_value
          RTS           
          
scroll:
          LDX     #digits_string
          
          loop:
                  LDAA    0, x
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_0

                  LDAA    1, x               
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_1

                  LDAA    2, x               
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_2
  
                  LDAA    3, x                 
                  
                  STAA    ascii_value
                  JSR     getSevenSegCode
                  JSR     digit_3          

                  
                  LDY     long_delay
                  DEY
                                          
                  
                  BEQ     restart
                  
                  STY     long_delay                  
    

                  BRA     loop
                  
          restart:
                  LDY     #200
                  STY     long_delay
                  
                  INX
                  
                  LDAB    0, x
                  SUBB    #13
                  BEQ     scroll 
                  
                  LDAB    1, x
                  SUBB    #13
                  BEQ     scroll
                  
                  LDAB    2, x
                  SUBB    #13
                  BEQ     scroll 
                  
                  LDAB    3, x
                  SUBB    #13
                  BEQ     scroll                  
                                   
                  BRA     loop        

delay:                     ; keeps the current display lit for approx. 0.5ms
          LDAA #200                        
          outerLoop:            
                  LDY #58
                  
                  innerLoop:
                          DEY            
                          BNE innerLoop            
            
                  DECA
                  BNE outerLoop            
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
          
digit_general:
          LDAA    sevenSegEnabler     ; need to write #$0E to PORTP
          STAA    PTP      ; to enable fourth LED  
          STAB    PORTB
          BSR     delay
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
                                                                                
 choiceOfDigits:    
          LDAB    #$06    ; load accumulator B with value to be displayed
          
          JSR readFromButton
          
          LDAA    port_h_value
          STAA    sevenSegEnabler
          
          JSR    digit_general
          
                                                
          BRA     choiceOfDigits	   ; loop back to beginning
                                                   
  
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
          ORG   $FFFE
          DC.W  Entry      ; reset Vector