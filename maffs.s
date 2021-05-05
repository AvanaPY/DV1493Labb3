# gcc -no-pie -fPIC maffs.s -o a && ./a
	.data
inbuf: 		.space 64
inbufOffset:	.quad 0

outbuf:		.space 64
outbufOffset:	.quad 0

maxBufferSize: .quad 4

putTextTestString: .asciz "Hello there :D"

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
	leaq putTextTestString, %rdi
	call putText	
	call outImage
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
	mov inbufOffset, %rax		# 
	ret

setInPos:
	mov %rdi, inbufOffset		#
	ret


outImage:
	leaq outbuf, %rdi		# Load address of outbuf into rdi
	call puts			# put text on screen
	ret

putInt:
	ret

putText:
	mov %rdi, %rcx			# Save address
	mov $0, %rdi
_putTextLoop:
	movb (%rcx), %dil		# Move character to rdi
	cmp $0, %dil			# Check if character is null terminator
	je _putTextDone			# Done if null terminator
calll:
	call putChar			# put char into buffer
	inc %rcx				# move next char
	jmp _putTextLoop		# loop
_putTextDone:
	ret

putChar:  				# Puts char in %rdi into the output buffer
					# Calls the outImage function if the buffer is full
	pushq %rcx
	movq outbufOffset, %rax 	# Move offset to rax
	leaq outbuf, %rbx		# Load address to rbx
	movb %dil, (%rbx, %rax, 1)	# Put input to address
	inc %rax			#
	mov %rax, outbufOffset		# Update outbufOffset
	
	cmp maxBufferSize, %rax		#
	jl _putCharDone			# Jump if buffer is nto full
	movq $0, %rax			# 
	mov %rax, outbufOffset		# Reset outbufOffset
	call outImage			# Call out if buffer full
_putCharDone:
	popq %rcx
	ret

getOutPos:
	ret

setOutPos:
	ret

