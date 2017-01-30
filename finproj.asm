.data

m1: .asciiz "Welome to Lexathon!!! \n"
m2: .asciiz "1. Start Game \n"
m3: .asciiz "2. Instructions \n"
m4: .asciiz "3. Quit Game \n"
m5: .asciiz "LET'S BEGIN!!!\n"
m6: .asciiz "Goodbye.\n"
newline: .asciiz "\n"
space: .asciiz " "
p1: .asciiz "Please enter an option: \n"
r1: .asciiz "The rules of the game are simple. \n"
r2: .asciiz "You are given a grid of random letters, and you must discover as many words as\npossible that are 4 letters or more that also contain the central letter. \n"
CHARarry: .byte 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'

.text	
	.include "LexthathonEnd.asm"	
	.include "randomGrid.asm"	
	.include "timer.asm"	
	main: 
		
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
		
		#options for branching
		addi $t0, $zero, 1 #start game
		addi $t1, $zero, 2 #instructions
		addi $t2, $zero, 3 #end game
		
		beq $t0, $t3, option1
		beq $t1, $t3, option2
		beq $t2, $t3, option3
	
	option1:
	
		#print message
		li $v0, 4
		la $a0, m5
		syscall
		
		#i = 0
		addi $t0, $zero, 0
		
		#int for newline
		addi $t2, $zero, 3
		addi $t3, $zero, 7
		
		#while loop to print random 3x3 grid
		while:
			
			bgt $t0, 10, exit
			
			#print space
			li $v0, 4   #1 print integer
    			la $a0, space
    			syscall
			
			#if i = 3 or i = 6 add newline
			beq $t0, $t2, nline
			beq $t0, $t3, nline
			
			#generate random index
			li $a1, 15  #Here you set $a1 to the max bound.
    			li $v0, 42  #generates the random number.
    			syscall
    		
    			move $t1, $a0
    			#add $a0, $a0, 100  #Here you add the lowest bound
    			#li $v0, 4   #1 print integer
    			#la $a0, newline
    			#syscall
    		
    			#get random char
    			la $t7, CHARarry
    			add $t7, $t7, $t1
    		
    			lb $t6, 0($t7)
    		
    			#print char
    			li $v0, 11
    			move $a0, $t6
    			syscall
    		
    			#i++
    			addi $t0, $t0, 1
    			
    			j while
    		
    		nline: 
			li $v0, 4   
    			la $a0, newline
    			syscall
    			addi $t0, $t0, 1
    			j while
		exit:
			#end
			li $v0, 10
			syscall
		
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
		
