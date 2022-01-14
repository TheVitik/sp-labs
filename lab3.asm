IDEAL
MODEL small
STACK 256


DATASEG

mas db 13, 10, 'string ','$'
messagex db,'Enter a x number: ','$'
messagey db,'Enter a y number: ','$'
message2 db,'Result is ','$'
message3 db 'Invalid type of number','$'

result dw 0
x dw 0
y dw 0
bufferx db 7, ?, 7 dup('?')
buffery db 7, ?, 7 dup('?')
check dw 0
exCode db 0

CODESEG
PROC Digit
mov dx, offset message2
mov ah,9
int 21h
lea dx, [result]
mov bx, [result]
test bx, bx

jns m1

m1:
mov ax, bx
xor cx, cx
mov bx, 10
m2:
xor dx, dx
div bx
add dl, '0'
push dx
inc cx
test ax, ax
jnz m2

m3:
pop ax
int 29h
loop m3 
ret
ENDP Digit

PROC DigitEnd
mov  dl, ','         ;First display a minus sign
mov  ah, 02h
int  21h
mov bx, [result]
test bx, bx

jns m1e
mov  dl, '-'         ;First display a minus sign
mov  ah, 02h
int  21h
neg bx

m1e:
mov ax, bx
xor cx, cx
mov bx, 10
m2e:
xor dx, dx
div bx
add dl, '0'
push dx
inc cx
test ax, ax
jnz m2

m3e:
pop ax
int 29h
loop m3 
ret
ENDP DigitEnd

PROC InputX
mov dx, offset messagex
mov ah,9h
int 21h

lea dx, [bufferx]
mov ah, 10
int 21h
;Enter
mov ah, 2h
mov dl, 0ah
int 21h
call StrToIntX
ret
ENDP InputX

PROC InputY
mov dx, offset messagey
mov ah,9h
int 21h

lea dx, [buffery]
mov ah, 10
int 21h
;Enter
mov ah, 2h
mov dl, 0ah
int 21h
call StrToIntY
back:
ret
ENDP InputY

PROC StrToIntX
lea dx,[bufferx]
add dx,2
mov bx,dx
mov bl,[bx]
mov al,[bufferx+1]
mov cl,al
cmp bl,'-'
je NegativeNumberX
jmp number_posX
ret
ENDP StrToIntX

PROC StrToIntY
lea dx,[buffery]
add dx,2
mov bx,dx
mov bl,[bx]
mov al,[buffery+1]
mov cl,al
cmp bl,'-'
je NegativeNumberY
jmp number_posY
ret
ENDP StrToIntY

negnumberx:
PROC NegativeNumberX
dec cl
mov [check],1
inc dx
jmp number_posX
ret
ENDP NegativeNumberX

negnumbery:
PROC NegativeNumberY
dec cl
mov [check],1
inc dx
jmp number_posY
ret
ENDP NegativeNumberY

number_posx:
PROC NumberPosX
mov si,dx
mov di,10
xor ax,ax
xor bx,bx
loopx:
mov bl,[si]
inc si
cmp bl,30h;
jl error
cmp bl,39h
jg error
sub bl,30h
mul di
jc error
add ax, bx
jc error
dec cl
cmp cl,0
jz finalx
jmp loopx
ret
ENDP NumberPosX

number_posy:
PROC NumberPosY
mov si,dx
mov di,10
xor ax,ax
xor bx,bx
loopy:
mov bl,[si]
inc si

cmp bl,30h;
jl error
cmp bl,39h
jg error
sub bl,30h
mul di
jc error
add ax, bx
jc error
dec cl
cmp cl,0
jz finaly
jmp loopy
ret
ENDP NumberPosY

error:
PROC Error
mov ah, 2
mov dl, 0ah
int 21h
mov dx, offset message3
mov ah,9
int 21h
mov ah, 2
mov dl, 0ah
int 21h
jmp start
ENDP Error

neg_result:
neg [result]
dec [result]
jo error
call Digit
jmp exit
neg_numberx:
neg [x]
jmp calculate
finalx:
mov [x],ax 
mov [check],0
cmp [check],1
jz neg_numberx
jmp inputy

neg_numbery:
neg [y]
jmp calculate
finaly:
mov [y],ax 
cmp [check],1
jz neg_numbery
jmp calculate

calculate: 
PROC Calculate

mov ax, [x]
mov bx, [y]
div bx
push dx
mov [result], ax
call Digit
mov cx, 7
mov bx,0
xor ax,ax
xor bx,bx
loop1:
;pop dx
;mov ax, 9
;mov bx, 3
;div bx
inc bx
mov [result],bx
;push dx
call DigitEnd
loop loop1
jmp back
ENDP Calculate

Start:
mov ax,@data
mov ds,ax
mov es,ax
mov [check],0
mov ax,03h
int 10h
call InputX
exit:
	mov ah, 4ch 
	mov al,[exCode] 
	int 21h	
end Start