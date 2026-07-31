addi $t1, $zero, 5
addi $t2, $zero, 10

addi $t4, $zero, 20
addi $t5, $zero, 15

nop
nop

nop
nop

nop
nop

nop
nop # $t5 is ready

add $t0, $t1, $t2 # two independent instructions
sub $t3, $t4, $t5
