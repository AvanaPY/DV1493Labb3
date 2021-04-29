	.data
textOut:	.asciz "This is a string :D"
textOut2:	.asciz "| :D This is also a string :D"
buf: 		.space 64
bufCount: 	.quad 0

	.text
	.global main

main:
	mov $textOut, %rdi
	leaq buf, %rsi
	call cpyStrTo 

	mov $textOut2, %rdi
	leaq buf, %rsi
	call cpyStrTo

label:
	mov $buf, %rdi
	call putText
	ret

cpyStrTo: # copies rdi to rsi
	movq %rdi, %rax 	# Move pointer to first character to rax 
cpyStrLoop:
	movb (%rax), %bl	# Move character to bl
	movq bufCount, %rdi	# Move bufCount to rdi
	cmp $0, %bl		# Compare value to 0 (NULL terminator checking)
	je lcpyStrDone		# Done if hit null terminator	
	movb %bl, (%rsi,%rdi,1)	# Copy character to target address plus bufCount offset
	add $1, %rax		# Increment character pointer
	add $1, bufCount	# Increment bufCount
	jmp cpyStrLoop		# Loop print
lcpyStrDone:
	ret
putText: # rdi contains a string
	call puts
	ret
