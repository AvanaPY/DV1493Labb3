	.data
inbuf: 		.space 64
inbufOffset:	.quad 0

outBuf:		.space 64
outBufOffset:	.quad 0

	.text
	.global main

	.global inImage
	.global getInt
	.global getText
	.global getChar
	.global getInPos
	.global setInPos
	
	.global outImage
	.global putInt
	.global putText	
	.global putChar
	.global getOutPos
	.global setOutPos
main:
	# call inImage		# Get input from user
	call getChar
	movb %al, outBuf
	leaq outBuf, %rdi
	call puts		#

	ret	

inImage:
	movq $0, inbufOffset	# Reset inbufOffset to 0
	leaq inbuf, %rdi	# Point to inbuf
	movq $64, %rsi		# Max 64 characters
	mov stdin, %rdx		# From stdin
	call fgets		# call fgets
	ret

getInt:		# 
	ret
getText:
	ret
getChar: # takes inputbuf as rax and returns the first character of inputbuf/rax as rax
	leaq inbuf, %rax # move the adress of inbuf to rax
	movq inbufOffset, %rbx	# Move inbufOffset to rbx

	cmp $0, %rbx # if inbufOffset is 0
	je _getCharNotDone

	cmp $64, %rbx # if inbufoffset is above maxed
	je _getCharNotDone
_getCharContinue:
	movb (%rax,%rbx,1), %al	# Copy the character at inbufOffset from rax to cl
	add $1, inbufOffset
	ret
_getCharNotDone:
	call inImage
	movq inbufOffset, %rbx	# Move inbufOffset to rbx
	jmp _getCharContinue

getInPos:
	mov inbufOffset, %rax
	ret
setInPos:
	mov %rdi, inbufOffset
	ret


outImage:
	ret
putInt:
	ret
putText:
	ret
putChar:
	ret
getOutPos:
	ret
setOutPos:
	ret

