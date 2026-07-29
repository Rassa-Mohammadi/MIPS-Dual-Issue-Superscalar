        addi    $sp, $zero, 2048    # Lane 1
        add     $t0, $zero, $zero   # $t0 = F(0) = 0 - Lane 2
        addi    $t1, $zero, 1       # $t1 = F(1) = 1 - Lane 1
        addi    $a0, $zero, 8       # $a0 = Loop counter - Lane 2 
        nop                         
        nop                         
        nop                         
        nop                         
        nop                         
        nop                        
loop:
        add     $v0, $t0, $t1       # $v0 = F(n-1) + F(n-2) - Lane 1
        add     $t0, $t1, $zero     # Shift n-1 into n-2 - Lane 2
        addi    $a0, $a0, -1        # Decrement loop counter - Lane 1
        nop                         # Lane 2
        # delay slots for $v0 to reach write back
        nop                         # Lane 1
        nop                         # Lane 2
        nop                         # Lane 1
        nop                         # Lane 2
        nop                         # Lane 1
        nop                         # Lane 2     
        add     $t1, $v0, $zero     # Shift current result into n-1 - Lane 1
        nop                         # Lane 2
        # delay slots for $t1 to reach write back before loop starts again
        nop                         
        nop                         
        nop                        
        nop                         
        bnez    $a0, loop           # If counter != 0, loop again - Lane 1
        nop                         
        nop                         
        nop                         

done:
        j       done                # Lane 1
        nop                         
        nop                         
        nop                        