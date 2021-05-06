# gcc -no-pie -fPIC maffs.s -o a && ./a
	.data
inbuf: 		.space 64
inbufOffset:	.quad 0

outbuf:		.space 64
outbufOffset:	.quad 0

maxBufferSize: .quad 64

putTextTestString: .asciz "Hello there :D"

	.text
	.global inImage
	.global getInt
	.global get12345Text
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
	call inImage
	call getInt
	call getInt	
	movq $0, %rbx	
	ret

#############
#
# Reads user input and puts it into the inbuf buffer
#
#############
inImage:
	movq $0, inbufOffset	# Reset inbufOffset to 0
	leaq inbuf, %rdi	# Point to inbuf
	movq maxBufferSize, %rsi		# Max 64 characters
	mov stdin, %rdx		# From stdin
	call fgets		# call fgets
	ret

##############
#
# Reads from the current inbuf buffer position
# and converts the text into a number that it returns in %rax
#
# Arguments:
#
# Returns:
#	%rax - A single int
#
##############
getInt:
	movq $0, %rax 			# resets the int register to 0
	movb $0, %r8b 			# r(8b = 0) == positive, (r8b = 1) == negative
	movq inbuf, %rcx		# Move inbufOffset to rcx
	cmp $0, %rcx 			# if inbuf is 0 or "empty"
	je inImage
	movq inbufOffset, %rcx	# Move inbufOffset to rcx
	cmp $64, %rcx 			# if inbufoffset is above maxed
	jge inImage
_getIntSpaceCheck:
	movq inbufOffset, %rcx 	# loads inbufOffset into rcx
	leaq inbuf, %rdx 		# loads inbuf into rdx
	movb (%rdx, %rcx, 1), %bl # loads the next character from inbuf
	cmp $32, %bl 			# checks if the character is a space
	je _getIntincOneAndLoop 		# loops and checks again
	jmp _getIntposOrMinCheck
_getIntincOneAndLoop: 			# loops and checks again
	inc %rcx
	movq %rcx, inbufOffset
	jmp _getIntSpaceCheck
_getIntposOrMinCheck: 			# checks if the first character are either a + or -
	cmp $45, %bl 			# is minus?
	je _getIntsetMin
	cmp $43, %bl 			# is plus?
	je _getIntsetPos
	jmp _getIntloop
_getIntsetMin:
	mov $1, %r8b
_getIntsetPos:
	inc %rcx
	movq %rcx, inbufOffset
	jmp _getIntloop
_getIntloop:
	movq inbufOffset, %rcx 	# loads inbufOffset into rcx
	leaq inbuf, %rdx 		# loads inbuf into rdx
	movb (%rdx, %rcx, 1), %bl # loads the next character from inbuf
	sub $'0', %bl 			# makes the "char" 0 based
	cmp $0, %bl
	jl _getIntDone 			# jump if lower than 0 (and therefor not a number)
	cmp $9, %bl
	jg _getIntDone 			# jump if greater than 9(and therefor not a number)
	imul $10, %rax 
	add %bl, %al
	inc %rcx
	movq %rcx, inbufOffset
	jmp _getIntloop
_getIntmakeNegative: 				# makes the sum negative before returning
	neg %rax
	ret
_getIntDone:
	cmp $1, %r8b 			# if r8b == 1 (aka the number had a - before it)
	je _getIntmakeNegative 		# makes the sum negative before returning
	ret 					# answer should sit in rax

##############
#
# HURR DUUUUUR
#
##############
getText:
	ret

##############
#
# Returns the current character in the current inbuffer position in %rax
# This also calls inImage if the buffer is empty
#
#############
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

##################
#
# Returns the current inbuffer position in %rax
#
#################
getInPos:
	mov inbufOffset, %rax		# 
	ret

###################
#
# Sets the current inbuffer position
#
##################
setInPos:
	mov %rdi, inbufOffset		#
	ret

###################
#
# Outputs the full outbuffer as text
#
##################
outImage:
	leaq outbuf, %rdi		# Load address of outbuf into rdi
	call puts			# put text on screen
	ret

#################
#
# HURR DUUUUUR
#
#################

putInt:
	ret

################
#
# Puts some text into the out buffer 
#
# Arguments:
#	%rdi - Address to asciz string
#
################
putText:
	mov %rdi, %rcx			# Save address
	mov $0, %rdi
_putTextLoop:
	movb (%rcx), %dil		# Move character to rdi
	cmp $0, %dil			# Check if character is null terminator
	je _putTextDone			# Done if null terminator
	call putChar			# put char into buffer
	inc %rcx				# move next char
	jmp _putTextLoop		# loop
_putTextDone:
	ret


################
#
# Puts a character into the out buffer
#
# Arguments:
# 	%rdi - ascii character
#
################
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

####################
#
# Returns the current position in the out buffer
#
# Returns:
#	%rax - Outbuffer position
#
####################
getOutPos:
	ret

##################
#
# Sets the current position in the out buffer
# 
# Arguments:
# 	%rdi - Integer
#
##################

setOutPos:
	ret

