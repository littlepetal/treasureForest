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
terminating_character  fcb $0d

space_store ds.B 1
fullstop_store ds.B 1
function_on ds 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts


mainLoop: 
Charmanipulation:
            ldx #inpstr ;load the address on the string to register x
            ldaa #1
            staa space_store    ;set these flags to 1 to capitalise the first letter of each word for ex 1.3 and 1.4
            staa fullstop_store ;
            jsr processstring   ;jump to subroutine which handles the string
            bra mainLoop
            stop                ;end the program when the manipulation is done 
                    ;
            

                   

;############
;exercise 1
;############

;check letter validity
processstring:         ;loop through each letter and apply the required operation
                   
            LDAB  0, x  ;load the first bit of x
            CMPB  terminating_character  ;compare this with terminating character
            BEQ   terminate  ;if end of stirng terminate
keepProcessing:                   
            TBA
            SUBA #65   ;check if ascii code is less than 65, if yes, move on to next char
            BLT  nextchar
                
            TBA
            SUBA #90                           
            BLT  validchar  ;uppercase
                  
            TBA
            SUBA #97         ;less than 97 invalid
            BLT  nextchar
                  
            TBA
            SUBA #122        ;more than 122 invalid
            BGE  nextchar
                                
            BRA validchar    ;else lower
validchar: ;if the char is valid perform operation     
            ;bra allToUpper      ;upper
            ;bra   allToLower    ;lower
            bra fullspace        ;captical after full space
            ;bra capspace        ; captialize every word
                              ;
nextchar:   ;in not alpha char, or operaction already performed, move to the next char

    fullstopcheck: ;before moving check if fullstop and store
            LDAB x
            TBA
            SUBA #46
            BNE spacecheck
            ldab #1
            stab fullstop_store
            inx
            bra processstring
                  
            
    spacecheck:  ;before moving check if space and store
            LDAB x
            TBA
            SUBA #32
            BNE skip  
            ldaa #1
            staa space_store
            inx
            bra processstring
    
    ;else skip and move to next char  
    skip:       
            ldaa #0
            staa space_store   ;set fullstop and space flags to zero
            staa fullstop_store  
            inx
            bra processstring  ;loop back to next char manipulations

terminate: ;terminate reached if required
            rts
                   
               
                
                        
;functions
allToUpper:
            ldab x
            TBA
            SUBA #90
            BLE  storechar  ;if less than 90 must be upper given valid char, therefor skip manipulation
            SUBB #32        ;else must be lower, subtract 32
storechar:
            stab x  ;store value in memory location
            BRA nextchar
            

allToLower:
            ldab x
            TBA
            SUBA #90
            BGT  storechar2   ;if greater than 0 must be lower, therefor skip manipulation
            ADDB #32          ;add 32 to make lower
storechar2:
            stab x  ;store in memory location
            BRA nextchar
            

Capspace 
           
           ldaa x
           ldab #1
           subb space_store ;check the value of space flag
           BEQ allToUpper   ;if it set, make sure the letter becomes upper case
           BGT allToLower   ;if not set, must be lower case
           
            
fullspace
          ;capitalise the first letter
          ldaa x
          ldab #1
          subb space_store     ;check the space flag
          BGT allToLower       ;if not set, fullstop must not be set either hence go to lower
          ldab #1
          subb fullstop_store  ;check fullstop flag
          BEQ allToUpper       ;if set go to upper function
          BGT allToLower       ;else go to lower
 
 




                   



            
            

