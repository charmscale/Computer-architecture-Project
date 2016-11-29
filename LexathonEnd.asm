.data
	gameOver		.asciiz "GAME OVER\n"
	finalScore		.asciiz "FINAL SCORE:\n"
	numberCorrectWords 	.asciiz "NUMBER OF WORDS FOUND:\n"
	correctWordsMessage	.asciiz "WORDS FOUND:\n"
	numberMissedWords 	.asciiz "NUMBER OF WORDS MISSED:\n"
	newLine			.asciiz "\n"
	grid:			.space 9	#PUT THE GRID HERE
	dictionary:		.space 663552
	wordsfound:		.space 663552
	word:			.space 10
	wordcheck:		.space 10
	file:			.asciiz "Dictionary.txt"
	enterWord:		.asciiz "Enter a word (all caps) with 3 to 9 letters: "
	notgrid:		.asciiz "This word has letters that aren't in the grid. "
	notthere:		.asciiz "This is not a real word."
	valid:			.asciiz "This word is valid." 
	playagain		.acsiiz "Would you like to play again? Enter 1 to continue, or 0 to quit." 
	
.text
main:		#this section opens and copies the file
		la $a0, file
		li $v0, 13
		li $a1, 0
		syscall					#open the file
		
		move $a0, $v0
		la $a1, dictionary
		li $a2,	663552
		li $v0, 14
		syscall					#copy the file
		
game:		#PUT SETUP HERE
		
gettheword:	#this section fills both word and wordcheck with null because the next word might be shorter than the last
		li $t0, 0				#set iterator for fillword to 1

fillword:	#PRINT THE PUZZLE
		li $t1, 0
		sb $t1, word($t0)
		sb $t1, wordcheck($t0)
		addi $t0, $t0, 1
		bne $t0, 10, fillword			#fill both word and wordcheck with null

		#this section gets the word from the user
		la $a0, enterWord
		li $v0, 4
		syscall					#ask for a word
				
		li $v0, 8
		la $a0, word
		li $a1, 9
		syscall					#get the word
		
		#A GOOD PLACE TO CHECK TO SEE IF TIME IS UP
		
		#This section eliminates the newline character in the word entered by the user
		li $t0, 0				#sets the iterator for nonewline
nonewline:	beq $t0, 10, next1			#exits loop if at the end of the word
		lb $t1, word($t0)			#loads the character
		addi $t0, $t0, 1			#increments nonewline
		bne $t1, 10, nonewline			#repeats if this is not a newline character
		sub $t0, $t0, 1				#reduces back to where the newline character is
		sb $zero, word($t0)			#replaces newline with null
		
		
next1:		lb $t1, word+2	
		beq $t1, $zero, gettheword		#check for 3 letters
		
		#This section checks each letter in the grid against each letter in the word, looping the grid on the outside and the
		#word on the inside. If a letter in the grid is the same as a letter in the word, it writes the letter in the 
		#same place in wordcheck, and then does what it would do if it had finished checking the word because letters in the
		# grid can't be used twice. After the entire grid has been checked, it compares wordcheck to word. If all the letters
		#have been found, the two will be identical. If they are not, it tells the user the word is not valid and goes back
		#to getting the word. 
		li $t0, 0				#set iterator for grid to 0
		
gridcheck:	li $t1, 0				#set iterator for word to 0

lettersgrid:	lb $t2, grid($t0)			#load letter in grid
		lb $t3, word($t1)			#load letter in word
		
		beq $t3, 0, iterategrid			#if entire word has been compared to grid letter, go iterate
		beq $t3, $t2, equal			#if the letters are the same, go note it and then iterate
		
		addi $t1, $t1, 1			# increments the lettersgrid loop
		
		j lettersgrid				#repeat the loop checking each letter in the word against a certain letter in the grid
		
equal:		sb $t3, wordcheck($t1)			#note that this letter has been found

iterategrid:	addi $t0, $t0, 1			#increments gridcheck loop
		bne $t0, 9, gridcheck			#if you haven't checked every letter in the grid, go to the next
		
		li $t0, 0				#set iterator for comparing wordcheck to word to 0
finalcheck:	lb $t2, word($t0)			#get the letter in word
		lb $t3, wordcheck($t0)			#get the letter in wordcheck
		
		addi $t0, $t0, 1			#increments the finalcheck loop
		
		bne $t2, $t3, notingrid			#if the letters aren't equal, not all the letters are in the grid		
		bne $t2, $zero, finalcheck		#if the word isn't done, loop
		
		j dictcheck				#if the word is in the grid, check if it is in the dictionary
		
notingrid:	li $v0, 4
		la $a0, notgrid
		syscall					#prints that the letters aren't in the grid
		j gettheword
		
		#This section will check the word against the dictionary. Each dictionary word is nine characters, with null filling
		#in for all missing letters, so it will go through the copied file nine characters at a time, comparing each nine to
		#the word entered by the user. It will compare each character, looping when the characters aren't the same. If it 
		#gets to the end of the file without finding an identical word, it will tell the user the word isn't a real word and
		#loop back to asking for a word. 
		
		li $t0, 0				#set iterator for file
		
dictcheck:	li $t1, 0				#set iterator for word

wordloop:	lb $t2, word($t1)			#gets letter in word
		lb $t3, dictionary($t0)			#gets letter in dictionary
		
		bne $t2, $t3, iteratedict		#if the words are not the same
		beq $t1, 9, wordvalid			#if all the letters have been checked, and the words are the same
		
		addi $t0, $t0, 1			#increments dictionary
		addi $t1, $t1, 1			#increments wordloop
		j wordloop				#if the letters are the same, and the entire word has not been checked, loop

iteratedict:	subi $t1, $t1, 10
		sub $t1, $zero, $t1			#gets the amount of word left, plus 1
		add $t0, $t0, $t1			#adds the amount to dictcheck iterator so that rest of word is skipped
		bne $t0, 663553, dictcheck		#if we have not reached the end of the file, check new word
		
		li $v0, 4
		la $a0, notthere
		syscall					#print the message if we have reached the end of the file
		
		j gettheword				#get another word

wordvalid:	li $v0, 4
		la $a0, valid
		syscall
		
		#INCREMENT THE SCORE, SAVE THE WORD, LOOP BACK TO GET ANOTHER WORD
		
showScore:				
		li $v0, 4			#prints "GAME OVER" message
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
		
showCorrectWords:			
		li $v0, 4			#prints "NUMBER OF WORDS FOUND" message
		la $v0, numberCorrectWords
		syscall
		
		li $v0, 1			#prints number of words player got correct
		move $a0, $s7			#register for word count
		syscall
		
		li $v0, 4			#skip line
		la $a0, newLine
		syscall
		
		li $v0, 4
		la $a0, correctWordsMessage
		syscall
		
		li $v0, 4			#correct words list appears here
		la $a0, correctWords
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
		
		li $v0, 4
		la $a0, playagain
		syscall				#asks if the player wants to play again
		
		li $v0, 5
		syscall				#gets answer
		
		beq $v0, 0, end			#jumps to exit
		
		li $v0, 4			#skip line
		la $a0, newLine
		syscall
		
		j game				#repeats the game

end:		li $v0, 10
		sycall				#exits
		
		
		
		
