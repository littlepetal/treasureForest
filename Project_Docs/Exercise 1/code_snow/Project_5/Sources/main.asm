            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
; Insert here your data definition.
output_string   DS.B  32     ; allocate 16 bytes at the address output_string
input_string    FCC   "Hello. this is A sentence. "  ; make a string in memory
terminating_character  FCC ""
length_count    DS.B  1     ; one byte to store the string length
function_code   DS.B  1     ; one byte to mark the required function


; code section
            ORG   ROMStart


Entry:
_Startup:
            ;LDS   #RAMEnd+1                         ; initialize the stack pointer

            ;CLI                                     ; enable interrupts
mainLoop:
            LDAA  #0
            
            LDX   #input_string                      ; load pointer to first char of input string to x
            LDY   #output_string                     ; load pointer to first byte of memory for output string to y
            
            JSR checkLength                          ; potentially redundant
            
            LDX   #input_string                      ; reset x to point to start of string
            
            applyOperationToLetters:                 ; loop through each letter and apply the required operation
                   ;LDAA  length_count
                   LDAB  0, x
                   PSHB      
                                          
                   JSR checkIfTerminate              ; check if it is the end of the string                  
                   JSR checkIfAlpha                                      
                   JSR applyRequiredFunction         ; apply the required function               
                                                                
            moveToNextChar:
                   STAB 1, y+                        ; stored converted letter into y
                   INX                               ; shift x to point to the next character
                   BRA applyOperationToLetters

checkIfTerminate:    
            CMPB  terminating_character
            BEQ   exit
            RTS           
            
checkLength:
            LDAB  1, x+
            CMPB  terminating_character
            BEQ   finishLengthCount            
            INCA
            STAA  length_count
            BRA checkLength
            
            finishLengthCount:
                   RTS        
            
checkIfAlpha:
            ;TBA
            ;SUBA #32
            ;JSR  space
            ;TBA
            ;SUBA #46
            ;JSR  fullStop
            
            TBA
            SUBA #65                                 ; check if ascii code is less than 65, if yes, move on to next char
            BLT  moveToNextChar
            
            TBA
            SUBA #122                                ; check if ascii code is greater than 65, if yes, move on to next char
            BGE  moveToNextChar
            
            TBA                                      ; need to write condition to eliminate some more non letters
            RTS                                    
            
applyRequiredFunction:                               ; determines which function we are using
            ;LDAA  function_code
            ;DECA
            ;BEQ   allToUpper
            ;DECA  
            ;BEQ   allToLower
            ;DECA 
            ;BEQ   properGrammar
            
            ;BRA allToUpper
            ;BRA allToLower
            BRA properGrammar         
            
allToUpper:
            TBA
            SUBA #90
            BLE  moveToNextChar
            
            SUBB #32
            RTS
            
allToLower:
            TBA
            SUBA #90
            BGT  moveToNextChar
            
            ADDB #32
            RTS
            
properGrammar:
            PULB
            SUBB #32
            BEQ potentialStart 

            BRA moveToNextChar
            
potentialStart:
            PULB
            SUBB #46
            BEQ definiteStart
            
            RTS
            
definiteStart:
            JSR allToUpper
            RTS
                                   
exit: 
            END
                     
  
  
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector