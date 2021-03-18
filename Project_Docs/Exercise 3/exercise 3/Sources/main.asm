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
            fcb $0d

inpstr rmb  $300


;brclr SCI1SR1,#mSCI1SR1_TC,*




; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
             
            
      
mainLoop:                      
            ;movb #$00,SCI1BDH
            ;movb #156,SCI1BDL  
            ;movb #%00001100,SCI1CR2
            
start:      
            ;inputting and storing the string
            jsr RE
   
            ;delaying the output
            ldab #100
            jsr   delay
           
            ;outputting a string at once per second
            jsr TE     
         
            bra start       
                            
RE

            movb #$00,SCI1BDH
            movb #156,SCI1BDL
            movb #%00000100,SCI1CR2
            ldx #inpstr
            ldy #$1500  
getcSCI0  
            
            brclr SCI1SR1,#mSCI1SR1_RDRF,* 
            
            ldab SCI1DRL
            ldaa #$0D
            sba
            beq return2
            stab x
            stab y
            iny
            inx 
            bra getcSCI0
return2
            ldab #$0D
            stab x
            stab y
            rts           
            
            



TE
            movb #$00,SCI1BDH
            movb #156,SCI1BDL
            movb #%00001000,SCI1CR2
            LDX   #inpstr             

putcSCI0    
            brclr SCI1SR1,#mSCI1SR1_TDRE,*        
            movb x,SCI1DRL
            ldab x
            ldaa #$0D
            sba
            beq return                     
            inx     
            bra putcSCI0
return
            brclr SCI1SR1,#mSCI1SR1_TC,*
            rts 
            




delay          
out_loop     ldx #60000 ;
inner_loop 
             dbne x,inner_loop
             dbne b,out_loop
             rts 
  
            

 
            

             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
