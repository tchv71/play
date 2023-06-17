WRKARE	EQU 0B000H
PSG	EQU 0CC00H
PPI	EQU 0C200H
LOTMP	EQU 0F800H

	.phase 100h
START:
 LXI H,ZAST
 CALL 0F818H
 CALL 0F803H
 CALL INITPL
 CPI '1'
 JZ PLAY1
 CPI '2'
 JZ PLAY2
 CPI '3'
 JZ PLAY3
 CPI '4'
 JZ PLAY4
 CPI '5'
 JZ PLAY5
 CPI '6'
 JZ PLAY6
 JMP 0F86CH

PLAY1:
 LXI H,PL01
 LXI D,PL02
 LXI B,PL03
 CALL PLAY
 JMP START
PLAY2:
 LXI H,PL11
 LXI D,PL12
 LXI B,PL13
 CALL PLAY
 JMP START
PLAY3:
 LXI H,PL21
 LXI D,PL22
 LXI B,PL23
 CALL PLAY
 LXI H,PL24
 LXI D,PL25
 LXI B,PL26
 CALL PLAY

 JMP START
PLAY4:
 LXI H,PL31
 LXI D,PL32
 LXI B,PL33
 CALL PLAY
 JMP START
PLAY5:
 LXI H,PL41
 LXI D,PL42
 LXI B,PL43
 CALL PLAY
 JMP START

PLAY6:
 LXI H,PL51
 LXI D,PL52
 LXI B,PL53
 CALL PLAY
 JMP START


RDSND:
 MOV A,M
 PUSH PSW
 MOV C,A
;CALL 0F809H
 MVI A,6
 STA PPI+2
 POP PSW
 INX H
 CPI 'V'
 JZ VOL
 CPI 'L'
 JZ LOUDN
 CPI 'O'
 JZ OCTAVE
 CPI 'T'
 JZ TEMP
 CPI 'R'
 JZ PAUSE
 CPI 'M'
 JZ FORM
 CPI 'A'
 JC ERROR
 CPI 'H'
 JNC ERROR
 CPI 'B'
 JNZ $+8
 MVI B,12
 JMP PL0
 CPI 'E'
 JNZ $+8
 MVI B,5
 JMP PL0
 CPI 'C'
 JNZ $+8
 MVI B,1
 JMP PL1
 CPI 'F'
 JNZ $+8
 MVI B,6
 JMP PL1
 CPI 'D'
 JNZ $+5
 MVI B,3
 CPI 'G'
 JNZ $+5
 MVI B,8
 CPI 'A'
 JNZ $+5
 MVI B,10
 CALL FNDBEM
 CALL FNDDZ
 JMP PL2

FNDBEM:
 MOV A,M
 CPI '$'
 RNZ
 DCR B
 INX H
 RET

FNDDZ:
 MOV A,M
 CPI '#'
 RNZ
 INR B
 INX H
 RET

PL0:
 CALL FNDBEM
 JMP PL2
PL1:
 CALL FNDDZ
PL2:
 MOV A,B
 CPI 13
 RNC
 INX D
 LDAX D
 DCX D
 MOV C,A
 MOV A,E
 ANI 0FCH
 RRC
 RRC
 PUSH PSW
 PUSH B
 MOV A,E
 ANI 0FCH
 RRC
 RRC
 RRC
 RRC
 ORI 36H
 STA PSG+3
 CALL SNDEL
 POP B
 POP PSW
 CALL SOUND
 CALL GETVAL
 MOV B,A
 RET

ERROR:
 LHLD STCPNT
 SPHL
 RET

;CALL SNDEL
 RLC
 JC PL3
 RLC
 JC PL3
 RLC
 JC PL3
 RLC
 JC PL3
 RLC
 JC PL3
 RLC
 JNC PL4
PL3:
 MVI A,0FFH
PL4:
 MVI A,0FFH
 MOV B,A
 MOV A,E
 ANI 0FBH
 RRC
 RRC
 RRC
 RRC
 ORI 36H
 STA PSG+3
;CALL SNDEL
 JMP RDSND

OCTAVE:
 CALL GETVL1
 ORA A
 JZ ERROR
 CPI 7
 JNC ERROR
 INX D
 STAX D
 DCX D
 JMP RDSND

PAUSE:
 MOV A,E
 ANI 0FCH
 RRC
 RRC
 RRC
 RRC
 ORI 36H
 STA PSG+3
 CALL GETVAL
 MOV B,A
 RET



LOUDN:
 CALL GETVL1
 STAX D
 JMP RDSND

TEMP:
 CALL GETVL1
 ORA A
 JZ ERROR
 PUSH D
 INX D
 INX D
 MOV A,C
 STAX D
 MOV A,B
 INX D
 STAX D
 POP D
 JMP RDSND

VOL:
 CALL GETVL1
 JMP RDSND

FORM:
 CALL GETVL1
 JMP RDSND

GETVAL:
 CALL GETVL1
 ORA A
 JNZ $+4
 LDAX D
 MOV C,A
 ANI 0FEH
 RRC
 MOV B,A
 MOV A,C
 RLC
 MOV C,A
 MOV A,M
 CPI '.'
 MOV A,C
 RNZ
 SUB B
 INX H
 RET

GETVL1:
 PUSH D
 LXI D,0
 MOV A,M
 SUI '0'
 MOV B,A
 MVI A,0
 RC
 CPI 0AH
 MVI A,0
 RNC
GET2:
 MOV A,M
 SUI '0'
 JC  GET1
 CPI 0AH
 JNC GET1
 XCHG
 DAD H
 DAD H
 DAD H
 DAD H
 XCHG
 ORA E
 MOV E,A
 INX H
 JMP GET2
GET1:
 MOV A,D
 STA DNUM+1
 MOV A,E
 STA DNUM
 PUSH H
 CALL ?FBCDB
 POP H
 LDA BNUM+1
 MOV B,A
 LDA BNUM
 MOV C,A
 POP D
 RET


INITPL:
 LXI H,PSG+3
 MVI M,36H
 MVI M,76H
 MVI M,0B6H
 LXI H,PPI+2
 MVI M,6
 RET


SOUND:; B - NOMER NOTY, C - NOMER OKTAVY,A - NOMER KANALA
 PUSH H
 PUSH D
 PUSH PSW
 LXI H,PLTBL
 MOV A,B
 DCR A
 ADD A
 MOV E,A
 MVI D,0
 DAD D
 MOV E,M
 INX H
 MOV D,M
 XCHG
 MOV B,C
 CALL ?SRNHB
 XCHG
 LXI H,PSG
 POP PSW
 MOV C,A
 MVI B,0
 DAD B
 MOV M,E
 MOV M,D
 POP D
 POP H
 RET

PLAY:
 SHLD PNT1
 LXI H,0
 DAD SP
 SHLD STCPNT
 XCHG
 SHLD PNT2
 MOV H,B
 MOV L,C
 SHLD PNT3
 CALL SND1
 CALL SND2
 CALL SND3
PLY0:
 LHLD DL1
 XCHG
 LHLD DLC1
 CALL ?NEGHL
 DAD D
 SHLD DL1
 CNC SND1
 LHLD DL2
 XCHG
 LHLD DLC2
 CALL ?NEGHL
 DAD D
 SHLD DL2
 CNC SND2
 LHLD DL3
 XCHG
 LHLD DLC3
 CALL ?NEGHL
 DAD D
 SHLD DL3
 CNC SND3
 LXI B,1
PLY1: DCX B
 MOV A,B
 ORA C
 JNZ PLY1
 JMP PLY0

SND1:
 LHLD PNT1
 LXI D,WRKARE
 CALL RDSND
 SHLD PNT1
 MVI E,2
 CALL GETDEL
 SHLD DLC1
 LXI H,LOTMP
 SHLD DL1
 RET

SND2:
 LHLD PNT2
 LXI D,WRKARE+4
 CALL RDSND
 SHLD PNT2
 MVI E,6
 CALL GETDEL
 SHLD DLC2
 LXI H,LOTMP
 SHLD DL2
 RET

SND3:
 LHLD PNT3
 LXI D,WRKARE+8
 CALL RDSND
 SHLD PNT3
 MVI E,10
 CALL GETDEL
 SHLD DLC3
 LXI H,LOTMP
 SHLD DL3
 RET

SNDEL:
 LXI B,1
SNDL1:
 DCX B
 MOV A,B
 ORA A
 JNZ SNDL1
 RET
GETDEL:
 XCHG
 MOV E,M
 INX H
 MOV D,M
 MOV L,B
 MVI H,0
 CALL ?MULHD
 MVI B,4
 CALL ?SRNHB
 MOV A,H
 ORA L
 JNZ $+5
 MVI L,1
 RET
; 16-BIT MULTIPLY
; HL *= DE
?MULHD:
 MOV B,H
 MOV C,L
 LXI H,0
 MVI A,16
?01:
 DAD H
 XCHG
 DAD H
 XCHG
 JNC ?02
 DAD B
?02:
 DCR A
 JNZ ?01
 RET


?ABSHL:
 MOV A,H
 ORA A
 RP
?NEGHL:
 DCX H
?NOTHL:
 MOV A,L
 CMA
 MOV L,A
 MOV A,H
 CMA
 MOV H,A
 RET

;USKORENNYE PREOBRAZOVANIYA BIN I BCD - CHISEL
; DNUM - ADRES BCD - CHISLA
; NDEC - DLINA -""-
; BNUM - DLINA BIN - CHISLA
; NBIN - DLINA -""-

?ZERON:XRA A
LOOP1:MOV M,A
 INX H
 DCR B
 JNZ LOOP1
 RET

; BCD -> BINARY
?FBCDB:
 LXI H,BNUM
 MVI B,NBIN
 CALL ?ZERON
 MVI A,NDEC
 ADD A
 ADD A
 ADD A
 MOV C,A
?NEW:
 XRA A
 LXI H,DNUM+NDEC-1
 MVI B,NDEC
 CALL SHIFTR
 LXI H,BNUM+NBIN-1
 MVI B,NBIN
 CALL SHIFTR
 LXI H,DNUM
 MVI B,NDEC
 CALL ?CORR
 DCR C
 JNZ ?NEW
 RET

NBIN	EQU 2
NDEC	EQU 2
DNUM:	DB 55H,2
BNUM:	DW 0

SHIFTR:
 MOV A,M
 RAR
 MOV M,A
 DCX H
 DCR B
 JNZ SHIFTR
 RET

?CORR:
 MOV A,M
 ANI 8
 JZ ?NOCR1
 MOV A,M
 SUI 3
 MOV M,A
?NOCR1:
 MOV A,M
 ANI 80H
 JZ ?NOCR2
 MOV A,M
 SUI 30H
 MOV M,A
?NOCR2:
 INX H
 DCR B
 JNZ ?CORR
 RET

; 16-BIT UNSIGNED SHIFT RIGHT
; HL >>= B
?SRNHB:
 INR B
?71:
 DCR B
 RZ
 ANA A
 MOV A,H
 RAR
 MOV H,A
 MOV A,L
 RAR
 MOV L,A
 JMP ?71

; KOEFFICIENTY DELENIYA DLYA NOT KONTROKTAVY
; 16 MGC;16.5MGC
PLTBL:
 DW 0D459H;0DB34H - DO
 DW 0C86EH;0CEE7H - DO#
 DW 0BD2EH;0C34AH - RE
 DW 0B290H;0B854H - RE#
 DW 0A88AH;0ADFCH - MI
 DW 09F15H;0A438H - FA
 DW 09627H;09B00H - FA#
 DW 08DBAH;0924DH - SOL'
 DW 085C5H;08A17H - SOL'#
 DW 07E43H;08257H - LYA
 DW 0772DH;07B00H - LYA#
 DW 0707DH;0741FH - SI
; MENUET I.S.BAH
; 1 GOLOS
PL01:
 DB 'T110L8O3D4GABO4CD4O3G4G4O4E4CDEF#G4O3G4'
 DB 'G4O4C4DCO3BAB4O4CO3BAGF#GABGB4A2'
 DB 'O4D4O3GABO4GD4O3G4G4O4E4GDEF#G4O3G4G4O4G4DCO3'
 DB 'BAB4O4CO3BAGA4BAGF#G2.'
 DB 'O4B4GABGA4DEF#DG4EF#GDC#4O3BO4C#O3A4ABO4C#DEF#'
 DB 'G4F#4E4D2.'
 DB 'D4O3GF#G4O4E4O3GF#G4O4D4C4O3D4AGF#GA4DEF#GABO4'
 DB 'C4O3B4A4BO4DO3G4F#4G2'
 DB 0
PL02: DB 'T110L8O1ABABABABABABABABABABABABABABABABAB'
 DB 'ABABABABABABABABABABABABABABABABABABABABABABABA'
 DB 'BABABABABABABABABABABABABABABABABABABABABABABAB'
 DB 'ABABABABABABABABABABABABABABABABABABABABABABA'
 DB 'BABABABABABABABABAB',0
PL03: DB 'T1L1RRR',0

; VO POLE BEREZA STOYALA
; 1 GOLOS
PL11:
 DB 'T50L8O3AAAAG4FFE4D4AAO4CO3AGGFFE4D4'
 DB 'E4.FG4FFE4D4E4.FG4FFE4D4'
 DB  0
; 2 GOLOS
PL12:
 DB 'T50O2L4DDO1AO2DO1AO2DDDO1GO2DO1AO2DO1A4.A8'
 DB 'AO2DO1AO2DO1A4.A8AAAO2D4',0
PL13:
 DB 'T1L1RRRR',0


; PESENKA KROKODILA GENY
; 1 GOLOS
PL24:
 DB 'T110O3A8O4C8D2.',0
PL21:
 DB 'T110L8O3AB$A4DEFDAB$A4EFGEAB$A4EFG4AB$A2.'
 DB 'O4DE$D4O3AB$O4CO3AO4DE$D4O3GAB$O4DCO3B$O4D4O3AFE4GFD2.'
 DB 'DFF4E2EGG4F2FAA4G2B$AO4C2.O3AO4CC4O3B$2GB$B$4A2FAG2A2D2.'
 DB 0
; 2 GOLOS
PL25:
 DB 'T110O3R8R8A2.',0
PL22:
 DB 'T110L4RO2DDDDO1AAAAAAAAO2D2.DDDDDO1GGGG'
 DB 'O2DDO1AAO2D2.RO1AAAAO2DDDDCCCCF2.DO1GGGGO2DDDDO1'
 DB 'AAAAO2D2.',0
PL23:
 DB 'T1L1RRRR',0
PL26:
 DB 'T110O3R8R8F2.',0

PL31:
; KUZNECHIK
 DB 'T200L4O3AEAEAG#G#RG#EG#EG#AARAEAEAG#G#RG#EG#EG#A2R'
 DB 'ABB8B8BBO4CC8C8CCCO3BAG#AARABB8B8BBO4'
 DB 'CC8C8CCCO3BAG#A2R4'
 DB 0
PL32:
 DB 'T200L2O1R4AAO2EEEEO1AAAAO2EEEEO1AA4'
 DB 'L4RGRRRO2CRRR'
 DB 'L2EEO1AAL4GRRRO1CRRRL2EEO1AAT1L1RRR',0
PL33:
 DB 'T10L1RRRRRRRRRRRRR',0
PL41:
 DB 'T110L8O3CA$A$GA$FCCCA$A$BGO4C4.CO3DDB$B$AGFCAAGAF4.'
 DB 'O4CO3DDB$B$AGFCAAGAF4.',0
PL42:
 DB 'T1L1RRRRRR',0

PL43:
 DB 'T1L1RRR',0
;THE FINAL COUNT DOWN
PL51:
      DB 'T100O2L4.AA8O4E16D16EO3AAA8O4'
      DB 'F16E16F8E8DDD8F16E16FO3AAA8O4D16C16D8C8'
      DB 'O3B8O4D8'
      DB 'CC8E16D16EO3AAA8O4F16E16F8E8DDD8'
      DB 'F16E16FO3AAA8O4D16C16D8C8O3B8O4D8'
      DB 'CC8O3B16O4C16DD8C16D16E8D8C8O3B8'
      DB 'AO4FE2E4$E16.F16E16D16E1'


      DB 'O3.AA8O4E16D16EO3AAA8O4'
      DB 'F16E16F8E8DDD8F16E16FO3AAA8O4D16C16D8C8'
      DB 'O3B8O4D8'
      DB 'CC8E16D16EO3AAA8O4F16E16F8E8DDD8'
      DB 'F16E16FO3AAA8O4D16C16D8C8O3B8O4D8'
      DB 'CC8O3B16O4C16DD8C16D16E8D8C8O3B8'
      DB 'AO4FE2E4$E16.F16E16D16E1'

;PL51: DB 'T100O3L4$A2AGEO4CO3BGA.A8$A8A2'
      DB 'T1L1RRRRRR1'
      DB 0
PL52:
      DB 'T1L1RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR1'
      DB 0
PL53:
      DB 'T100O1L1$AFDG.G32$AFDGA2G2O2C2O1F2EE'
      DB '.E32$L8'
      DB 'O0AO1AO0AO1AO0AO1AO0AO1A'
      DB 'O0FO1FO0FO1FO0FO1FO0FO1F'
      DB 'O0DO1DO0DO1DO0DO1DO0DO1D'
      DB 'O0GO1GO0GO1GO0GO1GO0GO1G'
      DB 'O0AO1AO0AO1AO0AO1AO0AO1A'
      DB 'O0FO1FO0FO1FO0FO1FO0FO1F'
      DB 'O0DO1DO0DO1DO0DO1DO0DO1D'
      DB 'O0GO1GO0GO1GO0GO1GO0GO1G'
      DB 'O0AO1AO0AO1AO0GO1GO0GO1G'
      DB 'O1CO2CO1CO2CO0FO1FO0FO1F'
      DB 'O0EO1EO0EO1EO0EO1EO0EO1E'
      DB 'O0EO1EO0EO1EO0EO1EO0EO1E8'
      DB 0

PNT1:DS 2
PNT2:DS 2
PNT3:DS 2
DL1: DS 2
DL2: DS 2
DL3: DS 2
DLC1:DS 2
DLC2:DS 2
DLC3:DS 2
STCPNT:DS 2
ZAST: DB 1FH,' 1  MINUET I.S.BAH'
      DB 0DH,0AH,' 2  VO POLE BEREZA STOYALA..'
      DB 0AH,0DH,' 3 PESENKA KROKODILA GENY'
      DB 0DH,0AH,' 4 KUZNECHIK'
      DB 0DH,0AH,' 5 V LESU RODILAS ELOCHKA'
      DB 0DH,0AH,' 6 THE FINAL COUNTDOWN',0

 END
