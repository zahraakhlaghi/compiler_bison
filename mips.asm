.data
     newline: .asciiz " " 
.text
main:
sw $t8,-4($sp)
sw $ra,-8($sp)
move $t8, $sp
addi $sp, $sp,-48
li $t2,'i'
sw $t0,-12($t8)
li $t0,3
sw $t0,-16($t8)
li $t0,2
sw $t0,-20($t8)
lw $t0,-16($t8)
sw $t0, -12($sp)
lw $t0,-20($t8)
sw $t0, -16($sp)
jal func
move $t0,$v0
sw $t0,-24($t8)
li $t0,0
sw $t0,-40($t8)
li $t2,'z'
sw $t0,-44($t8)
li $t0,0
sw $t0,-48($t8)

ForLoopStart1:
lw $t0,-48($t8)
sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,5

sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
slt $t0,$t0,$t1


beq $t0, $0, ForLoopEnd1
lw $t0,-40($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t0,-48($t8)

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-40($t8)
lw $t0,-48($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,1

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-48($t8)

j ForLoopStart1
ForLoopEnd1:li $t2,3
mul $t2,$t2,4
li $t3,-36
add $t3,$t3,$t8
add $t2,$t2,$t3
lw $t0,0($t2)
sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,0

sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
sgt $t0,$t0,$t1

beq $t0, $0, else2
li $t2,3
mul $t2,$t2,4
li $t3,-36
add $t3,$t3,$t8
add $t2,$t2,$t3
lw $t0,0($t2)
sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,10

sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
sgt $t0,$t0,$t1

beq $t0, $0, else3
li $t0,3

sw $t0,-24($t8)
lw $t0,-24($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,1

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-24($t8)
j ifEnded3
else3:
ifEnded3:
j ifEnded2
else2:
li $t0,0

sw $t0,-24($t8)
ifEnded2:
li $t0,0

sw $t0,-4($t8)
WhileLoopStart4:
lw $t0,-4($t8)
sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,9

sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
slt $t0,$t0,$t1

beq $t0, $0,Next4
lw $t0,-4($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,1

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-4($t8)
j WhileLoopStart4 
Next4:sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,1
sw $t0,-4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
seq $t0,$t0,$t1

beq $t0, $0, case5
lw $t0,-40($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,1

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-40($t8)
j endSwitch0
case5:
sw $t0,-4($sp)
addi $sp,$sp,-4
li $t0,2
sw $t0,-4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
seq $t0,$t0,$t1

beq $t0, $0, case6
lw $t0,-40($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,9

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-40($t8)
j endSwitch0
case6:
lw $t0,-40($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,3

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-40($t8)
j endSwitch0
endSwitch0:
li $v0, 10
syscall
func:
sw $t8,-4($sp)
sw $ra,-8($sp)
move $t8, $sp
addi $sp, $sp,-24
li $t0,0
sw $t0,-20($t8)
li $t0,1
sw $t0,-24($t8)

ForLoopStart7:
lw $t0,-24($t8)
sw $t0,-4($sp)
addi $sp,$sp,-4
lw $t0,-12($t8)

sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
sle $t0,$t0,$t1


beq $t0, $0, ForLoopEnd7
lw $t0,-20($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t0,-24($t8)
sw $t0, -12($sp)
jal square
move $t0,$v0

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-20($t8)
lw $t0,-24($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
li $t0,1

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
add $t0,$t0,$t1

sw $t0,-24($t8)

j ForLoopStart7
ForLoopEnd7:lw $t0,-20($t8)
move $v0,$t0
addi $sp, $sp, 24
lw $t8,-4($sp)
lw $ra,-8($sp)
jr $ra
square:
sw $t8,-4($sp)
sw $ra,-8($sp)
move $t8, $sp
addi $sp, $sp,-12
lw $t0,-12($t8)
sw $t0 -4($sp)
addi $sp,$sp,-4
lw $t0,-12($t8)

sw,$t0 -4($sp)
addi $sp,$sp,-4
lw $t1,0($sp)
addi $sp,$sp,4
lw $t0,0($sp)
addi $sp,$sp,4
mul $t0,$t0,$t1
move $v0,$t0
addi $sp, $sp, 12
lw $t8,-4($sp)
lw $ra,-8($sp)
jr $ra
