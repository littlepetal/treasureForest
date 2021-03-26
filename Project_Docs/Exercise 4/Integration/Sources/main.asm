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

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1

;definitions for ex 1
str         fcc "string"
            fcb $0d

;definitions for ex 3
inpstr rmb  $300
numbers rmb $100
;numbers fcc "123456789"
terminating_character  fcb $0d

;definitions for ex2
ascii_value  DS.B 1   ; allocate one byte for the ascii value
output_digit  DS.B 1  ; allocate one byte for the output digit
length_count  DS.B 1
seven_seg_code DS.B 10 
;terminating_character  FCC ""
digits_string  FCC "0123456789"
               FCB $0D
               
port_h_value  DS.B  1
long_delay  DS.W  1




;############
;main
;############
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
             
            
      
mainLoop:                      
            ;Set the baud rate at 9600
            clr PORTB
            movb #$00,SCI1BDH
            movb #156,SCI1BDL  
            movb #%00001100,SCI1CR2 ;Enable transmitting bit and receiving 
            
start:      
            ;Sub-routine for inputting and storing the string
            
receive:            
            jsr RE
   
            ;Sub-routine for delaying the output
            ldab #100
            jsr   delay
            
Charmanipulation:
            ldx #inpstr
            ldaa #1
            staa $4500
            staa $4501
            ;jsr processstring

Storenumeric: 
            LDY #numbers
            LDX #inpstr
            jsr numbering
                      

            
transmit:           
            ;Sub-routine for outputting the string 
            ;jsr TE     
            jsr sevenseg
            ;Always brnach to the start
            bra start  
            
            

                   

;############
;exercise 1
;############

;check letter validity
processstring:         ;loop through each letter and apply the required operation
                   
            LDAB  0, x            
            CMPB  terminating_character
            BEQ   terminate
keepProcessing:                   
            TBA
            SUBA #65                           ;check if ascii code is less than 65, if yes, move on to next char
            BLT  nextchar
                
            TBA
            SUBA #90                           
            BLT  validchar
                  
            TBA
            SUBA #97                           
            BLT  nextchar
                  
            TBA
            SUBA #122                         
            BGE  nextchar
                                
            BRA validchar  
validchar:
            
            ;need to come up with a way to do port h as input 
            LDAA PTH 
            staa $2000                             
            LDAA  #0              ;0 for all caps, 1 for space to upper
            LDAB  #0
            sba
            BGT Capspace
            BEQ allToUpper
            ;bra allToUpper        
           ;bra   allToLower
           ;bra fullspace
                      
           
;test if spce char                   ;
nextchar:   

    fullstopcheck:
            LDAB x
            TBA
            SUBA #46
            BNE spacecheck
            ldab #1
            stab $4501
            inx
            bra processstring
                  
            
    spacecheck:
            LDAB x
            TBA
            SUBA #32
            BNE skip  
            ldaa #1
            staa $4500
            inx
            bra processstring
    
    ;else skip                        
    skip:       
            ldaa #0
            staa $4500
            staa $4501  
            inx
            bra processstring                   

terminate:        
            rts
                   
               
                
                        
;functions
allToUpper:
            ldab x
            TBA
            SUBA #90
            BLE  storechar           
            SUBB #32
storechar:
            stab x                        
            BRA nextchar
            



allToLower:
            ldab x
            TBA
            SUBA #90
            BGT  storechar2            
            ADDB #32
storechar2:
            stab x 
            BRA nextchar
            



Capspace 
           
           ldaa x
           ldab #1
           subb $4500
           BEQ allToUpper
           BGT allToLower
           
            
fullspace
          ;capitalise the first letter
          ldaa x
          ldab #1
          subb $4500
          BGT allToLower
          ldab #1
          subb $4501 
          BEQ allToUpper
          BGT allToLower
 
 
 ;delay
delay          
out_loop     
             ldx #60000 ;1 cycle
inner_loop 
             ldy $4000
             dbne x,inner_loop  ;3 cycles
             dbne b,out_loop    ;3 cycles
             rts            




 ;###########
 ;exercise 2
 ;###########
 numbering:     
            LDAA x
            suba #$0d
            BEQ terminating
            ldaa x
            SUBA #48
            BLE next
            ldaa x
            SUBA #57
            BGT next
            ldaa x  ;else it is a number
            staa y
            iny
 next:
            inx
            bra numbering 
 terminating:
            LDAA #$0d
            STAA y           
            rts  


;seven seg main code                       
 sevenseg:
           ;enter code here
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
            ;JSR     checkLength
          
            ;BRA     staticFourDigits
            ;BRA     asciiToDigitOutput
            jsr     scroll  
            
            ;LDX    #digits_string
            ;BRA    moving
            ;JSR     readFromButton
            ;JSR     moving
             rts                    

;static 4 digits function
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

;ascii supporting function          
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
                    
moving:
          LDX     #digits_string
          
          loopmove:
          
          JSR     asciiToDigitOutput 
          
          INX
          
          LDAB    0, x
          SUBB    #13
          BEQ     moving 
                   
          BRA     loopmove         
          
readFromButton:
          LDAA    PTH
          STAA    port_h_value
          RTS           

;scrolling function          
scroll:
          LDX     #numbers
          
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
scrollend:
                  clr PORTB 

                  rts
                  
          restart:
                  LDY     #200
                  STY     long_delay
                  
                  INX
                  
                  LDAB    0, x
                  SUBB    #13
                  ;BEQ     scroll
                  BEQ     scrollend 
                  
                  LDAB    1, x
                  SUBB    #13
                  BEQ     scrollend
                  
                  LDAB    2, x
                  SUBB    #13
                  BEQ     scrollend 
                  
                  LDAB    3, x
                  SUBB    #13
                  BEQ     scrollend                  
                                   
                  BRA     loop        

delay2:                     ; keeps the current display lit for approx. 0.5ms
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

;seven seg supporting table          
digit_0:
          LDAA    #$07     ; need to write #$07 to PORTP
          STAA    PTP      ; to enable first LED
          STAB    PORTB
          BSR     delay2
          RTS

digit_1:
          LDAA    #$0B     ; need to write #$0B to PORTP
          STAA    PTP      ; to enable second LED
          STAB    PORTB
          BSR     delay2
          RTS
          
digit_2:
          LDAA    #$0D     ; need to write #$0D to PORTP
          STAA    PTP      ; to enable third LED
          STAB    PORTB
          BSR     delay2
          RTS
          
digit_3:
          LDAA    #$0E     ; need to write #$0E to PORTP
          STAA    PTP      ; to enable fourth LED  
          STAB    PORTB
          BSR     delay2
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
                
initialise_seven_seg_code:             ; redundant
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





;##################
;Exercise 3
;##################            

;receive char
RE
            ;movb #%00000100,SCI1CR2 ;Enable receiving bit
            ldx #inpstr ;load the address of the reserved memory  
getc  
            
            brclr SCI1SR1,#mSCI1SR1_RDRF,*  ;Only branch when RDRF bit is 1          
            ldab SCI1DRL ;Load data into reg b
            ldaa #$0D
            sba
            beq return2  ;Return if carrage char
            stab x       ;Else store data in reserved memory
            inx 
            bra getc     ;Continue for remaining char
return2
            ldab #$0a    ;Store newline char in reserved memory
            stab x
            inx
            ldab #$0D    ;Store carrage char in reserved memory
            stab x
            rts           
            
           
;transmit char
TE
            LDX   #inpstr              ;load the address of the reserved memory  

putc    
            brclr SCI1SR1,#mSCI1SR1_TDRE,* ;Only branch when TDRE bit is 1       
            movb x,SCI1DRL                 ;Move char at reserved memory address to SCI1 data reg
            ldab x
            ldaa #$0D
            sba
            beq return                    ;Return in Carrage char 
            inx     
            bra putc                      ; Else go to next Character
return
            ;brclr SCI1SR1,#mSCI1SR1_TC,*  ;Only return when transmission complete
            rts 
            



             
             
                     
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector