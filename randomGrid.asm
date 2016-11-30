.text
	add $t0, $zero, $zero
	for_row:
		beq $t0, 3, endRow
		add $t1, $zero, $zero
	for_col:
		beq $t1, 3, endCol
		
		li $v0, 42
		li $a0, 1
		li $a1, 25
		syscall
		
		add $a0, $a0, 65
		li $v0, 11
		syscall
		
		addi $t1, $t1, 1
		j for_col
	endCol:
		
		li $v0, 11
		la $a0, 10
		syscall
		
		addi $t0, $t0, 1		
		j for_row
		
	endRow:
			
