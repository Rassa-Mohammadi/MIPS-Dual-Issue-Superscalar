        addi $a0, $zero, 32      
        addi $t1, $zero, 1      

        addi $t3, $zero, 2      
        addi $t0, $zero, 5      

        addi $t2, $zero, 2      
        addi $t4, $zero, 3      

        addi $t5, $zero, 4      
        addi $t6, $zero, 5      

        addi $t7, $zero, 6      
        addi $t8, $zero, 7      

        addi $t9, $zero, 8      
        addi $v0, $zero, 9      

        addi $v1, $zero, 10     
        addi $s0, $zero, 11     

        addi $s1, $zero, 12     
        addi $s2, $zero, 13     

        addi $s3, $zero, 14     
        addi $s4, $zero, 15     

        addi $s5, $zero, 16     
        addi $s6, $zero, 17     

        addi $s7, $zero, 18     
        nop                     

loop:
        # cycle 1
        addi $a0, $a0, -1       
        addi $t0, $t0, 1        

        # cycle 2
        sub  $t2, $t2, $t3      
        and  $t4, $t4, $t3      

        # cycle 3
        or   $t5, $t5, $t3      
        xor  $t6, $t6, $t3      

        # cycle 4
        add  $t7, $t7, $t3      
        sub  $t8, $t8, $t3      

        # cycle 5
        and  $t9, $t9, $t3      
        or   $v0, $v0, $t3      

        # cycle 6
        xor  $v1, $v1, $t3      
        add  $s0, $s0, $t3      

        # cycle 7
        sub  $s1, $s1, $t3      
        and  $s2, $s2, $t3      

        # cycle 8
        or   $s3, $s3, $t3      
        xor  $s4, $s4, $t3      

        # cycle 9
        add  $s5, $s5, $t3      
        sub  $s6, $s6, $t3      

        # cycle 10
        and  $s7, $s7, $t3      
        or   $t1, $t1, $t3      

        # cycle 11
        xor  $t2, $t2, $t3      
        add  $t4, $t4, $t3      

        # cycle 12
        sub  $t5, $t5, $t3      
        and  $t6, $t6, $t3      

        # cycle 13
        or   $t7, $t7, $t3      
        xor  $t8, $t8, $t3      

        # cycle 14
        add  $t9, $t9, $t3      
        sub  $v0, $v0, $t3      

        # cycle 15
        and  $v1, $v1, $t3      
        or   $s0, $s0, $t3      

        # cycle 16
        xor  $s1, $s1, $t3      
        add  $s2, $s2, $t3      

        # cycle 17
        sub  $s3, $s3, $t3      
        and  $s4, $s4, $t3      

        # cycle 18
        or   $s5, $s5, $t3      
        xor  $s6, $s6, $t3      

        # cycle 19
        add  $s7, $s7, $t3      
        sub  $t1, $t1, $t3      

        # cycle 20
        and  $t2, $t2, $t3      
        or   $t4, $t4, $t3      

        # cycle 21
        addi $t3, $t3, 1        
        xor  $t5, $t5, $t0      

        # cycle 22
        add  $t6, $t6, $t0      
        sub  $t7, $t7, $t0      

        # cycle 23
        and  $t8, $t8, $t0      
        or   $t9, $t9, $t0      

        # cycle 24
        xor  $v0, $v0, $t0      
        add  $v1, $v1, $t0      

        # cycle 25
        sub  $s0, $s0, $t0      
        and  $s1, $s1, $t0      

        # cycle 26
        or   $s2, $s2, $t0      
        xor  $s3, $s3, $t0      

        # cycle 27
        add  $s4, $s4, $t0      
        sub  $s5, $s5, $t0      

        # cycle 28
        and  $s6, $s6, $t0      
        or   $s7, $s7, $t0      

        # cycle 29
        xor  $t1, $t1, $t0      
        add  $t2, $t2, $t0      

        # cycle 30
        sub  $t4, $t4, $t0      
        and  $t5, $t5, $t0      

        # cycle 31
        or   $t6, $t6, $t0      
        xor  $t7, $t7, $t0      

        # cycle 32
        add  $t8, $t8, $t0      
        sub  $t9, $t9, $t0      

        # cycle 33
        and  $v0, $v0, $t0      
        or   $v1, $v1, $t0      

        # cycle 34
        xor  $s0, $s0, $t0      
        add  $s1, $s1, $t0      

        # cycle 35
        sub  $s2, $s2, $t0      
        and  $s3, $s3, $t0      

        # cycle 36
        or   $s4, $s4, $t0      
        xor  $s5, $s5, $t0      

        # cycle 37
        add  $s6, $s6, $t0      
        sub  $s7, $s7, $t0      

        # cycle 38
        and  $t1, $t1, $t0      
        or   $t2, $t2, $t0      

        # cycle 39
        xor  $t4, $t4, $t0      
        add  $t5, $t5, $t0      

        # cycle 40
        sub  $t6, $t6, $t0      
        and  $t7, $t7, $t0      

        # cycle 41
        bnez $a0, loop          
        nop                     

        # cycle 42
        nop                     
        nop                     

done:
        j done                  