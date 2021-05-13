# gcc -no-pie -fPIC maffs.s -o a && ./a
	.data
inbuf: 		.space 64 
inbufOffset:	.quad 0

outbuf:		.space 64
outbufOffset:	.quad 0

maxBufferSize: .quad 64

putTextTestString: .asciz "Hello there :D"
testGetTextSpace:	.space 25

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

#############
#
# Reads user input and puts it into the inbuf buffer
#
# Arguments: 
#	-
# 
# Returns:
#	-
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
	movq inbuf, %rcx		# Move inbufOffset to rcx
	cmp $0, %rcx 			# if inbuf is 0 or "empty"
	jne _getIntEmptyBufferSkip
	call inImage
	jmp _getIntSpaceCheck
_getIntEmptyBufferSkip:
	movq inbufOffset, %rcx	# Move inbufOffset to rcx
	cmp maxBufferSize, %rcx 			# if inbufoffset is above maxed
	jl _getIntSpaceCheck
	call inImage
_getIntSpaceCheck:
	movq $0, %rax 			# resets the int register to 0
	movb $0, %r8b 			# r(8b = 0) == positive, (r8b = 1) == negative
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
	add $1, inbufOffset
	ret 					# answer should sit in rax

##############
#
# Moves text from inbuf to allocated buffer position
#
# Arguments:
#	%rdi - Address to buffer
#	%rsi - Max numof characters to be moved
#
# Returns:
#	%rax - Actual characters move
#
##############
getText:
	movq %rdi, %rdx		# Move address to other register as we'll use getChar to get the current char
	movq %rsi, %rcx		# Amount of characters to be moved
	movq $0, %r14
	movq inbufOffset, %rax
	cmp %rax, maxBufferSize
	jne _getTextLoop
	call inImage 
_getTextLoop:
	call getChar
	mov %rax, (%rdx)
	inc %rdx
	inc %r14
	dec %rcx
	cmp $0, %rcx		# If we have moved max characters
	je _getTextDone
	cmp $0, %al		# If %al is a null terminator
	je _getTextDone
	jmp _getTextLoop
_getTextDone:
	movq %r14, %rax
	ret

##############
#
# Returns the current character in the current inbuffer position in %rax
# This also calls inImage if the buffer is empty
#
# Arguments:
#	-
#
# Returns:
#	-
#
#############
getChar:
	push %rdx
	leaq inbuf, %rax 	# move the adress of inbuf to rax
	movq inbufOffset, %rbx	# Move inbufOffset to rbx
	cmp $0, inbuf 		# if inbuf is empty e.g it starts with a null terminator
	je _getCharNotDone

	cmp maxBufferSize, %rbx	# if inbufoffset is above maxed
	je _getCharNotDone
_getCharContinue:
	movb (%rax,%rbx,1), %al	# Copy the character at inbufOffset from rax to cl
	add $1, inbufOffset	# increment inbufOffset
	pop %rdx
	ret
_getCharNotDone:
	call inImage		# grab new input
	movq inbufOffset, %rbx	# Move inbufOffset to rbx
	jmp _getCharContinue

##################
#
# Returns the current inbuffer position in %rax
#
# Arguments:
#	-
#
# Returns:
#	%rax - Integer
#
#################
getInPos:
	mov inbufOffset, %rax		# 
	ret

###################
#
# Sets the current inbuffer position.
# Limits the position value to [0, maxBufferSize]
#  
# Arguments:
# 	%rdi - int
#
# Returns:
#	-
#
##################
setInPos:
	cmp $0, %rdi
	jl _setInPosLZ
	cmp maxBufferSize, %rdi
	jg _setInPosGM
	jmp _setInPosDone 	
_setInPosLZ:
	movq $0, %rdi
	jmp _setInPosDone
_setInPosGM:
	movq maxBufferSize, %rdi
_setInPosDone:	
	mov %rdi, inbufOffset		#
	ret

###################
#
# Outputs the full outbuffer as text
#
# Arguments:
#	-
#
# Returns:
#	-
#
##################
outImage:
	movq $0, %rdi
	call putChar
	movq $0, outbufOffset
	leaq outbuf, %rdi		# Load address of outbuf into rdi
	call puts			# put text on screen
	ret

#################
#
# Puts int from rax to outbuf in string format
# 
# Arguments:
# 	%rax - int
#
# Returns:
#	-
#
#################
putInt:
	movb $0, %r8b 	# (r8b = 0) == positive, (r8b = 1) == negative
	movq $10, %rbp
	pushq %rbp
	cmp $0, %rdi
	jl _putIntMinus
_putIntLoop:
	cmp $9, %rdi # is rax 10 or more? Then we can divide it with 10, otherwise we jump away
	jle _putIntEnd

	mov $0, %edx

	movq $10, %rcx
	movq %rdi, %rax
	div %rcx # saves the rest in rdx and the divided in rax!
	movq %rax, %rdi
	pushq %rdx
	jmp _putIntLoop
_putIntEnd:
	pushq %rdi
	cmp $1, %r8b
	je _putIntAddMinus
_putIntUnStacking:
	popq %rdi
	cmp $10, %rdi
	je _putIntReturnNQuit

	addq $'0', %rdi
	call putChar
	jmp _putIntUnStacking
_putIntReturnNQuit:
	ret

_putIntAddMinus:
	movq $45, %rdi
	call putChar
	jmp _putIntUnStacking

_putIntMinus:
	mov $1, %r8b
	not %rdi
	inc %rdi
	jmp _putIntLoop

################
#
# Puts some text into the out buffer 
#
# Arguments:
#	%rdi - Address to asciz string
#
# Returns:
# 	-
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
# Returns:
# 	-
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
# Arguments:
#	-
#
# Returns:
#	%rax - Integer - Outbuffer position
#
####################
getOutPos:
	movq outbufOffset, %rax
	ret

##################
#
# Sets the current position in the out buffer
# 
# Arguments:
# 	%rdi - Integer
#
# Returns:
#	-
#
##################

setOutPos:
	cmp $0, %rdi			# Compare 0
	jl _setOutPosLZ			# 
	cmp maxBufferSize, %rdi		# Compare max
	jg _setOutPosGM			#
	jmp _setOutPosDone 		#
_setOutPosLZ:
	movq $0, %rdi			# If is less
	jmp _setOutPosDone		#
_setOutPosGM:
	movq maxBufferSize, %rdi	# If is greater
_setOutPosDone:	
	mov %rdi, outbufOffset		#
	ret
