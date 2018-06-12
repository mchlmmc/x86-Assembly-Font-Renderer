; Copyright © 2018 Michael Mamic
; ----------------------------------------------------
; Permission is hereby granted, free of charge,
; to any person obtaining a copy of this software
; and associated documentation files (the “Software”),
; to deal in the Software without restriction,
; including without limitation the rights to use,
; copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
; TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; -----------------------------------------------------
; The code below functions as an entire operating system,
; although it only draws a string of text.
; The code is a bootloader, which ends in a boot signature
; 0x55AA in order to be booted by the processor on startup.
; The font is expected to be on disk at sectors 2 and 3
; (With the first sector on disk as sector 1).
; -----------------------------------------------------
; The formula to get character in disk is 0x200 + (char * 7)
; To go to the next row, add 0xC80.

use16

BLUE =			       0x1
GREEN = 		       0x2
CYAN =			       0x3
RED =			       0x4
MAGENTA =		       0x5
BROWN = 		       0x6
GRAY =			       0x7
DARKGRAY =		       0x8
LIGHTBLUE =		       0x9
LIME =			       0xA
LIGHTCYAN =		       0xB
LIGHTRED =		       0xC
LIGHTMAGENTA =		       0xD
YELLOW =		       0xE
WHITE = 		       0xF

COLOR = LIME			; Because lime looks cool.

; # Stack Setup #

mov ax, 0x7BFF		       ; Move AX to address 0x7BFF
mov ss, ax		       ; Set the max height of the stack to 0x7BFF
mov sp, 0x7BFF		       ; Make the stack start at 0x7BFF
mov bp, 0x500		       ; Make the stack start at 0x7000
mov ax, 0x7C00		       ; Move AX to address 0x6000
mov ds, ax		       ; Set the base of the data to 0x6000

; # Load Font to RAM #

pusha			       ; Push all registers
mov ah, 0x02		       ; Read memory
mov al, 0x02		       ; Read 2 sectors
mov ch, 0x0		       ; First cylinder
mov cl, 0x2		       ; Read sector 2
mov dh, 0x0		       ; First Head
mov dl, 0x0		       ; First Drive
mov bx, 0x7E00		       ; Load at 7E00
mov es, bx
xor bx, bx		       ; Clear off BX

readFloppy:
int 0x13		       ; Call interrupt 0x13
jc readFloppy		       ; If interrupt fails, try again
popa			       ; Pop all registers

; # Set Video Mode #

xor ah, ah		       ; Set AH to 0
mov al, 0x13		       ; Set AL to VGA video
int 0x10		       ; Change video mode

; # Call Display Function #

xor di, di		       ; Clear DI
xor cx, cx		       ; Clear CX

xor ax, ax
mov bx, 0x7C0
mov es, bx
mov bx, text

call writeString
jmp $			       ; Infinite wait because there's nothing left to do

; # Display Character Function #

dispChar:
push di
push es
push dx
push cx
push bx
push ax
mov ax, 7		       ; Move AX to 8
mul dx			       ; Multiply DX (Character to print) by AX (8)
mov bx, 0xA000		       ; Move ES to 0xA0000 (Start of VGA memory)
mov es, bx
mov bx, ax		       ; Set BX to result of the prior multiplication
xor cx, cx		       ; Clear CX, as it will be the counter

printLine:
cmp cx, 0x7		       ; Compare CX to 8
je dispCharEnd		       ; If it is 8 then jump to the end of this function
inc cx			       ; Increment CX
push di 		       ; Store DI, ES, and BX in the stack
push es
push bx
mov bx, 0x7E00		       ; Set ES to 0x7E00 (Start of font)
mov es, bx
pop bx			       ; Restore BX
mov al, [es:bx] 	       ; Make AL the byte referred to by [es:bx]
pop es			       ; Restore ES
push ax 		       ; Store AX
inc bx			       ; Increment BX
and al, 128		       ; Check if the 128 bit in AL is set
cmp al, 128
jne nxtPrint		       ; If not, skip the following line
mov [es:di], byte COLOR        ; Draw pixel at first pixel of current line
nxtPrint:
pop ax			       ; Restore AX
inc di			       ; Increment DI (Move to next pixel)
push ax 		       ; Store AX
and al, 64		       ; Check if the 64 bit in AL is set
cmp al, 64
jne nxtPrintB		       ; If not, skip the following line
mov [es:di], byte COLOR        ; Draw pixel at second pixel of current line
nxtPrintB:
pop ax			       ; Restore AX
inc di			       ; Increment DI (Move to next pixel)
push ax 		       ; Store AX
and al, 32		       ; Check if the 32 bit in AL is set
cmp al, 32
jne nxtPrintC		       ; If not, skip the following line
mov [es:di], byte COLOR        ; Draw pixel at third pixel of current line
nxtPrintC:
pop ax			       ; Restore AX
inc di			       ; Increment DI (Move to next pixel)
push ax 		       ; Store AX
and al, 16		       ; Check if the 16 bit in AL is set
cmp al, 16
jne nxtPrintD		       ; If not, skip the following line
mov [es:di], byte COLOR        ; Draw pixel at fourth pixel of current line
nxtPrintD:
pop ax			       ; Restore AX
inc di			       ; Increment DI (Move to next pixel)
push ax 		       ; Store AX
and al, 8		       ; Check if the 8 bit in AL is set
cmp al, 8
jne dispLineEnd 	       ; If not, skip the following line
mov [es:di], byte COLOR        ; Draw pixel at fifth pixel of current line
dispLineEnd:
pop ax			       ; Restore AX
pop di			       ; Restore DI
add di, 0x140		       ; Add 0x140 to DI (Move DI to next line)
jmp printLine		       ; Jump back to printLine

dispCharEnd:
pop ax
pop bx
pop cx
pop dx
pop es
pop di
ret

; # Write String Function #

writeString:		       ; Writes null-terminated string starting at [es:bx]
wsRepeat:		       ; Writes character until null byte
mov al, [es:bx] 	       ; Moves AL (character to write) to current address
cmp al, 0x00			  ; Checks if AL is null
je wsDone		       ; If so, jump to .done
cmp al, 0xA
je wsNew
mov dl, [es:bx] 	       ; Set DX to character at [es:bx]
call dispChar		       ; Display DX
cmp al, 'i'
je add5
cmp al, 'l'
je add5
add di, 0x6		       ; Move DX for spacing
jmp incBX
add5:
add di, 0x5		       ; Move DX for spacing
incBX:
inc bx			       ; Increments current address
jmp wsRepeat		       ; Otherwise, repeat the following steps
wsNew:
call newLine
inc bx
jmp wsRepeat
wsDone: 		       ; Last label of function
ret			       ; Returns function

newLine:
push ax
push bx
mov bx, di
newLineA:
cmp di, 0xA00
jl newLineB
sub di, 0xA00
jmp newLineA
newLineB:
mov ax, 0xA00
sub ax, di
add bx, ax
mov di, bx
pop bx
pop ax
ret

; # Program Data (Not including the font) #

text:
db '# Goodbye to a World'
db 0xA
db '# by Porter Robinson'
db 0xA
db 0xA
db ' Thank you, I''ll say goodbye soon'
db 0xA
db ' Though it''s the end of the world,'
db 0xA
db ' don''t blame yourself, now'
db 0xA
db ' And if it''s true, I will surround you,'
db 0xA
db ' and give life to a world'
db 0xA
db ' That''s our own'
db 0x0

; # Generic Bootloader Footer #

times 510 - ($ - $$) db 0
dw 0xAA55