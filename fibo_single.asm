        addi    $sp, $zero, 2048
        add     $t0, $zero, $zero   # $t0 = F(0) = 0
        addi    $t1, $zero, 1       # $t1 = F(1) = 1
        addi    $a0, $zero, 8       # $a0 = Loop counter 
        nop
        nop
        nop
loop:
        add     $v0, $t0, $t1       # $v0 = F(n-1) + F(n-2)
        add     $t0, $t1, $zero     # Shift n-1 into n-2
        nop 
        nop
        nop
        add     $t1, $v0, $zero     # Shift current result into n-1
        
        addi    $a0, $a0, -1        # Decrement loop counter
        nop
        nop
        nop
        nop
        bnez    $a0, loop           # If counter != 0, loop again
        nop                         
done:
        j       done               
	nop               
