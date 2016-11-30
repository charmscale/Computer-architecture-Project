.text
	li $v0, 30
	syscall
	
	addu $s2, $a0, $zero	#store starting time
	
	addiu $s2, $s2, 60000
	
start:	
	li $v0, 30
	syscall
	
	addu $t0, $a0, $zero 	#store changed time
	
	subu $t0, $s2, $t0
	
	bltz $t0, end
	
	j start
	
end: