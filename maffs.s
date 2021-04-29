	.data
inbuf: 		.space 64
inbufOffset:	.quad 0

outBuf:		.space 64
outBufOffset:	.quad 0

	.text
	.global _main
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
_main:
	call inImage		# Get input from user

	leaq inbuf, %rdi	# Print input 
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
getChar:
	ret
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

