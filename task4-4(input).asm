IDEAL
MODEL small
STACK 256

MACRO M_init
	mov ax,@data
	mov ds,ax
	mov es,ax
ENDM M_init

DATASEG
enter_row_text db 'Enter the rows count of the array: ','$'
enter_column_text db 'Enter the columns count of the array: ','$'
enter_array_text db  'Enter the 2D array',10,'$'
enter_numbers_text db "Enter numbers for row $"
error_text db 10, 'Convertation error','$'
large_text db 10, 'The number is too large','$'
enter_number_text db 10,'Enter number to find', 10, 13, '$'
found_x db 10, 'X:', '$'
found_y db 'Y:', '$'
not_found_text db 10, 'The number not found','$'
input_string db 4, ?, 4 dup('?')
error_check db 0
large_check db 0
error db 0
rows db 0
columns db 0
array db 15 dup('?')
number db 0
number_found db 0
current_row db 0
bufferx db 7, ?, 7 dup('?')
buffery db 7, ?, 7 dup('?')
check dw 0
exCode db 0

CODESEG
PROC InputX
M_init
mov dx, offset enter_row_text
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
back:
ret
ENDP InputX

PROC InputY
M_init
mov dx, offset enter_column_text
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
jl numerror
cmp bl,39h
jg numerror
sub bl,30h
mul di
jc numerror
add ax, bx
jc numerror
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
jl numerror
cmp bl,39h
jg numerror
sub bl,30h
mul di
jc numerror
add ax, bx
jc numerror
dec cl
cmp cl,0
jz finaly
jmp loopy
ret
ENDP NumberPosY

numerror:
PROC DoError
mov ah, 2
mov dl, 0ah
int 21h
mov dx, offset error_text
mov ah,9
int 21h
mov ah, 2
mov dl, 0ah
int 21h
jmp start
ENDP DoError

neg_numberx:
neg [rows]
finalx:
mov [rows],al 
mov [check],0
cmp [check],1
jz neg_numberx
jmp inputy

neg_numbery:
neg [columns]
jmp back
finaly:
mov [columns],al 
cmp [check],1
jz neg_numbery
jmp back

PROC InputArray
mov [error], 0
mov ah, 9
lea dx, [enter_array_text]
int 21h
mov cx, 0
mov cl, [rows]
lea bx, [array]
rows_loop:
mov ah, 9
lea dx, [enter_numbers_text]
int 21h
push bx
push cx
inc [current_row]
mov ax, 0
mov al, [current_row]
call Digit
pop cx
pop bx
mov ah, 2
mov dl, 10
int 21h
mov dl, 13
int 21h
push cx
mov cx, 0
mov cl, [columns]
columns_loop:
mov ah, 10
lea dx, [input_string]
int 21h
push bx
push cx
call ConvertArray
pop cx
pop bx
cmp [large_check], 1
je close
cmp [error_check], 1
je close
mov [bx], al
mov ah, 2
mov dl, 10
int 21h
mov dl, 13
int 21h
inc bx
loop columns_loop
pop cx
loop rows_loop
ret
close:
mov [error], 1
ret
ENDP InputArray
PROC InputNumber
mov ah, 9
lea dx, [enter_number_text]
int 21h
mov ah, 10
lea dx, [input_string]
int 21h
call ConvertArray
cmp [large_check], 1
je exit_enter
cmp [error_check], 1
je exit_enter
mov [number], al
ret
exit_enter:
mov [error], 1
ret
ENDP InputNumber
PROC FindNumber
mov ax, 0
mov al, [rows]
mul [columns]
mov cx, ax
lea bx, [array]
loopf:
mov al, [number]
cmp [bx], al
je number_match
fback:
inc bx
loop loopf
ret
number_match:
inc [number_found]
mov ah, 9
lea dx, [found_x]
int 21h
push bx
push cx
mov ax, bx
lea bx, [array]
sub ax, bx
mov bx, ax
div [columns]
mov ah, 0
push bx
push ax
call Digit
mov ah, 2
mov dl, ' '
int 21h
pop ax
pop bx
mov ah, 9
lea dx, [found_y]
int 21h
mul [columns]
sub bx, ax
mov ax, bx
call Digit
pop cx
pop bx
jmp fback
ENDP FindNumber
PROC ConvertArray
mov [large_check], 0
mov [error_check], 0
mov cx, 0
mov cl, [input_string + 1]
lea si, [input_string + 2]
mov ax, 0
loop1:
mov bx, 0
mov bl, '0'
cmp [si], bl
jl not_number
mov bl, '9'
cmp [si], bl
jg not_number
mov bl, '0'
sub [si], bl
mov bl, 10
mul bl
jo overflow
mov bl, [si]
add ax, bx
inc si
loop loop1
ret
not_number:
mov [error_check], 1
lea dx, [error_text]
mov ah, 9
int 21h
ret
overflow:
mov [large_check], 1
lea dx, [large_text]
mov ah, 9
int 21h
ret
ENDP ConvertArray
PROC Digit
mov cx, 0
m2:
mov dx, 0
mov bx, 10
div bx
mov bl, '0'
add dl, bl
push dx
inc cx
test ax, 0ffh
jnz m2
mov ah, 2
m3:
pop dx
int 21h
loop m3
ret
ENDP Digit

Start:
M_init
mov ax,03h
int 10h
call InputX
call InputArray
cmp [error], 1
je exit
call InputNumber
cmp [error], 1
je exit
call FindNumber
cmp [number_found], 0
je number_not_found

exit:
mov ah, 4ch
mov al,[exCode]
int 21h
number_not_found:
mov ah, 9h
lea dx, [not_found_text]
int 21h
jmp exit
end Start