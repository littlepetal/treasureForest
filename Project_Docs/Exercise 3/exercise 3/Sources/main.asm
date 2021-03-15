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





; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

            movb #156,SCI0BDL
            movb #$00,SCI0BDH
            movb #$4C,SCI0CR1       ; 8 bits and address wake up
            movb #$0C,SCI0CR2       ; enable transmitter and receiver
            LDX   #str
            ldaa  x
            jsr   putcSCI0
putcSCI0    brclr SCI0SR1,#128,* ; wait for TDRE to be set
            staa SCI0DRL
            rts  

getcSCI0    brclr SCI0SR1,#128,* ; wait until RDRF bit is set
            ldab SCI0DRL ; read the character
            rts
             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
