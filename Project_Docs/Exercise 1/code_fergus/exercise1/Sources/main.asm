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


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
            ldx #1
            ldx #1
            ldaa #1
            ldaa #1
            staa $1000            
            staa $1001
            ldab #0
            stab $1002
            stab $1003 
            clra
            clrb 
           
            LDX   #$86 
            stx   $1500            
            
            ldab #0
            stab $2000
             
str         fcc "This is an error" 
                
            
            
               
Charloop:              
            ;load the current string value perform ops
           ldy str+$2000
           sty $2100 
           ldaa $2100
           
           ;test if next character would be valid
           inc $2000
           ldx str+$2000
           stx $2200
           ldaa $2200
           SBA
           bne Charloop
           

 
          
          
           
            
            

