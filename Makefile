M80PATH=D:/M80
PORT=COM2:

.SUFFIXES: .ASM .REL .BIN .rkl

.asm.REL:
	$(M80PATH)/M80 '=$< /I/L'

play3.REL: play3.asm
	$(M80PATH)/M80 '=$< /I/L'
	../m80noi/x64/Release/m80noi.exe PLAY3.PRN

play31.REL: play31.asm
	$(M80PATH)/M80 '=$< /I/L'
	../m80noi/x64/Release/m80noi.exe PLAY31.PRN

organ.REL: organ.asm
	$(M80PATH)/M80 '=$< /I/L'
	../m80noi/x64/Release/m80noi.exe organ.PRN

clean:
	del *.REL
	del *.PRN
	del *.BIN

all: play3.rkl play31.rkl duckt.rkl

send: organ.rkl
	MODE $(PORT) baud=115200 parity=N data=8 stop=1
	cmd /C copy /B $< $(PORT)

send2: play31.rkl
	MODE $(PORT) baud=115200 parity=N data=8 stop=1
	cmd /C copy /B $< $(PORT)

.BIN.rkl:
	../makerk/Release/makerk.exe 100 $< $@


.REL.BIN:
	$(M80PATH)/L80 /P:100,$<,$@/N/Y/E

