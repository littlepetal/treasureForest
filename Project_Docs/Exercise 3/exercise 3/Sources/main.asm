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
test        fcc "testing"
inpstr rmb  $300







; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
             
            
      
mainLoop:                      
            movb #156,SCI1BDL
            movb #00,SCI1BDH
            movb #%00001100,SCI1CR2
            
start:      ;inputting and storing the string
            ;movb #%00000000,SCI1CR2
            movb #%00000100,SCI1CR2
            ldx #inpstr
            jsr getcSCI0
            ldab #$0D
            stab x
            
            
            ;delaying the output
            ldab #100
            jsr   delay
           
            ;outputting a string at once per second
            ;movb #%00000000,SCI1CR2
            movb #%00001000,SCI1CR2
            LDX   #inpstr
            jsr   putcSCI0     
         
            bra start       
                            


putcSCI0    
            ldab x
            ldaa #$0D
            sba
            beq return
            brclr SCI1SR1,#mSCI1SR1_TDRE,* 
            movb x,SCI1DRL          
            inx     
            bra putcSCI0
return
            brclr SCI1SR1,#mSCI1SR1_TDRE,* 
            movb #$0D,SCI1DRL
            rts 
            


delay          
out_loop     ldx #60000 ;
inner_loop 
             dbne x,inner_loop
             dbne b,out_loop
             rts 
  
            

getcSCI0    
            brclr SCI1SR1,#mSCI1SR1_RDRF,* 
            ldab SCI1DRL
            ldaa #$0D
            sba
            beq return2
            stab x
            inx 
            bra getcSCI0
return2
            rts 
            

             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
