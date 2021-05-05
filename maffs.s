# gcc -no-pie -fPIC maffs.s -o a && ./a
	.data
inbuf: 		.space 64
inbufOffset:	.quad 0

outbuf:		.space 64
outbufOffset:	.quad 0

maxBufferSize: .quad 4

	.text
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
	.global main
main:
	#call inImage		# Get input from user
	
	mov $'H', %rdi
	call putChar
	
	mov $'e', %rdi
	call putChar

	mov $'l', %rdi
	call putChar
	
	mov $'l', %rdi
	call putChar

	mov $'o', %rdi
	call putChar
	
	mov $0, %rdi
	call putChar

	#call outImage
	ret	

inImage:
	movq $0, inbufOffset	# Reset inbufOffset to 0
	leaq inbuf, %rdi	# Point to inbuf
	movq maxBufferSize, %rsi		# Max 64 characters
	mov stdin, %rdx		# From stdin
	call fgets		# call fgets
	ret

getInt:
	ret

getText:
	ret

getChar:
	leaq inbuf, %rax 	# move the adress of inbuf to rax
	movq inbufOffset, %rbx	# Move inbufOffset to rbx

	cmp $0, %rbx 		# if inbufOffset is 0
	je _getCharNotDone

	cmp maxBufferSize, %rbx	# if inbufoffset is above maxed
	je _getCharNotDone
_getCharContinue:
	movb (%rax,%rbx,1), %al	# Copy the character at inbufOffset from rax to cl
	add $1, inbufOffset	# increment inbufOffset
	ret
_getCharNotDone:
	call inImage		# grab new input
	movq inbufOffset, %rbx	# Move inbufOffset to rbx
	jmp _getCharContinue


getInPos:
	mov inbufOffset, %rax
	ret

setInPos:
	mov %rdi, inbufOffset
	ret


outImage:
	leaq outbuf, %rdi
	call puts
	ret

putInt:
	ret

putText:
	ret

putChar:  				# Puts char in %rdi into the output buffer
					# Calls the outImage function if the buffer is full
	movq outbufOffset, %rax 	# Move offset to rax
	leaq outbuf, %rbx		# Load address to rbx
	movb %dil, (%rbx, %rax, 1)	# Put input to address
	inc %rax
	mov %rax, outbufOffset
	
	cmp maxBufferSize, %rax
	jl _putCharDone
	movq $0, %rax
	mov %rax, outbufOffset
	call outImage
_putCharDone:
	ret

getOutPos:
	ret
setOutPos:
	ret

