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
cr          fcb  $0D
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
            
            ;inputting and storing the string
            ldx #inpstr
            jsr getcSCI0
            
            ;delaying the output
            ldab #100
            jsr   delay
           
            ;outputting a string at once per second
            LDX   #inpstr
            jsr   putcSCI0
       
         
            
         
            bra mainLoop       
                            


putcSCI0    
            movb #%00001000,SCI1CR2
            brclr SCI1SR1,#mSCI1SR1_TDRE,* 
            movb x,SCI1DRL
            ldab x
            ldaa cr
            sba
            beq return
            inx
            bra putcSCI0
return
            rts 
            


delay          
out_loop     ldx #60000 ;
inner_loop 
             dbne x,inner_loop
             dbne b,out_loop
             rts 
  
            

getcSCI0    
            movb #%00000100,SCI1CR2
            brclr SCI1SR1,#mSCI1SR1_RDRF,* 
            ldab SCI1DRL
            stab x
            ldaa cr
            sba
            beq return2
            inx
            bra getcSCI0
return2
            rts 
            

             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
