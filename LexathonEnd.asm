.data
	gameOver		.asciiz "GAME OVER\n"
	finalScore		.asciiz "FINAL SCORE:\n"
	numberCorrectWords 	.asciiz "NUMBER OF WORDS FOUND:\n"
	numberMissedWords 	.asciiz "NUMBER OF WORDS MISSED:\n"
	tryAgain 		.asciiz "TRY AGAIN? ('1' = YES, '0' = NO): "
	
.text
	showScore:				#prints "GAME OVER" message
		li $v0, 4
		la $a0, gameOver
		syscall
		
		la $a0, finalScore		#prints "FINAL SCORE: " message
		syscall
		
		li $v0, 1			#print integer
		move $a0, $s4`			#load score
		syscall
		
		li $v0, 4			#skip line
		la $a0, newLine
		syscall
		
	showCorrectWords:			#prints "NUMBER OF WORDS FOUND" message
		li $v0, 4
		la $v0, numberCorrectWords
		syscall
		
		li $v0, 1			#prints number of words player got correct
		move $a0, $s7			#register for word count
		syscall
		
		li $v0, 4			#skip line
		la $a0, newLine
		syscall
				
	showTotalWords:
		li $v0, 4			#prints "NUMBER OF WORDS MISSED: " message
		la $v0, numberMissedWords
		syscall
		
		sub $s2, $s1, $s7		#obtain number of words missed
		
		li $v0, 1			#prints number of words player missed
		move $a0, $s2			#moving missed words for printing
		syscall
		
		li $v0, 4			#skip line
		la $a0, newLine
		syscall
		
		
