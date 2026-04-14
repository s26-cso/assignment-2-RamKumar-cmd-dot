.section .data
filename: .string "input.txt"
mode:     .string "r"
yes_msg:  .string "Yes\n"
no_msg:   .string "No\n"

.section .text
.globl main

.extern fopen
.extern fseek
.extern ftell
.extern fgetc
.extern fclose
.extern printf
.extern exit

main:
    # make stack space and save return address
    addi sp, sp, -16
    sw ra, 0(sp)
    # open the file in read mode
    la a0, filename
    la a1, mode
    call fopen
    mv s0, a0
    # move pointer to end to find file size
    mv a0, s0
    li a1, 0
    li a2, 2
    call fseek
    # get current position which gives total size
    mv a0, s0
    call ftell
    mv s1, a0
    # initialize two pointers for checking
    li t0, 0
    addi t1, s1, -1

check_loop:
    # stop when both pointers meet
    bge t0, t1, is_pal
    # go to left index and read character
    mv a0, s0
    mv a1, t0
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    mv t2, a0
    # go to right index and read character
    mv a0, s0
    mv a1, t1
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    mv t3, a0
    # skip newline if found on left or right
    li t4, 10
    beq t2, t4, inc_left
    beq t3, t4, dec_right
    # compare both characters
    bne t2, t3, not_pal
    # move both pointers inward
    addi t0, t0, 1
    addi t1, t1, -1
    j check_loop

inc_left:
    # skip left newline
    addi t0, t0, 1
    j check_loop

dec_right:
    # skip right newline
    addi t1, t1, -1
    j check_loop

is_pal:
    # print yes if palindrome
    la a0, yes_msg
    call printf
    j do_exit

not_pal:
    # print no if mismatch
    la a0, no_msg
    call printf

do_exit:
    # close file before exiting
    mv a0, s0
    call fclose
   # restore and return
    lw ra, 0(sp)
    addi sp, sp, 16
    li a0, 0
    ret
    
    
