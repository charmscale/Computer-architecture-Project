.data
	gameOver:		.asciiz "GAME OVER\n"
	finalScore:		.asciiz "FINAL SCORE:\n"
	numberCorrectWords: 	.asciiz "NUMBER OF WORDS FOUND:\n"
	correctWordsMessage:	.asciiz "WORDS FOUND:\n"
	grid:			.space 9	#PUT THE GRID HERE
	dictionary:		.space 655360
	wordsfound:		.space 655360
	word:			.space 10
	wordcheck:		.space 10
	file:			.asciiz "Dictionary.txt"
	enterWord:		.asciiz "Enter a word (all caps) with 3 to 9 letters: "
	notgrid:		.asciiz "This word has letters that aren't in the grid. "
	notthere:		.asciiz "This is not a real word."
	valid:			.asciiz "This word is valid." 
	m1: 			.asciiz "Welome to Lexathon!!! \n"
	m2: 			.asciiz "1. Start Game \n"
	m3: 			.asciiz "2. Instructions \n"
	m4: 			.asciiz "3. Quit Game \n"
	m5: 			.asciiz "LET'S BEGIN!!!\n"
	m6: 			.asciiz "Goodbye.\n"
	m7:			.asciiz "You have "
	m8:			.asciiz " seconds remaining."
	space: 			.asciiz " "
	p1: 			.asciiz "Please enter an option: \n"
	r1: 			.asciiz "The rules of the game are simple. \n"
	r2: 			.asciiz "You are given a grid of random letters, and you must discover as many words as\npossible that are 4 letters or more that also contain the central letter. \n"
	CHARarry: 		.ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	
.text
		#$s0- score, $s7- size of words found, $s4- timer
main:		#this section opens and copies the file
		la $a0, file
		li $v0, 13
		li $a1, 0
		syscall					#open the file
		
		move $a0, $v0
		la $a1, dictionary
		li $a2,	655360
		li $v0, 14
		syscall					#copy the file
		
game:		li $s7, 0				#start the word counter at 0
		li $s0, 0
		
		#start time
		li $v0, 30
		syscall
		move $a0, $s4
		addi $s4, $s4, 60000
		
		#print messages and prompts
		li $v0, 4
		la $a0, m1
		syscall
	
		li $v0, 4
		la $a0, m2
		syscall
	
		li $v0, 4
		la $a0, m3
		syscall
	
		li $v0, 4
		la $a0, m4
		syscall
		
		#prompt user to enter option
		li $v0, 4
		la $a0, p1
		syscall
		
		#get user input
		li $v0, 5
		syscall
		
		
		#store input in $t3
		move $t3, $v0
	
		
		beq $t3, 1, option1
		beq $t3, 2, option2
		beq $t3, 3 option3
	
option1:
	
		#print message
		li $v0, 4
		la $a0, m5
		syscall
		
		#i = 0
		li $t0, 0
		
		#while loop to print random 3x3 grid
while:		bgt $t0, 10, exit
		#print space
		li $v0, 4   #1 print integer
    		la $a0, space
    		syscall
			
		#if i = 3 or i = 6 add newline
		beq $t0, 3, nline
		beq $t0, 6, nline
			
		#generate random index
back:		li $a1, 25  #Here you set $a1 to the max bound.
    		li $v0, 42  #generates the random number.
    		syscall
    		
    		move $t1, $a0
    		
    		#get random char
		lb $t6, CHARarry($t1)
    		
    		#print char
    		li $v0, 11
    		move $a0, $t6
    		syscall
			
		#save char
		sb $t6, grid($t0)
    		
    		#i++
    		addi $t0, $t0, 1
    			
    		j while
    		
 nline: 	li $v0, 11   
    		la $a0, 10
    		syscall
		j back
		
option2:
		
		#print instructions
		li $v0, 4
		la $a0, r1
		syscall
	
		li $v0, 4
		la $a0, r2
		syscall
		
		li $v0, 10
		syscall
		
option3:
		
		li $v0, 4
		la $a0, m6
		syscall
		
		li $v0, 10
		syscall
	
gettheword:	#this section fills both word and wordcheck with null because the next word might be shorter than the last
		li $t0, 0				#set iterator for fillword to 1

fillword:
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
		
		li $v0, 30				#check the time
		syscall
		bgt $a0, $s0, endsequence
		
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
		
		centercheck:	lb $t2, word($t0)
		addi $t0, $t0, 1
		beq $t1, $t2, next2			#look through the word, and continue if you find the center
		
		bne $t0, 9, centercheck				
		li $v0, 4
		la $a0, notcenter
		syscall
		j gettheword
		
		#This section checks each letter in the grid against each letter in the word, looping the grid on the outside and the
		#word on the inside. If a letter in the grid is the same as a letter in the word, it writes the letter in the 
		#same place in wordcheck, and then does what it would do if it had finished checking the word because letters in the
		# grid can't be used twice. After the entire grid has been checked, it compares wordcheck to word. If all the letters
		#have been found, the two will be identical. If they are not, it tells the user the word is not valid and goes back
		#to getting the word. 
		li $t0, 0				#set iterator for grid to 0
		
gridcheck:	li $t1, 0				#set iterator for word to 0
		lb $t2, grid($t0)			#load letter in grid
		
lettersgrid:	lb $t3, word($t1)			#load letter in word
		
		beq $t3, 0, iterategrid			#if entire word has been compared to grid letter, go iterate
		beq $t3, $t2, equal			#if the letters are the same, go note it and then iterate
		
		addi $t1, $t1, 1			# increments the lettersgrid loop
		
		j lettersgrid				#repeat the loop checking each letter in the word against a certain letter in the grid
		
equal:		lb $t4, wordcheck($t1)
		addi $t1, $t1, 1
		bne $t4, 0, lettersgrid			#if the letter has already been found, keep going
		subi $t1, $t1, 1
		sb $t3, wordcheck($t1)			#note that this letter has been found

iterategrid:	addi $t0, $t0, 1			#increments gridcheck loop
		bne $t0, 9, gridcheck			#if you haven't checked every letter in the grid, go to the next
		
		li $t0, 0				#set iterator for comparing wordcheck to word to 0
finalcheck:	lb $t2, word($t0)			#get the letter in word
		lb $t3, wordcheck($t0)			#get the letter in wordcheck
		
		addi $t0, $t0, 1			#increments the finalcheck loop
		
		bne $t2, $t3, notingrid			#if the letters aren't equal, not all the letters are in the grid		
		bne $t2, $zero, finalcheck		#if the word isn't done, loop
		
		j beginfound				#if the word is in the grid, check if it is in the dictionary
		
notingrid:	li $v0, 4
		la $a0, notgrid
		syscall					#prints that the letters aren't in the grid
		j gettheword
		
beginfound:	li $t0, 0

foundcheck:	li $t1, 0

foundloop:	lb $t2, word($t1)
		lb $t3, wordsfound($t0)
		
		bne $t2, $t3, iteratefound
		beq $t1, 8, wordfound
		
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		
		j foundloop
		
iteratefound:	subi $t1, $t1, 9
		sub $t1, $zero, $t1
		add $t0, $t0, $t1
		
		bne $t0, $s7, foundcheck
		
		j begincheck
		
wordfound:	li $v0, 4
		la $a0, alreadyfound
		syscall
		
		j gettheword
		
		#This section will check the word against the dictionary. Each dictionary word is nine characters, with null filling
		#in for all missing letters, so it will go through the copied file nine characters at a time, comparing each nine to
		#the word entered by the user. It will compare each character, looping when the characters aren't the same. If it 
		#gets to the end of the file without finding an identical word, it will tell the user the word isn't a real word and
		#loop back to asking for a word. 
		
begincheck:	li $t0, 0				#set iterator for file
		
dictcheck:	li $t1, 0				#set iterator for word
		
wordloop:	lb $t2, word($t1)			#gets letter in word
		lb $t3, dictionary($t0)			#gets letter in dictionary
		
		bne $t2, $t3, iteratedict		#if the words are not the same
		beq $t1, 8, wordvalid			#if all the letters have been checked, and the words are the same
		
		addi $t0, $t0, 1			#increments dictionary
		addi $t1, $t1, 1			#increments wordloop
		j wordloop				#if the letters are the same, and the entire word has not been checked, loop

iteratedict:	subi $t1, $t1, 9
		sub $t1, $zero, $t1			#gets the amount of word left, plus 1
		add $t0, $t0, $t1			#adds the amount to dictcheck iterator so that rest of word is skipped
		
		bne $t0, 655360, dictcheck		#if we have not reached the end of the file, check new word
		
		li $v0, 4
		la $a0, notthere
		syscall					#print the message if we have reached the end of the file
		
		j gettheword				#get another word

wordvalid:	li $v0, 4
		la $a0, valid
		syscall
		
		#this adds the word to the wordsfound list
		li $t0, 0
addword:	lb $t1, word($t0)
		sb $t1, wordsfound($s7)
		addi $t0, $t0, 1
		addi $s7, $s7, 1
		bne $t0, 9, addword
		
		#add to the score and the time
		addi $s0, $s0, 1
		addi $s4, $s4, 5000
		
		li $v0, 30
		syscall
		sub $t0, $s0, $a0
		divu $t0, $t0, 1000
		
		li $v0, 4
		la $a0, m7
		syscall
		
		li $v0, 1
		move $a0, $t0
		syscall
		
		li $v0, 4
		la $a0, m8
		syscall
		
		li $t0, 0
		li $v0, 11
printgrid:	beq $t0, 3, newline
backprint:	lb $a0, grid($t0)
		addi $t0, $t0, 1
		syscall
		la $a0, space
		syscall
		bne $t0, 9, printgrid
		j gettheword
		
newline:	li $a0, 10
		syscall
		j backprint
		
		#this is the end of the game			
endsequence:	li $v0, 4			#prints "GAME OVER" message
		la $a0, gameOver
		syscall
		
		la $a0, finalScore		#prints "FINAL SCORE: " message
		syscall
		
		li $v0, 1			#print integer
		move $a0, $s0			#load score
		syscall
		
		li $v0, 11			#skip line
		la $a0, 10
		syscall
					
		li $v0, 4			#prints "NUMBER OF WORDS FOUND" message
		la $a0, numberCorrectWords
		syscall
		
		divu $t0, $s7, 9
		li $v0, 1			#prints number of words player got correct
		move $a0, $t0			#register for word count
		syscall
		
		li $v0, 11			#skip line
		la $a0, 10
		syscall	
		
		li $v0, 4
		la $a0, correctWordsMessage
		syscall
		
		li $t0, 0			#set the iterator for the entire wordsfound
		li $t1, 0			#set the iterator for the word
		
correctword:	lb $a0, wordsfound($t0)		#load the character
		li $v0, 11
		syscall				#print the character
		
		addi $t0, $t0, 1		#increment entire list
		addi $t1, $t1, 1		#increment word
		bne $t1, 9, correctword		#if we haven't gotten to the end of the word, repeat
		li $t1, 0			#reset iterator for word
		
		li $v0, 11			#skip line
		la $a0, 10
		syscall
		
		bne $t0, $s7, correctword	#if we haven't gotten to the end of the list, repeat
		
		li $v0, 11			#skip line
		la $a0, 10
		syscall
		
		j game				#repeats the game


		
		
		
		
