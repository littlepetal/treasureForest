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
inpstr      fcc "a. bc. de!" 
            fcb $0d
terminating_character  fcb $0d

function_on ds 1
;isletter:   ds $3000

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop: 


Charmanipulation:
            ldx #inpstr
            ldaa #1
            staa $4500
            staa $4501 
            jsr processstring
            bra mainLoop 
            

                   

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
            ;bra Capspace
            ;rts Capspace
            ;bra allToUpper
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
 
 




                   



            
            

