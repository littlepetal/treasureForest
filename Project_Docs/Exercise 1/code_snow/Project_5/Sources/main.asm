            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
; Insert here your data definition.
output_string   DS.B  32     ; allocate 16 bytes at the address output_string
input_string    FCC   "a #StrIng."  ; make a string in memory
terminating_character  FCC ""
length_count    DS.B  1     ; one byte to store the string length
function_code   DS.B  1     ; one byte to mark the required function

;function_code EQU #4



; code section
            ORG   ROMStart


Entry:
_Startup:
            ;LDS   #RAMEnd+1       ; initialize the stack pointer

            ;CLI                     ; enable interrupts
mainLoop:
            LDAA  #0
            
            LDX   #input_string             ;load pointer to first char of input string to x
            LDY   #output_string           ;load pointer to first byte of memory for output string to y
            
            BRA checkLength                ;potentially redundant
            finishLengthCount:
            
            LDX   #input_string    ;reset x to point to start of string
            
            applyOperationToLetters:         ;loop through each letter and apply the required operation
                   ;LDAA  length_count
                   LDAB  0, x
            
                   BRA checkIfTerminate            ;check if it is the end of the string
                   keepProcessing:
                   
                   BRA checkIfAlpha
                   yesAlpha:
                   
                   ;apply the required function
                   BRA applyRequiredFunction
               
                                             
                   ;BRA applyOperationToLetters
                   
            moveToNextChar:
                   STAB 1, y+                  ;stored converted letter into y
                   INX                         ;shift x to point to the next character
                   BRA applyOperationToLetters

checkIfTerminate:    
            ;LDAB  0, x
            CMPB  terminating_character
            BEQ   exit
            BRA keepProcessing            
            
checkLength:
            LDAB  1, x+
            CMPB  terminating_character
            BEQ   finishLengthCount
            INCA
            STAA  length_count
            BRA checkLength
            
checkIfAlpha:
            TBA
            SUBA #65                           ;check if ascii code is less than 65, if yes, move on to next char
            BLT  moveToNextChar
            
            TBA
            SUBA #122                          ;check if ascii code is greater than 65, if yes, move on to next char
            BGE  moveToNextChar
            
            TBA                                 ;need to write condition to eliminate some more non letters
            
            BRA yesAlpha                        
            
            
applyRequiredFunction:             ;determines which function we are using
            ;LDAA  function_code
            ;DECA
            ;BEQ   allToUpper
            ;DECA  
            ;BEQ   allToLower
            ;DECA 
            ;BEQ   properGrammar
            
            BRA allToUpper
            ;BRA allToLower         
            
allToUpper:
            TBA
            SUBA #90
            BLE  moveToNextChar
            
            SUBB #32
            BRA moveToNextChar
            
allToLower:
            TBA
            SUBA #90
            BGT  moveToNextChar
            
            ADDB #32
            BRA moveToNextChar
            
properGrammar:
            BRA moveToNextChar
                       
            
exit: 
            END
                     
  
  
;possibly we don't need to count the characters

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector