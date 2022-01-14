IDEAL
MODEL small
STACK 256

MACRO M_init
	mov ax,@data
	mov ds,ax
	mov es,ax
ENDM M_init

MACRO M_Exit
	mov ah, 4ch 
	mov al,[exCode] 
	int 21h	
ENDM M_Exit

DATASEG
enter_length_text db 'Enter the length of the array: ','$'
enter_array_text db  'Enter the array',10,'$'
error_text db 10, 'Convertation error','$'
large_text db 10, 'The number is too large','$'
sum_text db 10, 'Sum: ','$'
min_text db 10, 'Min: ','$'
max_text db 10, 'Max: ','$'
sorted_array_text db 10, 'Sorted: ','$'
input_string db 3, ?, 3 dup('?')
buffer db 7, ?, 7 dup('?')
array db 5 dup('?')
len dw 0
check dw 0
error_check db 0
large_check db 0
error db 0
min db 255
max db 0
exCode db 0
swapnum db 0

CODESEG
PROC InputLength
M_init
mov dx, offset enter_length_text
mov ah,9h
int 21h
lea dx, [buffer]
mov ah, 10
int 21h
mov ah, 2h
mov dl, 0ah
int 21h
call StrToInt
back:
ret
ENDP InputLength

PROC StrToInt
lea dx,[buffer]
add dx,2
mov bx,dx
mov bl,[bx]
mov al,[buffer+1]
mov cl,al
cmp bl,'-'
je negnumber
jmp posnumber
ret
ENDP StrToInt

negnumber: 
PROC NegativeNumber
dec cl
mov [check],1
inc dx
jmp posnumber
ret
ENDP NegativeNumber


posnumber:
PROC NumberPos
mov si,dx
mov di,10
xor ax,ax
xor bx,bx
loopl:
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
jz finally
jmp loopl
ret
ENDP NumberPos

numerror:
PROC DoError
mov ah, 2h
mov dl, 0ah
int 21h
lea dx,[error]
mov ah,9
int 21h
mov ah, 2h
mov dl, 0ah
int 21h
jmp start
ENDP DoError

jmp numerror
negative:
neg [len]
mov ax,[len]
mov [check],0
jmp back
finally:
mov [len],ax
mov ax,[len]
cmp [check],1
jz negative
jmp back
PROC CalculateSum
mov cx, [len]
lea bx, [array]
mov ax, 0
loops:
mov dx, 0
mov dl, [bx]
add ax, dx
inc bx
loop loops
push ax
mov ah, 9
lea dx, [sum_text]
int 21h
pop ax
call Digit
ret
ENDP CalculateSum
PROC MinMax
mov cx, [len]
lea bx, [array]

loopm:
mov ax, 0
mov al, [min]
cmp [bx], al
jb is_greater
tomin:
mov al, [max]
cmp [bx], al
ja is_less
tomax:
inc bx
loop loopm
mov ah, 9
lea dx, [min_text]
int 21h
mov ax, 0
mov al, [min]
call Digit
mov ah, 9
lea dx, [max_text]
int 21h
mov ax, 0
mov al, [max]
call Digit
ret
is_greater:
mov al, [bx]
mov [min], al
jmp tomin
is_less:
mov al, [bx]
mov [max], al
jmp tomax
ENDP MinMax
arrayinput:
PROC InputArray
mov [error], 0
mov ah, 9
lea dx, [enter_array_text]
int 21h
mov cx, [len]
lea bx, [array]

input_loop:
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
loop input_loop
ret
close:
mov [error], 1
ret
ENDP InputArray
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
ENDP ConvertArray
PROC PrintSorted
mov ah, 9
lea dx, [sorted_array_text]
int 21h
mov cx, [len]
lea bx, [array]
loopp:
push bx
push cx
mov ax, 0
mov al, [bx]
call Digit
pop cx
pop bx
mov ah, 2
mov dl, ' '
int 21h
inc bx
loop loopp
ret
ENDP PrintSorted
PROC SortArray
repeat:
mov [swapnum], 0
mov cx, [len]
lea bx, [array]
dec cx

loopc:
mov al, [bx]
mov dl, [bx + 1]
cmp al, dl
ja swap
sback:
inc bx
loop loopc
cmp [swapnum], 1
je repeat
ret
swap:
mov [swapnum], 1
mov [bx], dl
mov [bx + 1], al
jmp sback
ENDP SortArray
PROC Digit
mov cx, 0

m2:
mov dx, 0
mov bx, 10
div bx
add dl, '0'
push dx
inc cx
test ax, ax
jnz m2
mov ah, 2

m3:
pop ax
int 29h
loop m3
ret
ENDP Digit
Start:
call InputLength
call InputArray
cmp [error], 1
je close2
call CalculateSum
call MinMax
call SortArray
call PrintSorted
close2:
mov [error], 1
exit:
mov ah, 4ch
mov al,[exCode]
int 21h
end Start