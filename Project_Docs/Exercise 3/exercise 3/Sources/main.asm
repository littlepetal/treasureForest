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

     ; enable transmitter and receiver
            LDX   #str
            movb #156,SCI1BDL
            movb #00,SCI1BDH
            ;movb #$4C,SCI1CR1 
            ;movb #%00011100,SCI1CR1
            ;movb #%00000000,SCI1CR1 
            
            ldaa #100
            ;jsr   putcSCI0
            
            ;jsr   delay
            jsr   getcSCI0
            ;jsr putchar
            ;jsr getchar
            bra mainLoop       
                            


putcSCI0    
            movb #%00001000,SCI1CR2
            brclr SCI1SR1,#mSCI1SR1_TDRE,* 
            movb #85,SCI1DRL
            ldab SCI1DRL
            stab $1500
            rts 
            


delay          
            
            ldab #100
inner       
            decb
            bne inner
            
            deca
            bne delay
            rts
  
            

getcSCI0    
            movb #%00000100,SCI1CR2
            brclr SCI1SR1,#mSCI1SR1_RDRF,* 
            ldab SCI1DRL
            stab x
            inx
            rts
            

             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
