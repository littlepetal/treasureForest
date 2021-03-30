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

inpstr         fcc "string"
            fcb $0d

;inpstr rmb  $300


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
             
            
      
mainLoop:                      
            ;Set the baud rate at 9600
            movb #$00,SCI1BDH
            movb #156,SCI1BDL
            movb #%00001100,SCI1CR2       ;Enable transmitting bit and receiving   
            
start:      
            ;Sub-routine for inputting and storing the string
            ;jsr RE
   
            ;Sub-routine for delaying the output
            ldab #80
            jsr   delay
           
            ;Sub-routine for outputting the string 
            jsr TE     
         
            ;Always brnach to the start
            bra start       
                            



RE
            ldx #inpstr ;load the address of the reserved memory  
getc  
            
            brclr SCI1SR1,#mSCI1SR1_RDRF,*  ;Only branch when RDRF bit is 1          
            ldab SCI1DRL ;Load data into reg b
            ldaa #$0D
            sba
            beq return2  ;Return if carrage char
            stab x       ;Else store data in reserved memory
            inx 
            bra getc     ;Continue for remaining char
return2
            ldab #$0a    ;Store newline char in reserved memory
            stab x
            inx
            ldab #$0D    ;Store carrage char in reserved memory
            stab x
            rts           
            
           
;transmit char
TE
            LDX   #inpstr              ;load the address of the reserved memory  

putc    

            brclr SCI1SR1,#mSCI1SR1_TDRE,* ;Only branch when TDRE bit is 1       
            movb x,SCI1DRL                 ;Move char at reserved memory address to SCI1 data reg
            ldab x
            ldaa #$0D
            sba
            beq return                    ;Return in Carrage char 
            inx     
            bra putc                      ; Else go to next Character
return
            ;brclr SCI1SR1,#mSCI1SR1_TC,*  ;Only return when transmission complete
            rts 
            




delay          
out_loop     
             ldx #60000 ;1 cycle
inner_loop 
             ;ldy $4000
             dbne x,inner_loop  ;3 cycles
             dbne b,out_loop    ;3 cycles
             rts 
  
            

 
            

             
            
            
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
