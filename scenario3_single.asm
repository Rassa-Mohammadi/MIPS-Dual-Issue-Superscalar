        addi $t1, $zero, 5
        addi $t2, $zero, 10
        addi $t4, $zero, 20
        addi $t5, $zero, 15
        addi $a0, $zero, 8
loop:
        
        addi $a0, $a0, -1
    
        bnez $a0, loop
done:
        j done