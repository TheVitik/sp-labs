IDEAL
MODEL small
STACK 256

MACRO M_init
	mov ax,@data
	mov ds,ax
ENDM M_init


DATASEG

mas db 13, 10, 'string ','$'
message1 db,'Enter a number: ','$'
message2 db,'Result is ','$'
message3 db 'Invalid type of number','$'

number dw 0
buffer db 7, ?, 7 dup('?')
check dw 0
exCode db 0

CODESEG

Start:
mov [check],0
mov ax,03h
int 10h
call Input

PROC Digit
M_init
mov dx, offset message2
mov ah,9
int 21h
mov dx, [number]
mov bx, [number]
or bx, bx

jns m1
mov al, '-'
int 29h
neg bx

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

PROC Input
M_init
mov dx, offset message1
mov ah,9h
int 21h

lea dx, [buffer]
mov ah, 10h
int 21h
;Переходимо на наступний рядок х3
mov ah, 2
mov dl, 0ah
int 21h
call StrToInt
ret
ENDP Input


PROC StrToInt
lea dx,[buffer]
add dx,2
mov bx,dx
mov bl,[bx]
mov al,[buffer+1]
mov cl,al
cmp bl,'-'

je NegativeNumber
jmp number_pos
ret
ENDP StrToInt

negnumber:
PROC NegativeNumber
dec cl
mov [check],1
inc dx
jmp number_pos
ret
ENDP NegativeNumber

PROC Error
;Переходимо на наступний рядок х3
mov ah, 2
mov dl, 0ah
int 21h
;Виводимо текст про помилку
mov dx, offset message3
mov ah,9
int 21h
;Переходимо на наступний рядок х3
mov ah, 2
mov dl, 0ah
int 21h
jmp start
ENDP Error

number_pos:
PROC NumberPos
mov si,dx
mov di,10
xor ax,ax
xor bx,bx
loop1:
mov bl,[si]
inc si

cmp bl,30h;
jl Error
cmp bl,39h
jg Error
sub bl,30h
mul di
jc Error
add ax, bx
jc Error
dec cl
cmp cl,0
jz final
jmp loop1
ret
ENDP NumberPos

neg_number:
neg [number]
add [number],23
jo Error
call Digit
jmp exit

final:
mov [number],ax
cmp [check],1
jz neg_number
add [number],23
call Digit
jmp exit

exit:
	mov ah, 4ch ;Завершуємо програму
	mov al,[exCode] ;Вихід з програми з кодом 0
	int 21h	

end Start