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
str         fcc "abcde!" 

function_on ds 1
;isletter:   ds $3000

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts



;set initial conditions
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
            
            ;load ' ' 
            ldaa #32
            staa $1700
            
            ;load . 
            ldaa #46
            staa $1800
            
            ;load str as index 
            ldx #str           
           
            ;enter char loop
            bsr charloop
            clra
            clrb 
            bra mainLoop
            
            
;looping through each char
charloop:  
            ;load current letter into the accumulator        
            ldaa x       
            staa $1500 ;original value
            staa $3500 ;modified value

            
            ;perform operations 
            ;check the current chacter is a letter      
            bsr checklet
action:  
            ;complete action on the char - given it is a letter
            bsr checkupper
            bsr convupper
 
            
            

            
            
            
            ;terminate or continue string loop       
            ;compare with fixed value
skipaction:
            ;restore this variable
            ldaa $3500
            staa x
            inx
            
            ;return to end of loop
            ldaa $1500
            ldab $1600
            sba
            bne charloop 
            rts




            
;check if the char is a letter 
checklet:     ;check for 32 and 46 binary
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
         

;check if the current char is upper or lower case            
checkupper:
             ;65-90 upper 97-122 lower
             
             ;compare current char to be upper or lower
             ldaa $1500
             ldab #95
             sba
             bge islower
             ble isupper
islower:      
             ldaa #0
             staa $3000
             bra return
isupper:
             ldaa #1
             staa $3000
             bra return
return:             
             ;return to char actions
             rts           
           

;convert all to upper
convupper:
            ldaa $1500
            ldab $3000
            tstb
            bgt skipupper
            ldab #32
            sba
            staa $3500
skipupper:  
            rts
            

                  
          
           
            
            

