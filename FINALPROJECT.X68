*-----------------------------------------------------------
* Title      : ECE441 Design Project Part 1
* Written by : Nicholas Velcich
* Date       : JAN 03 2019
* Description:
*-----------------------------------------------------------
    
    
    
    ORG $900
    MOVE.L  $A00000,D0
    ;DIVU    D0,D7
    
BUS_ERR:
    MOVEM.L D0-D7/A0-A7,-(A7)
    LEA MSG_BUS_ER,A5
    LEA MSG_BUS_ER_ED,A6
    BSR PRINT
    BSR BA_ER_PRINT
    MOVEM.L (A7)+,D0-D7/A0-A7
    BSR DF_D
ADRS_ERR:
    MOVEM.L D0-D7/A0-A7,-(A7)
    LEA MSG_ADDR_ER,A5
    LEA MSG_ADDR_ER_ED,A6
    BSR PRINT
    BSR BA_ER_PRINT
    MOVEM.L (A7)+,D0-D7/A0-A7
    BSR DF_D

DIV_ZERO:
    LEA MSG_0_ER,A5
    LEA MSG_0_ER_ED,A6
    BSR PRINT
    BSR DF_D
ILL_INST:
    LEA MSG_ILL_ER,A6
    LEA MSG_ILL_ER_ED,A5
    BSR PRINT
    BSR DF_D
CHK_INST:
    LEA MSG_CHK_ER,A6
    LEA MSG_CHK_ER_ED,A5
    BSR PRINT
    BSR DF_D
PRIV_VIOL:
    LEA MSG_PRIVILEGE_ER,A6
    LEA MSG_PRIVILEGE_ER_ED,A5
    BSR PRINT
    BSR DF_D
LINE_A:
    LEA MSG_LINE_A_ER,A6
    LEA MSG_LINE_A_ER_ED,A5
    BSR PRINT
    BSR DF_D
LINE_F:
    LEA MSG_LINE_F_ER,A6
    LEA MSG_LINE_F_ER_ED,A5
    BSR PRINT
    BSR DF_D
BA_ER_PRINT:
    MOVE.W  $44(A7),D0
    MOVE.L  #2,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.L  $46(A7),D0
    MOVE.L  #4,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.W  $54(A7),D0
    MOVE.L  #2,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT
    RTS
    
    

    ORG    $1000
START:
    MOVE.L  #BUS_ERR,$8
    MOVE.L  #ADRS_ERR,$C
    MOVE.L  #ILL_INST,$10
    MOVE.L  #DIV_ZERO,$14
    MOVE.L  #CHK_INST,$18
    MOVE.L  #PRIV_VIOL,$20
    MOVE.L  #LINE_A,$28
    MOVE.L  #LINE_F,$2C     
    LEA MSG_WELCOME,A5
    LEA MSG_WELCOME_ED,A6
    BSR PRINT
RESET:
    LEA HISTORY_BUFF,A2
    MOVE.B #0,(A2)
    LEA STACK,A7        ;SET(RESET) A7
MAIN:    
    LEA MSG_PROM, A5
    LEA MSG_PROM_ED, A6
    BSR PRINT_C
    BSR INPUT
    BSR INTERPRETER
    BRA MAIN

*------------------SUBROUTINE------------*    
;Standard I/O
;Print WITH carrige return and line feed
;Print string stored within address range marked by A5 and A6
PRINT:
    MOVEM.L D0-D1/A1,-(A7)
    MOVEA.L A5,A1           
    SUBA.L A5,A6            
    MOVE.L A6,D1            
    MOVE.L #0,D0            
    TRAP #15
    MOVEM.L (A7)+,D0-D1/A1
    RTS
;Print WITHOUT carrige return and line feed
;Print string stored within address range marked by A5 and A6
PRINT_C:            
    MOVEM.L D0-D1/A1,-(A7)
    MOVEA.L A5,A1           
    SUBA.L A5,A6            
    MOVE.L A6,D1            
    MOVE.L #1,D0
    TRAP #15
    MOVEM.L (A7)+,D0-D1/A1
    RTS
;Store input string to buffer
;Marked
INPUT:
    MOVEM.L D0-D1/A1,-(A7)
    LEA INPUT_BUFF,A1  ;EVERY WORDS COMES FROM KEYBOARD WILL BE STORED AT BUFF AREA
    MOVE.L #2,D0
    TRAP #15
    ADDA.W D1,A1
    MOVE.B #NULL,(A1)
    CMPI.B #0,D1
    MOVEM.L (A7)+,D0-D1/A1
    RTS

;Determine which command been input and branch accordingly 
INTERPRETER:    
    ;Check if input buffer is empty
    LEA INPUT_BUFF,A1
    CMPI.B #NULL,(A1)
    BEQ INTERPRETER_END
 
    ;Check if it's HELP command
    LEA MSG_CMD_HELP,A5
    LEA MSG_CMD_HELP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP   
    
    ;Block search
    LEA MSG_CMD_BSCH,A5
    LEA MSG_CMD_BSCH_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BSCH

    
    ;Addition
    LEA MSG_CMD_ADD,A5
    LEA MSG_CMD_ADD_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ ADD

    ;And
    LEA MSG_CMD_AND,A5
    LEA MSG_CMD_AND_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE 
    BEQ AND       

    ;Recall Last command
    LEA MSG_CMD_RC,A5
    LEA MSG_CMD_RC_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ RC
    
    ;MEMORY DISPLAY
    LEA MSG_CMD_MDSP,A5
    LEA MSG_CMD_MDSP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MDSP
    
    ;EXIT
    LEA MSG_CMD_EXIT,A5
    LEA MSG_CMD_EXIT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ EXIT
    
    ;MEMORY MANAGMENT
    LEA MSG_CMD_MM,A5
    LEA MSG_CMD_MM_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MM
    
    ;MEMORY SET
    LEA MSG_CMD_MS,A5
    LEA MSG_CMD_MS_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MS
    
    ;BLOCK FILL
    LEA MSG_CMD_BF,A5
    LEA MSG_CMD_BF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BF
    
    ;BLOCK MOVE
    LEA MSG_CMD_BMOV,A5
    LEA MSG_CMD_BMOV_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BMOV
    
    ;DISPLAY REGISTERS
    LEA MSG_CMD_DF,A5
    LEA MSG_CMD_DF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ DF
    
    ;BLOCK TEST
    LEA MSG_CMD_BT,A5
    LEA MSG_CMD_BT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BT
    
    ;GO
    LEA MSG_CMD_GO,A5
    LEA MSG_CMD_GO_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ GO    
    ;Invalid input
    BSR SYNTAX_ER
INTERPRETER_END:    
    RTS

;Compare strong from A1 to NULL or SPACE 
;With string from A5 to A6
COMPARE:                    
    CMPI.B #SPACE,(A1)      ;Check if end of command(SPACE)
    BEQ COMPARE_CHK_END
    CMPI.B #NULL, (A1)
    BEQ COMPARE_CHK_END     ;Check if end of command(NULL)
    CMPI.B #DOT, (A1)
    BEQ COMPARE_CHK_END
    CMPA.L A5,A6
    BEQ COMPARE_END
    CMP.B (A1)+,(A5)+       
    BNE COMPARE_END         ;If content not the same end
    BRA COMPARE
COMPARE_CHK_END:
    CMPA.L A5,A6
COMPARE_END:
    RTS

; Convert HEX num (D0) to ASCII, length in D2 (Bytes) before use
; ASCII string buffer should start from A6
HEX2ASCII:
    MOVEM.L D1/D3, -(A7)
    ROL.L #1,D2
    ADD.L D2, A6
    MOVE.L D2,D3
HEX2ASCII_LOOP:
    MOVE.L D0, D1
    ANDI.L #$0000000F,D1	;Get last digit (4 bits)
    CMPI.B #10,D1			;Compare with 10
    BGE CONVERT_HEX
    ADDI.B #$30,D1			;Convert to 0-9
    JMP STORE_ASCII
CONVERT_HEX:
    ADDI.B #$37,D1			;Convert to A-F
STORE_ASCII:
    MOVE.B D1, -(A6)		;Store to Stack(self defined stack)
    ROR.L #4,D0
    SUBI.B #1, D2			;Count to 0
    BNE HEX2ASCII_LOOP
    ADD.L D3,A6
    MOVEM.L (A7)+, D1/D3
    RTS
    
; Convert ASCII(START FROM A1) to HEX num (Will be storeed in D0) 
; length will be stored in D2
ASCII2HEX:
    MOVEM.L D1,-(A7)
    CLR.L   D2
    CLR.L   D1
    CLR.L   D0
    CMPI.B #DOLLAR, (A1)    ;Get rid of $ first
    BNE ASCII2HEX_LOOP
    ADDA #1,A1
ASCII2HEX_LOOP:
    MOVE.B (A1)+,D1
    CMPI.B #$30,D1     ;0-9
    BLT SYNTAX_ER
    CMPI.B #$39,D1
    BLE ASCII2HEX_NUM 
    CMPI.B #F_ASC,D1  ;A-F
    BGT SYNTAX_ER
    CMPI.B #A_ASC,D1
    BLT SYNTAX_ER
    SUBI.B #$37,D1
    BRA ASCII2HEX_SUM
ASCII2HEX_NUM    
    SUBI.B #$30,D1
ASCII2HEX_SUM
    ROL.L #4,D0    
    ADD.L D1, D0
    ADDQ.B #1,D2
    CMPI.B #SPACE,(A1)  ;If next char is SPACE or NULL end sub routine
    BEQ ASCII2HEX_END   
    CMPI.B #NULL,(A1)
    BEQ ASCII2HEX_END
    BRA ASCII2HEX_LOOP
ASCII2HEX_END
    ADDQ #1,D2          ;CONVERT DIGIT TO BYTE
    BCLR #0,D2
    ROR.L #1,D2    
    MOVEM.L (A7)+,D1
    RTS

;Store input buffer
STORE_HIS:
    MOVEM.L A1/A2,-(A7)
    LEA INPUT_BUFF,A1
    LEA HISTORY_BUFF,A2
STORE_HIST_LOOP:
    CMPI.B #0,(A1)
    BEQ STORE_HIS_END
    MOVE.B (A1)+,(A2)+
    BRA STORE_HIST_LOOP
STORE_HIS_END:
    MOVE.B #0,(A2)
    MOVEM.L (A7)+,A1/A2
    RTS  
  
*----------------COMMAND SUBROUTINE----------------------*
;Help
;Print help messages for each individual debugger command
HELP:
    BSR STORE_HIS 
    LEA MSG_HELP,A5
    LEA MSG_HELP_ED,A6  
    BSR PRINT 
    LEA MSG_CMD_FST,A5
    LEA MSG_CMD_LST,A6  
    BSR PRINT 
HELP_LOOP:
    ;Print help console prompt
    LEA MSG_CMD_HELP,A5
    LEA MSG_CMD_HELP_ED,A6
    MOVE.B #LARGER,(A6)+
    BSR PRINT_C
    
    ;User input command to be displayed
    BSR INPUT
    LEA INPUT_BUFF,A1

    ;Check if buffer is empty
    CMPI.B #NULL,(A1)
    BEQ HELP_LOOP
    
    
    ;Block search
    LEA MSG_CMD_BSCH,A5
    LEA MSG_CMD_BSCH_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BSCH
    
    ;Addition
    LEA MSG_CMD_ADD,A5
    LEA MSG_CMD_ADD_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_ADD

    ;And 
    LEA MSG_CMD_AND,A5
    LEA MSG_CMD_AND_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_AND
    
    ;Recall last command
    LEA MSG_CMD_RC,A5
    LEA MSG_CMD_RC_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_RC
    
    ;MEMORY DISPLAY
    LEA MSG_CMD_MDSP,A5
    LEA MSG_CMD_MDSP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MDSP
    
    ;EXIT COMMAND
    LEA MSG_CMD_EXIT,A5
    LEA MSG_CMD_EXIT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_EXIT_MSG
    
    ;MEMORY MODIFY
    LEA MSG_CMD_MM,A5
    LEA MSG_CMD_MM_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MM_MSG
    
    ;MEMORY SET
    LEA MSG_CMD_MS,A5
    LEA MSG_CMD_MS_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MS_MSG
    
    ;BLOCK FILL
    LEA MSG_CMD_BF,A5
    LEA MSG_CMD_BF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BF_MSG
    
    ;BLOCK MOVE
    LEA MSG_CMD_BMOV,A5
    LEA MSG_CMD_BMOV_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BMOV_MSG
    
    ;BLOCK TEST
    LEA MSG_CMD_BT,A5
    LEA MSG_CMD_BT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BT_MSG
    
    ;GO
    LEA MSG_CMD_GO,A5
    LEA MSG_CMD_GO_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_GO_MSG
    
    ;DF
    LEA MSG_CMD_DF,A5
    LEA MSG_CMD_DF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_DF_MSG
    
    ;Exit help console
    LEA INPUT_BUFF,A1
    CMPI.B #Q_ASC,(A1)
    BEQ HELP_EXIT
    BRA HELP
HELP_EXIT:
    RTS

HELP_BSCH:
    LEA MSG_HELP_BSCH,A5
    LEA MSG_HELP_BSCH_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_ADD:
    LEA MSG_HELP_ADD,A5
    LEA MSG_HELP_ADD_ED,A6
    BSR PRINT 
    BRA HELP_LOOP
HELP_AND:
    LEA MSG_HELP_AND,A5
    LEA MSG_HELP_AND_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_RC:
    LEA MSG_HELP_RC,A5
    LEA MSG_HELP_RC_ED,A6
    BSR PRINT
    BRA HELP_LOOP

HELP_MDSP:
    LEA MSG_HELP_MDSP,A5
    LEA MSG_HELP_MDSP_ED,A6
    BSR PRINT
    BRA HELP_LOOP
    
HELP_EXIT_MSG:
    LEA MSG_HELP_EXIT,A5
    LEA MSG_HELP_EXIT_ED,A6
    BSR PRINT
    BRA HELP_LOOP

HELP_MM_MSG:
    LEA MSG_HELP_MM,A5
    LEA MSG_HELP_MM_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_MS_MSG:
    LEA MSG_HELP_MS,A5
    LEA MSG_HELP_MS_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_BF_MSG:
    LEA MSG_HELP_BF,A5
    LEA MSG_HELP_BF_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_BMOV_MSG:
    LEA MSG_HELP_BMOV,A5
    LEA MSG_HELP_BMOV_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_BT_MSG:
    LEA MSG_HELP_BT,A5
    LEA MSG_HELP_BT_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_GO_MSG:
    LEA MSG_HELP_GO,A5
    LEA MSG_HELP_GO_ED,A6
    BSR PRINT
    BRA HELP_LOOP
HELP_DF_MSG:
    LEA MSG_HELP_DF,A5
    LEA MSG_HELP_DF_ED,A6
    BSR PRINT
    BRA HELP_LOOP


;Block search
BSCH:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
    CMPA.L A4,A3        ;Check if the first address is smalller
    BGE SYNTAX_ER       
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER
    MOVE.L A1,-(A7)
BSCH_LOOP_1:
    MOVE.L (A7),A1
    CMPA.L A3,A4
    BEQ BSCH_FAILD    
    CMPM.B (A3)+,(A1)+
    BNE BSCH_LOOP_1
    MOVE.L A3,D0
    SUBQ #1,D0
BSCH_LOOP_2:
    CMPA.L A3,A4
    BLT BSCH_FAILD 
    CMPM.B (A3)+,(A1)+
    BEQ BSCH_LOOP_2
    CMPI.B #0,-1(A1)
    BEQ BSCH_SUCCESS
    CMPA.L A3,A4
    BEQ BSCH_FAILD
    MOVE.L (A7),A1
    BRA BSCH_LOOP_1
BSCH_FAILD:
    LEA MSG_BSCH_FAILD,A5
    LEA MSG_BSCH_FAILD_ED,A6
    BSR PRINT
    BRA BSCH_END    
BSCH_SUCCESS:
    LEA MSG_BSCH_SUCCESS,A5
    LEA MSG_BSCH_SUCCESS_ED,A6
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT
    BRA BSCH_END
BSCH_END:
    ADDQ #4,A7    
    RTS

;Addition
;Add two numbers and display the result
ADD:
        BSR     STORE_HIS
    CMPI.B  #SPACE,(A1)+ ;Get rid of the space after command
    BNE     SYNTAX_ER       
    BSR     ASCII2HEX
    MOVE.L  D0,D1        ;Parse the first NUMBER
    CMPI.B  #SPACE,(A1)+ 
    BNE     SYNTAX_ER       
    BSR     ASCII2HEX
    ADD.L   D1,D0
    MOVE.L  #4,D2
    MOVE.L  #$3000,A6
    MOVE.L  A5,A6
    BSR     HEX2ASCII
    BSR     PRINT
    RTS

;Arithmatic and 
;And two hex number bitwise and display the result
AND:
       BSR     STORE_HIS
    CMPI.B  #SPACE,(A1)+ ;Get rid of the space after command
    BNE     SYNTAX_ER       
    BSR     ASCII2HEX
    MOVE.L  D0,D1        ;Parse the first NUMBER
    CMPI.B  #SPACE,(A1)+ 
    BNE     SYNTAX_ER       
    BSR     ASCII2HEX
    AND.L   D1,D0
    MOVE.L  #4,D2
    MOVE.L  #$3000,A6
    MOVE.L  A5,A6
    BSR     HEX2ASCII
    BSR     PRINT
    RTS



;Recall last command    
RC:
    LEA HISTORY_BUFF,A2
    CMPI.B #0,(A2)  ;Check if history buffer is empty
    BNE RC_PROCESS
    LEA MSG_HIS_EMPTY, A5
    LEA MSG_HIS_EMPTY_ED, A6
    BSR PRINT
    RTS
RC_PROCESS:
    LEA INPUT_BUFF, A1
RC_LOOP:    
    CMPI.B #0,(A2)
    MOVE.B (A2)+,(A1)+
    BNE RC_LOOP
RC_END:    
    MOVE A1,A6
    LEA INPUT_BUFF,A5
    BSR PRINT
    BRA INTERPRETER ;Return to interpreter   
    
;Syntax error
;Throw an message indicating syntax error
SYNTAX_ER:
    LEA MSG_WRONG_CMD,A5
    LEA MSG_WRONG_CMD_ED,A6
    BSR PRINT
    LEA MSG_HELP_PROM,A5
    LEA MSG_HELP_PROM_ED,A6
    BSR PRINT
    BRA MAIN


MDSP:
    MOVEM.L D0-D7/A1-A6,-(A7)
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER
    
    CMPI.B  #DOLLAR, (A1)+  ;MAKE SURE ADDRESS STARTS WITH '$'
    BNE SYNTAX_ER
    BSR ASCII2HEX
    MOVE.W  D0,A3
    
    CMPI.B #SPACE,(A1)+
    BNE ONEMEM
    BSR TWOMEM
ONEMEM:
    MOVE.L  #16,D4      ;COUNTER
ONEMEMLOOP:
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #DOLLAR,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    LEA     OUTPUT_BUFF,A6
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    CLR     D0
    
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #SPACE,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    LEA     OUTPUT_BUFF,A6
    MOVE.B  (A3)+,D0
    MOVE.B  #1,D2
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT
    MOVE.L  A3,D0
    MOVE.L  #2,D2
    
    SUBI    #1,D4
    BGT     ONEMEMLOOP
    MOVEM.L (A7)+,D0-D7/A1-A6
    BRA MAIN
TWOMEM:
    MOVE.L  D0,D1
    CMPI.B  #DOLLAR, (A1)+  ;MAKE SURE ADDRESS STARTS WITH '$'
    BNE SYNTAX_ER
    BSR ASCII2HEX
    CMP     D0,D1
    BGE     SYNTAX_ER
    MOVE.W  D0,A4
    MOVE.L  A3,D0

TWOMEMLOOP:
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #DOLLAR,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    LEA     OUTPUT_BUFF,A6
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    CLR     D0
    
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #SPACE,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    LEA     OUTPUT_BUFF,A6
    MOVE.B  (A3)+,D0
    MOVE.B  #1,D2
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT
    MOVE.L  A3,D0           ;SETS UP NEXT ADDRESS TO PRINT
    MOVE.L  #2,D2
    
    CMP     A3,A4
    BGE     TWOMEMLOOP
    MOVEM.L (A7)+,D0-D7/A1-A6
    BRA MAIN
    
MM:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER  
    CMPI.B  #DOLLAR, (A1)+  ;MAKE SURE ADDRESS STARTS WITH '$'
    BNE SYNTAX_ER
    BSR ASCII2HEX
    MOVE.L  D0,A3
MMLOOP:
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #DOLLAR,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    LEA     OUTPUT_BUFF,A6
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    
    BSR PRINT_SPACE
    
    LEA     OUTPUT_BUFF,A6
    MOVE.B  (A3),D0
    MOVE.B  #1,D2
    BSR     HEX2ASCII
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C    
    BSR PRINT_COLON
    BSR INPUT
    LEA INPUT_BUFF,A1
    CMPI.B  #DOT,(A1)
    BEQ     MMEXIT
    
    BSR ASCII2HEX
    CMPI.B #2,D2
    BGE SYNTAX_ER
    MOVE.B  D0,(A3)+
    MOVE.L  A3,D0           ;SETS UP NEXT ADDRESS TO PRINT
    MOVE.L  #2,D2
    BSR     MMLOOP
MMEXIT:
    RTS
    
MS:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER  
    CMPI.B  #DOLLAR, (A1)+  ;MAKE SURE ADDRESS STARTS WITH '$'
    BNE SYNTAX_ER
    BSR ASCII2HEX
    MOVE.L  D0,A3
    CMPI.B #SPACE,(A1)+     ;Get rid of the space after command
    BNE SYNTAX_ER
    CMPI.B  #DOLLAR, (A1)  
    BEQ MSHEX
    BSR MSSTRING    
    RTS
MSHEX:
    ADD.L   #1,A1
    BSR ASCII2HEX
    CMPI.B  #2,D2
    BEQ     HEXWORD
    BLT     HEXBYTE
    BGT     HEXLW
    RTS
    
MSSTRING:
    CMPI.B  #NULL,(A1)
    BEQ STRINGEND
    MOVE.B  (A1)+,(A3)+
    BRA MSSTRING
STRINGEND:
    RTS
HEXWORD:
    MOVE.W  D0,(A3)
    RTS
HEXBYTE:
    MOVE.B  D0,(A3)
    RTS
HEXLW:
    MOVE.L  D0,(A3)
    RTS
BF:
    MOVEM.L D0-D7/A3/A4,-(A7)    
    BSR STORE_HIS
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,D1
    DIVU    #2,D1
    SWAP    D1
    CMPI.B  #0,D1
    BNE     SYNTAX_ER
    MOVE.L  D0,A3
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,D1
    DIVU    #2,D1
    SWAP    D1
    CMPI.B  #0,D1
    BNE     SYNTAX_ER
    MOVE.L  D0,A4
    CMPA.L  A3,A4
    BLE SYNTAX_ER
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    CMPI.B  #2,D2
    BGT     SYNTAX_ER
BFLOOP:
    MOVE.W  D0,(A3)+
    CMPA    A3,A4
    BLT     BFEXIT
    BSR     BFLOOP
BFEXIT:
    MOVEM.L (A7)+,D0-D7/A3/A4
    BRA MAIN   
BMOV:
    BSR STORE_HIS
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,A2
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,A3
    CMPA.L  A2,A3
    BLE     SYNTAX_ER
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,A4
BMOV_LOOP:
    MOVE.B  (A2)+,(A4)+
    CMPA.L  A2,A3
    BLT BMOV_EXIT
    BSR BMOV_LOOP
BMOV_EXIT:   
    RTS

DF: 
    MOVEM.L D0-D7/A0-A7,-(A7)
    MOVE.L  A7,A2
    MOVEM.L A7,-(A2)
    PEA *(PC)    
    MOVE.L  #4,D2    
    LEA OUTPUT_BUFF,A6
    MOVE.B  #80,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    MOVE.B  #67,(A6)+
    BSR PRINT_C
    BSR PRINT_COLON
    MOVE.L  (A2)+,D0
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.L  #4,D2
    LEA OUTPUT_BUFF,A6
    MOVE.B  #83,(A6)+
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    MOVE.B  #82,(A6)+
    BSR PRINT_C
    BSR PRINT_COLON
    MOVE    SR,D0
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.L  #4,D2
    LEA OUTPUT_BUFF,A6
    MOVE.B  #85,(A6)+
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    MOVE.B  #83,(A6)+
    BSR PRINT_C
    BSR PRINT_COLON
    MOVE    USP,A3
    MOVE.L  A3,D0
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.L  #4,D2
    LEA OUTPUT_BUFF,A6
    MOVE.B  #83,(A6)+
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    MOVE.B  #83,(A6)+
    BSR PRINT_C
    BSR PRINT_COLON
    MOVE.L  (A2)+,D0
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    BSR PRINT_C
    BSR PRINT_CR_LF 
    MOVEM.L (A7)+,D0-D7/A0-A7   
DF_D:
    MOVEM.L D0-D7/A0-A7,-(A7)
    MOVE.L A7,A2
    MOVE.B  #48,D3
    MOVE.B  #7,D7
DF_D_LOOP:
    BSR PRINT_D
    LEA OUTPUT_BUFF,A6
    MOVE.B  D3,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_COLON
    
    MOVE.L  (A2)+,D0
    MOVE.B  #4,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE      
    SUBI    #1,D7
    BLT     DF_A       
    ADDI    #1,D3
    CMPI.B  #3,D7
    BEQ     DF_D_NEWLINE
    BRA     DF_D_LOOP
DF_D_NEWLINE:
    LEA OUTPUT_BUFF,A6
    MOVE.B  #CR,(A6)+
    MOVE.B  #LF,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BRA     DF_D_LOOP
DF_A:
    BSR PRINT_CR_LF
    MOVE.B  #4,D2
    MOVE.B  #48,D3
    MOVE.L  #7,D7
DF_A_LOOP:
    BSR PRINT_A
    LEA OUTPUT_BUFF,A6
    MOVE.B  D3,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_COLON
    
    MOVE.L  (A2)+,D0
    MOVE.B  #4,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE      
    SUBI    #1,D7
    BLT     DFEND    
    ADDI    #1,D3
    CMPI.B  #3,D7
    BEQ     DF_A_NEWLINE
    BRA     DF_A_LOOP
    
DF_A_NEWLINE:
    LEA OUTPUT_BUFF,A6
    MOVE.B  #CR,(A6)+
    MOVE.B  #LF,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BRA     DF_A_LOOP

DFEND:
    BSR PRINT_CR_LF
    MOVEM.L (A7)+,D0-D1/A0-A7
    BRA MAIN


BT:
    MOVEM.L D0-D7/A3/A4,-(A7)    
    BSR STORE_HIS
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,D1
    DIVU    #2,D1
    SWAP    D1
    CMPI.B  #0,D1
    BNE     SYNTAX_ER
    MOVE.L  D0,A3
    MOVE.L  A3,A2
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,D1
    DIVU    #2,D1
    SWAP    D1
    CMPI.B  #0,D1
    BNE     SYNTAX_ER
    MOVE.L  D0,A4
    CMPA.L  A3,A4
    BLE SYNTAX_ER
    MOVE.B  #$AA,D0
BT_FILL_LOOP:
    MOVE.B  D0,(A3)+
    CMPA    A3,A4
    BGE     BT_FILL_LOOP
    MOVE.L  A2,A3
    MOVE.L  #$AA,D7
    BSR     BT_1
BT_1:
    CMPI.B  #$AA,(A3)
    BNE     BT_ERROR
    BSR     LOAD_55
    CMPA.L  A3,A4
    BGE     BT_1
    MOVE.L  A2,A3
    MOVE.L  #$55,D7
    BSR     BT_2
LOAD_55:
    MOVE.B  #$55,(A3)+
    RTS
    
BT_2:
    CMPI.B  #$55,(A3)
    BNE     BT_ERROR
    BSR     LOAD_AA
    CMPA.L  A3,A4
    BGE     BT_2
    BSR     BT_PASS
LOAD_AA:
    MOVE.B  #$AA,(A3)+
    RTS

    MOVEM.L (A7)+,D0-D7/A3/A4
    BRA MAIN   
BT_ERROR:
    LEA MSG_BT_FAIL,A5
    LEA MSG_BT_FAIL_ED,A6
    BSR PRINT
    MOVE.L  A3,D0
    MOVE.L  #4,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.B  (A3),D0
    MOVE.L  #1,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    BSR PRINT_SPACE
    
    MOVE.L  D7,D0
    MOVE.L  #1,D2
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT
    
    MOVEM.L (A7)+,D0-D7/A3/A4
    BRA MAIN
BT_PASS:
    LEA MSG_BT_PASS,A5
    LEA MSG_BT_PASS_ED,A6
    BSR PRINT
    MOVEM.L (A7)+,D0-D7/A3/A4
    BRA MAIN
GO:
    BSR STORE_HIS
    BSR SPACE_CHECK
    BSR HEXFROMINPUT
    MOVE.L  D0,A2
    JMP (A2)
    

HEXFROMINPUT:
    CMPI.B  #DOLLAR, (A1)+  ;MAKE SURE ADDRESS STARTS WITH '$'
    BNE SYNTAX_ER
    BSR ASCII2HEX
    RTS
SPACE_CHECK:
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER
    RTS
PRINT_CR_LF:    
    LEA OUTPUT_BUFF,A6
    MOVE.B  #CR,(A6)+
    MOVE.B  #LF,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    RTS
PRINT_D:
    LEA OUTPUT_BUFF,A6
    MOVE.B  #D_ASC,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    RTS
PRINT_A:
    LEA OUTPUT_BUFF,A6
    MOVE.B  #A_ASC,(A6)+
    LEA OUTPUT_BUFF,A5
    BSR PRINT_C
    RTS

PRINT_SPACE:
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #SPACE,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    RTS
PRINT_COLON:
    LEA     OUTPUT_BUFF,A6
    MOVE.B  #COLON,(A6)+
    LEA     OUTPUT_BUFF,A5
    BSR PRINT_C
    RTS

    

 
EXIT: 
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

*----------------COMMON SYMBOLS--------------------------*
BUFFSIZE    EQU     $256    ;BUFF SIZE IS EQUAL TO $256
SPACE       EQU	    $20     ;SPACE IN ASCII
CR          EQU     $0D     ;CARRIGE RETURN IN ASCII
LF          EQU     $0A     ;LINE FEED IN ASCII
NULL        EQU     $00     ;NULL
COLON	    EQU     $3A     ; : IN ASCII
COMMA	    EQU	    $2C     ; , IN ASCII
DOT	        EQU	    $2E     ; . IN ASCII
DOLLAR	    EQU	    $24     ; $ IN ASCII
A_ASC	    EQU	    'A'
B_ASC	    EQU	    'B'
D_ASC	    EQU	    'D'
F_ASC       EQU     'F'
G_ASC	    EQU	    'G'
H_ASC	    EQU	    'H'
L_ASC       EQU     'L'
M_ASC	    EQU	    'M'
Q_ASC		EQU		'Q'
S_ASC	    EQU	    'S'
W_ASC       EQU     'W'
LARGER      EQU     '>'

*---------------COMMAND MESSAGES------------------*
MSG_CMD_HELP    DC.B    'HELP'
MSG_CMD_HELP_ED:   
	DC.B	CR,LF 
MSG_CMD_FST:
MSG_CMD_BSCH    DC.B    'BSCH'
MSG_CMD_BSCH_ED:
	DC.B	CR,LF
MSG_CMD_ADD     DC.B    'ADD'
MSG_CMD_ADD_ED:
	DC.B	CR,LF
MSG_CMD_AND     DC.B    'AND'
MSG_CMD_AND_ED:
	DC.B	CR,LF
MSG_CMD_RC     DC.B    '<'
MSG_CMD_RC_ED:
    DC.B    CR,LF
MSG_CMD_MDSP    DC.B    'MDSP'
MSG_CMD_MDSP_ED:
    DC.B    CR,LF
MSG_CMD_EXIT    DC.B    'EXIT'
MSG_CMD_EXIT_ED:
    DC.B    CR,LF
MSG_CMD_MM      DC.B    'MM'
MSG_CMD_MM_ED:
    DC.B    CR,LF
MSG_CMD_MS      DC.B    'MS'
MSG_CMD_MS_ED:
    DC.B    CR,LF
MSG_CMD_BF      DC.B    'BF'
MSG_CMD_BF_ED:
    DC.B    CR,LF
MSG_CMD_BMOV    DC.B    'BMOV'
MSG_CMD_BMOV_ED:
    DC.B    CR,LF
MSG_CMD_BT    DC.B    'BT'
MSG_CMD_BT_ED:
    DC.B    CR,LF
MSG_CMD_GO      DC.B    'GO'
MSG_CMD_GO_ED:
    DC.B    CR,LF
MSG_CMD_DF      DC.B    'DF'
MSG_CMD_DF_ED:

MSG_CMD_LST:

*----------------COMMON MESSAGES------------------*
MSG_WELCOME:
    DC.B 'System initiallied. Please input command.' 
MSG_WELCOME_ED
MSG_PROM:
    DC.B 'MONITOR441>'
MSG_PROM_ED
MSG_HELP:
    DC.B	'Enter the command you need help.'
    DC.B 	CR,LF,'Press "Q" to exit.'
MSG_HELP_ED
MSG_BSCH_SUCCESS:
    DC.B 'Content found at: $'
MSG_BSCH_SUCCESS_ED
MSG_BSCH_FAILD:
    DC.B 'Content not found'
MSG_BSCH_FAILD_ED
MSG_WRONG_CMD:
    DC.B 'Wrong command'
MSG_WRONG_CMD_ED
MSG_HELP_PROM:
    DC.B	'Enter "HELP" for help info.'
MSG_HELP_PROM_ED
MSG_FINISH:
    DC.B 'Finshed'
MSG_FINISH_ED
MSG_HIS_EMPTY:
    DC.B 'No command to recall.'
MSG_HIS_EMPTY_ED
MSG_BT_PASS:
    DC.B    'MEMORY TEST PASSES'
MSG_BT_PASS_ED
MSG_BT_FAIL:
    DC.B    'MEMORY TEST FAILED'
MSG_BT_FAIL_ED

MSG_BUS_ER:
    DC.B    'BUS ERROR EXCEPTION'
MSG_BUS_ER_ED

MSG_ADDR_ER:
    DC.B    'ADDRESS ERROR EXCEPTION'
MSG_ADDR_ER_ED
MSG_ILL_ER:
    DC.B    'ILLEGAL INSTRUCTION EXCEPTION'
MSG_ILL_ER_ED
MSG_PRIVILEGE_ER:
    DC.B    'PRIVILEGE VIOLATION EXCEPTION'
MSG_PRIVILEGE_ER_ED

MSG_0_ER:
    DC.B    'DIVIDE BY ZERO EXCEPTION'
MSG_0_ER_ED

MSG_CHK_ER:
    DC.B    'CHK INSTRUCTION EXCEPTION'
MSG_CHK_ER_ED

MSG_LINE_A_ER:
    DC.B    'LINE A EMULATOR'
MSG_LINE_A_ER_ED

MSG_LINE_F_ER:
    DC.B    'LINE F EMULATOR'
MSG_LINE_F_ER_ED
*--------------HELP MESSAGES----------------------*

;Block search
MSG_HELP_BSCH:
    DC.B	'SEARCH FOR A SPECIFIC PATTERN (INPUT AS STRING) WITHIN',CR,LF 
    DC.B	'A MEMORY RANGE. IF FOUND, PRINT THE LOCATION OF SUCH',CR,LF
    DC.B	'STRING, IF NOT FOUND PRINT FAILED PROMOTION.',CR,LF 
    DC.B	'BSCH <addr1> <addr2> string'
MSG_HELP_BSCH_ED

;Addition
MSG_HELP_ADD:
    DC.B    'ADDS TWO HEX NUMBERS TOGETHER.',CR,LF
    DC.B    'ADD <Num1> <Num2>'
MSG_HELP_ADD_ED

;And
MSG_HELP_AND:
    DC.B    'ANDS TWO HEX NUMBERS TOGETHER.',CR,LF
    DC.B    'AND <NUM1> <NUM2>'
MSG_HELP_AND_ED


;Recall command
MSG_HELP_RC:
    DC.B	'REDO LAST CORRECT COMMAND.',CR,LF 
    DC.B	'<'
MSG_HELP_RC_ED:

;MEMORY DISPLAY
MSG_HELP_MDSP:
    DC.B    'DISPLAY MEMORY IN ADDRESS RANGE OR WILL',CR,LF
    DC.B    'DISPLAY 16 BYTES FROM SINGLE ADDRESS',CR,LF
    DC.B    'MDSP <addr1> <addr2>',CR,LF
    DC.B    '           OR       ',CR,LF
    DC.B    'MDSP <addr1>',CR,LF
MSG_HELP_MDSP_ED:

;EXIT
MSG_HELP_EXIT:
    DC.B    'EXITS THE MONITOR PROGRAM',CR,LF
    DC.B    'EXIT'
MSG_HELP_EXIT_ED:

;MEMORY MODIFY
MSG_HELP_MM:
    DC.B    'ALLOWS MODIFICATION OF MEMORY ONE BYTE AT A TIME',CR,LF
    DC.B    'DISPLAYS CURRENT MEMORY LOCATION THEN WAITS FOR INPUT',CR,LF
    DC.B    'INPUT MUST BE A HEX NUMBER, 2 DIGITS MAX',CR,LF
    DC.B    'TYPE "." WHEN FINISHED TO QUIT',CR,LF
    DC.B    'MM <addr>'
MSG_HELP_MM_ED:

;MEMORY SET
MSG_HELP_MS:    
    DC.B    'SETS MEMORY IN GIVEN LOCATION. INPUT CAN BE IN HEX OR ASCII FORMAT.',CR,LF
    DC.B    'HEX INPUT MUST START WITH A "$" AND IS WRITTEN AS: BYTE, WORD, LONG',CR,LF
    DC.B    'DEPENDING ON THE LENGTH OF THE NUMBER, LONG WORD MAX',CR,LF
    DC.B    'MS <addr> <input to be stored>'
MSG_HELP_MS_ED:

;BLOCK FILL
MSG_HELP_BF:
    DC.B    'FILLS A BLOCK OF MEMORY FROM ONE ADDRESS THROUGH ENDING ADDRESS',CR,LF
    DC.B    'WITH A HEX NUMBER IN WORD FORMAT. NUMBER CAN NOT BE LARGER THAN A WORD.',CR,LF
    DC.B    'BF <addr1> <addr2> <input>'
MSG_HELP_BF_ED:

;BLOCK MOVE
MSG_HELP_BMOV:
    DC.B    'COPIES A BLOCK OF MEMORY BETWEEN A GIVEN RANGE TO ANOTHER LOCATION.',CR,LF
    DC.B    'BMOV <addr1> <addr2> <addr to move to>'
MSG_HELP_BMOV_ED:

;BLOCK TEST
MSG_HELP_BT:
    DC.B    'A DESTRUCTIVE TEST OF A BLOCK OF MEMORY BEWEEN ADDR1 AND ADDR2',CR,LF
    DC.B    'BT <addr1> <addr2>'
MSG_HELP_BT_ED
    
;GO
MSG_HELP_GO:
    DC.B    'RUNS A PROGRAM START FROM MEMORY LOCATION ADDR1',CR,LF
    DC.B    'GO <addr1>'
MSG_HELP_GO_ED

;DISPLAY
MSG_HELP_DF:
    DC.B    'DISPLAYS FORMATED REGISTERS INCLUDING: PC,SR,US,SS,D AND A REGISTERS',CR,LF
    DC.B    'DF'
MSG_HELP_DF_ED    

    ORG $3000
INPUT_BUFF:
    DS.B    BUFFSIZE 
OUTPUT_BUFF:
    DS.B    BUFFSIZE
HISTORY_BUFF:
    DS.B    BUFFSIZE    
ADDR_BUFF:
    DS.B    8
    ORG $4000
    DS.B    1024    ;RESERVE 1KB FOR A7 STACK
STACK:    
    DS.L    20      ;RESERVE 40 BYTES FOR
REGISTER_STACK: 
    DS.L    1
REGISTER_PC:   
    DS.L    1
    END    START        
    






























*~Font name~Courier New~
*~Font size~18~
*~Tab type~1~
*~Tab size~4~
