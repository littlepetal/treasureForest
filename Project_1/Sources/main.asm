
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


;definitions for ex 1
str         fcc "string"
            fcb $0d

;definitions for ex 3
inpstr rmb  $300            ; memory reserved for string
numbers rmb $100            ; memory reserved for numbers
terminating_character  fcb $0d

;definitions for ex2
ascii_value  DS.B 1   ; allocate one byte for the ascii value
output_digit  DS.B 1  ; allocate one byte for the output digit
length_count  DS.B 1
seven_seg_code DS.B 10 
digits_string  FCC "0123456789"
               FCB $0D               
port_h_value  DS.W  1
long_delay  DS.W  1
wasSpace  DS.B  1




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
            clr PORTB                     ; turn all seven segs off
            movb #$00,SCI1BDH             ; Set the baud rate at 9600
            movb #156,SCI1BDL  
            movb #%00001100,SCI1CR2       ;Enable transmitting bit and receiving 
            
start:      
            
receive:            
            jsr RE         ; received subroutine
               
            ldab #100
            jsr   delay     ;Sub-routine for delaying the output
            
Charmanipulation:
            ldx #inpstr      ; load input string to register x           
            ldaa #1
            staa wasSpace       ; setting the space flag to 1 for the first word
            jsr processstring     ; jump to string manipulations 

Storenumeric: 
            LDY #numbers       ; load numerical characters only string to register y
            LDX #inpstr        ; load input string to register x 
            jsr numbering      ; subroutine for storing numerical characters               
                                        
transmit:                        
            jsr TE             ;Sub-routine for outputting the string
            
                 
            jsr sevenseg       ;Sub-routines for seven seg outputs
            
            bra start            ;Always brnach to the start
            
            

                   

;############
;exercise 1
;############

processstring:                     
            LDAB  0, x                          ; load pointer to fisrt char of inpstr to register B
            CMPB  terminating_character         ; compare register B to ascii value for carriage return 
            BEQ   terminate
keepProcessing:                   
            TBA
            SUBA #65                           ;check if ascii code is less than 65, if yes, move on to next char
            BLT  nextchar
                
            TBA
            SUBA #90                           ;check if ascii code is less than 90, if yes, move on to valid char
            BLT  validchar
                  
            TBA
            SUBA #97                            ;check if ascii code is less than 97, if yes, move on to next char
            BLT  nextchar
                  
            TBA
            SUBA #122                          ;check if ascii code is greater than 122, if yes, move on to next char
            BGE  nextchar
                                
            BRA validchar  
validchar:
            JSR readFromButton                             
            brclr port_h_value,#%10000000,default       ; mask compare port H value to 10000000
            bra Capspace
default:           
            bra allToUpper        
                                      ;
nextchar:   

                             
    spacecheck:                           ; before moving onto next character check if current character is space
            LDAB x
            TBA
            SUBA #32
            BNE skip  
            ldaa #1
            staa wasSpace                   ; if yes then set wasSpace flag to 1, increment x and move to next char  
            inx
            bra processstring
    
    ;else skip                        
    skip:       
            ldaa #0
            staa wasSpace                   ; if no then set wasSpace flag to 0, increment x and move to next char 
            inx
            bra processstring                   

terminate:        
            rts
                                  
                        
;functions
allToUpper:
            ldab x
            TBA
            SUBA #90                           ; if ascii value is less than 90, then it is already an upper case, store character
            BLE  storechar           
            SUBB #32                           ; else subtract 32
storechar:
            stab x                             ; store character and move onto next character
            BRA nextchar
            



allToLower:
            ldab x
            TBA
            SUBA #90                          ; if ascii value is greater than 90, then it is already a lower case, store character
            BGT  storechar2            
            ADDB #32                          ; else add 32
storechar2:
            stab x                            ; store character and move onto next character
            BRA nextchar

Capspace      
           ldaa x
           ldab #1
           subb wasSpace                     ; check if wasSpace flag is 1
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
 numbering:                              ; if the character is numerical, store it into numbers variable
            LDAA x
            suba #$0d
            BEQ terminating               ; if current character is carriage return, terminate
            ldaa x                        
            SUBA #48                      ; if ascii value is between 48 and 57, store in numbers, else skip character
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
 
          LDX  #numbers
          ldaa x
          ldab #$0D
          SBA
          BEQ  returnsev           ; if first character is return, skip seven seg function (if no numbers are stored, we skip seven seg)
           
            LDAA    #$FF
            STAA    DDRB          ; configure PORTB as output
            STAA    DDRJ          ; configure PORTJ as output
            STAA    DDRP          ; configure PORTP as output
            LDAA    #00     
            STAA    PTJ           ; write 0 to J0 to enable LEDs
            STAA    DDRH          ; configure PORTH as input
            
            LDY     #200
            STY     long_delay
          
            JSR     scroll  
            
returnsev:            
             rts                           

;scrolling function          
scroll:
          LDX  #numbers                                  ; load numurical string to register x
          ldaa x
          ldab #$0D                                      ; check for carriage return
          SBA
          BEQ  scrollend
          
          loop:                                          ; display the digits at the 0, 1, 2 and 3 offsets of x in the four seven segs
                  LDAA    0, x
                  
                  STAA    ascii_value                    ; store the ascii value to be converted and displayed into register A
                  JSR     getSevenSegCode                ; convert ascii to seven seg representaion
                  JSR     digit_0                        ; light up righter most seven seg with the required digit

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
                  DEY                                   ; decrement number of iterations left
                                          
                  
                  BEQ     restart
                  
                  STY     long_delay                  
    

                  BRA     loop
scrollend:
                  clr PORTB                             ; turn off all seven segs

                  rts
                  
          restart:                                     ; move on to the next set of four digits and restart seven seg display
                  LDY     #200
                  STY     long_delay
                  
                  INX
                  
                  LDAB    0, x
                  SUBB    #13
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
                  
                  innerLoop:
                          DEY            
                          BNE innerLoop            
            
                  DECA
                  BNE outerLoop            
          RTS	
  

;seven seg supporting table          
digit_0:
          LDAA    #$07     ; need to write #$07 to PORTP
          STAA    PTP      ; to enable first LED
          ;
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
                                           ; match decimal value to seven seg code
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
                 
readFromButton:
          LDAA    PTH
          STAA    port_h_value
          RTS           
                                                                    
                                                  
;##################
;Exercise 3
;##################            

;receive char
RE
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