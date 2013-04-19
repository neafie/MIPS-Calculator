# Matthew Neafie -- 04/14/13
# HW4_MNeafie.asm – a simple program calculator for decimal numbers. 
# The calculator will maintain and display a current value (initially 0) and 
# a current operation (initially empty) after each user command.


.data
str1:  .asciiz	"\n\n------- Illegal input -------\n"
str2:	.asciiz	"value: "
str3:	.asciiz	"\toper: "
str5:	.asciiz	"enter: "
strnewl:.asciiz	"\n"

	.text
	.globl main
	
# function main -- written by Matthew Neafie -- 04/14/13
#       taking input, error checking, then calling the cal_fun function 
#		and display the results by calling prtstat function
# 	
#	An invalid character is entered as the operator. 
#	If a value is input to a given operator that is invalid, such as:
#	For divide: attempting to divide by 0.
#	For greatest common divisor: one of the numbers is 0.
#	For nchoosek:
#	n or k is negative.
#	k is larger than n.
#	n is larger than 30,such that we go out of bound.
# Register use:
#       $a0     syscall parameter
#       $a1     syscall parameter
#       $v0     syscall parameter
# 		$t1		temp var. used for operators
# 		$s5		global var. new value.
# 		$s6		global var. current value.
# 		$s7		global var. current oper.

main:
	li $s5, 0	# global var. new value.	
	li $s6, 0	# global var. current value.	
	li $s7, ' '	# global var. current oper.

loop:
	jal prtstat

	addi $v0, $0, 5		
	syscall				#reading value
	add $a1, $v0, 0		#storing first value
	
	beq $a1, -1000, oper #change oper
	add $s6, $a1, $0
	bne $s7, ' ', second
	j loop
	
oper:
	addi $v0, $0, 12    
	syscall      		#reading operator
	add   $a1, $v0, $0	#storing operator 
	
	addi $t1, $0, 0x2b
	beq $a1, $t1, good	#checking if +
	addi $t1, $0, 0x2d
	beq $a1, $t1, good	#checking if -
	addi $t1, $0, 0x2a
	beq $a1, $t1, good	#checking if *
	addi $t1, $0, 0x2f
	beq $a1, $t1, good	#checking if /
	addi $t1, $0, 0x40
	beq $a1, $t1, good	#checking if @
	addi $t1, $0, 0x26
	beq $a1, $t1, good	#checking if &
error:
	addi $v0, $0, 4  
	la   $a0, str1     
	syscall            	#print str1 if bad operator
	j main
good:
	add $s7, $a1, $0	
second:
	jal prtstat
	addi $v0, $0, 5		
	syscall				#reading value
	add $a1, $v0, 0		#storing second value
	beq $a1, -1000, oper #change oper
	add $s5, $a1, $0
	bne $s7, 0x2f, skip
	beq $s5, $0, error
skip:
	bne $s7, 0x40, skip2
	beq $s5, $0, error
	beq $s6, $0, error
skip2:
	bne $s7, 0x26, calfun
	blt $s5, $0, error
	blt $s6, $0, error
	blt $s6, $s5, error
	bgt $s6, 30, error
	
calfun:
	add $a0, $0, $s6
	add $a1, $0, $s7
	add $a2, $0, $s5
	jal cal_fun
	add $s6, $0, $v0
	j second
	
done:li $v0, 10	# exit
	syscall
	
#-----------------------------------
# function prtstat -- written by Zhenghao Zhang -- 
# just prints whatever in $s5, $s6, $s7
#-----------------------------------
prtstat:
	li $v0,4
	la $a0, strnewl
	syscall

	li $v0,4
	la $a0, str2
	syscall
	ori	$a0,$s6, 0
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, str3
	syscall
	ori	$a0,$s7, 0
	li $v0, 11
	syscall

	li $v0,4
	la $a0, strnewl
	syscall

	li $v0,4
	la $a0, str5
	syscall

	jr	$ra
	
#-----------------------------------
# function cal_fun -- written by Matthew Neafie -- 04/14/13
# Called when a calculation is needed and returns in $v0 the result.
# Error checking done by the caller and the values are valid.
# The first value, the operator, and the second value in $a0, $a1, and $a2.
# Handles simple things like +,-*,/ inside this function.
# Calls gcf and calnchoosek for @ and &. 
# Register use:
#       $a0     first value parameter
#       $a1     operator parameter
#       $a2     second value parameter
# 		$t1		temp var. used for operators
# 		$v0 	global storage used for return value
#-----------------------------------
cal_fun:
	
	addi $t1, $0, 0x2b
	beq $a1, $t1, addIt	#checking if +
	addi $t1, $0, 0x2d
	beq $a1, $t1, subIt	#checking if -
	addi $t1, $0, 0x2a
	beq $a1, $t1, mulIt	#checking if *
	addi $t1, $0, 0x2f
	beq $a1, $t1, divIt	#checking if /
	addi $t1, $0, 0x40
	beq $a1, $t1, ggcf	#checking if @
	addi $t1, $0, 0x26
	beq $a1, $t1, calnk	#checking if &
	
addIt:
	add $v0, $a0, $a2	#adding values
	jr $ra
subIt:
	sub $v0, $a0, $a2	#subtracting values
	jr $ra
mulIt:
	mul $v0, $a0, $a2	#multiplying values
	jr $ra
divIt:
	div $v0, $a0, $a2	#dividing values
	jr $ra
ggcf:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal gcf
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
calnk:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal calnchoosek
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j $ra

#-----------------------------------
# function gcf -- written by Matthew Neafie -- 04/14/13
# returns in $v0 the greatest common factor between two values
# $a0 and $a2 are the two values
# Register use:
#       $a0     first value parameter passed
#       $a2     second value parameter passed
# 		$t0		temp var. used for first value parameter
# 		$t1		temp var. used for second value parameter
# 		$v0 	global storage used for return value
#-----------------------------------
gcf:
	add $t0, $a0, $0
	add $t1, $a2, $0
loop1:
	beq $t1, $0, done1
	div $t0, $t1
	add $t0, $t1, $0
	mfhi $t1
	j loop1
done1:
	add $v0, $t0, $0
	jr	$ra
	
	
#-----------------------------------
# function calnchoosek -- written by Matthew Neafie -- 04/14/13
#	Recursive function to calculate N choose K
# 	C(n,k) = C(n-1,k) + C(n-1,k-1)
# 	returns in $v0 C(n,k)
# 	$a0 is n and $a2 is k
# Register use:
#       $a0     first value parameter 
#       $a2     second value parameter 
#		$f0
#		$f2
#		$f4
#		$f6
#		$f8
#		$f10
#-----------------------------------
calnchoosek: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	mtc1 $a0, $f0
	cvt.s.w $f0, $f0 	#f0 = a0 =n
	mtc1 $a2, $f2
	cvt.s.w $f2, $f2	#f2 = a2 =k

	sub.s $f4, $f0, $f2 #f4 = (n-k)
	mov.s $f6, $f0 		#n = $a0
	jal fact
	mov.s $f0, $f6		#a0 = result
	mov.s $f6, $f2		#n = $a1
	jal fact
	mov.s $f2, $f6		#a1 = result
	mov.s $f6, $f4		#n = n-k
	jal fact
	mov.s $f4, $f6		#(n-k)! = result
	
	mul.s $f2, $f2, $f4 #K!(n-k)!
	div.s $f0, $f0, $f2	#n!/result
	cvt.w.s $f6, $f0
	mfc1 $v0, $f6
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
fact:
	li.s $f8, 1.0 	#f8 = 1
	li.s $f10, 1.0  #f10 = result
	

factloop: 
	mul.s $f10, $f10, $f6
	c.lt.s $f8, $f6
	sub.s $f6, $f6, $f8
	bc1t factloop
	mov.s $f6, $f10
	jr $ra
