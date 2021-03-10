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
str         fcc "a.!" 

function_on ds 1
;isletter:   ds $3000

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

            ldaa #1
            ldaa #1
            staa $1000            
            staa $1001
            ldab #0
            stab $1002
            stab $1003 
            clra
            clrb 
           
           ;load breaking character
            LDAA   #$21 
            staa   $1600 ; breaking char
            
            ;load full stop 
            ldaa #32
            staa $1700
            
            ;load white space 
            ldaa #46
            staa $1800
            
            ;load str as index 
            ldx #str           
           
            ;enter char loop
            bsr charloop
            clra
            clrb 
            bra mainLoop


charloop:  
            ;load current letter into the accumulator        
            ldaa 1,x+
            staa $1500
            ldy $1500
            
            ;perform operations 
            ;check the current chacter is a letter      
            bsr checklet
action:  
            ;if a space or full stop is found, zero flag is raised
            
            
            ;terminate or continue string loop       
            ;compare with fixed value

skipaction:
            ldaa $1500
            ldab $1600
            sba
            bne charloop 
            rts





            
 
checklet:     ;65-90 97-122 but check for 32 and 46
              ;check full .
              ldaa $1500
              ldab $1700
              sba
              staa $1900 
              BEQ skipaction
              
              ;check white space
              ldaa $1500
              ldab $1800
              sba 
              staa $2000
              BEQ skipaction
              
             ;return 
             rts                  
         
            
           
           

 
          
          
           
            
            

