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

str         fcc "string"
            fcb $0d

inpstr rmb  $300
numbers rmb $100
terminating_character  fcb $0d



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
            jsr processstring

Storenumeric: 
            LDY #numbers
            LDX #inpstr
            jsr numbering
            jsr sevenseg          

            
transmit:           
            ;Sub-routine for outputting the string 
            ;jsr TE     
         
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
            LDAA  #1              ;0 for all caps, 1 for space to upper
            LDAB  #0
            sba
            ;BGT Capspace
            ;BEQ allToUpper
            ;bra allToUpper        
           ;bra   allToLower
           bra fullspace
                      
           
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

                       
 sevenseg:
           ;enter code here
           rts                    


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