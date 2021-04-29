    .data
myText: .asciz "This is a test string!"
buf: .space 64

curr: .quad [buf]

    .text
    .global main

main:
    movq $myText, %rdi
    call putText
    call outImage
    ret
inImage:
    ret
outImage:
    call puts
    ret
setOutPos:
    ret
getOutPos:
    ret
putInt:
    ret
getInt:
    ret
putChar:
    ret
getText:
    ret
putText:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    
lPutTextDone:
    ret
