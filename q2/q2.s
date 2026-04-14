.section .data
fmt:    .asciz "%d "
nwlne:  .asciz "\n"
.section .text
.globl main
.extern atoi
.extern printf
.extern malloc
.extern free

main:
    # create stack frame and save important registers
    # we are using s0–s6, so we save them + ra
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)      # n
    sd s1, 40(sp)      # top of stack
    sd s2, 32(sp)      # loop variable i
    sd s3, 24(sp)      # arr[]
    sd s4, 16(sp)      # stack[]
    sd s5, 8(sp)       # ans[]
    sd s6, 0(sp)       # argv
    # n = argc - 1 because argv[0] is program name
    addi s0, a0, -1
    # store argv pointer
    mv s6, a1
    # initialize stack top = -1 (empty stack)
    li s1, -1
    # initialize i = 0
    li s2, 0
    # allocate memory for arr[n]
    # each int = 4 bytes → n * 4
    slli a0, s0, 2
    call malloc
    mv s3, a0	
    # allocate memory for stack[n]
    slli a0, s0, 2
    call malloc
    mv s4, a0
    # allocate memory for ans[n]
    slli a0, s0, 2
    call malloc
    mv s5, a0

#  Step 1: fill array and initialize ans
input_loop:
    # stop when i >= n
    bge s2, s0, exit1
    # get argv[i+1] (skip argv[0])
    # each argv entry is 8 bytes → i*8 + 8
    slli t0, s2, 3
    addi t0, t0, 8
    add t0, s6, t0
    # convert string to integer using atoi
    ld a0, 0(t0)
    call atoi
    # store integer in arr[i]
    slli t1, s2, 2
    add t1, s3, t1
    sw a0, 0(t1)
    # initialize ans[i] = -1 (default: no NGE)
    slli t1, s2, 2
    add t1, s5, t1
    li t2, -1
    sw t2, 0(t1)
    # move to next i
    addi s2, s2, 1
    j loop1

input_done:
    # reset i = 0 for main logic
    li s2, 0
# Step 2: Next Greater Element logic
# idea: use stack to store indices whose NGE is not found yet
nge_outer_loop:
    # stop when i >= n
    bge s2, s0, exit2

pop_stack_loop:
    # if stack empty → nothing to compare
    blt s1, x0, exit3
    # load current element arr[i]
    slli t0, s2, 2
    add t0, s3, t0
    lw t1, 0(t0)
    # get index at top of stack
    slli t2, s1, 2
    add t2, s4, t2
    lw t3, 0(t2)
    # get value arr[stack[top]]
    slli t4, t3, 2
    add t4, s3, t4
    lw t4, 0(t4)
    # if arr[stack[top]] >= arr[i]
    # then current element is not greater → stop popping
    bge t4, t1, exit3
    # otherwise arr[i] is next greater for stack[top]
    # so store index i in ans[stack[top]]
    slli t5, t3, 2
    add t5, s5, t5
    sw s2, 0(t5)
    # pop stack (top--)
    addi s1, s1, -1
    # continue popping until condition fails
    j loop3

stop_popping:
    # push current index i into stack
    # stack[++top] = i
    addi s1, s1, 1
    slli t0, s1, 2
    add t0, s4, t0
    sw s2, 0(t0)
    # move to next i
    addi s2, s2, 1
    j loop2

nge_done:
    # reset i = 0 for printing
    li s2, 0

# Step 3: print result
print_loop:
    # stop when i >= n
    bge s2, s0, exit4
    # load ans[i]
    slli t0, s2, 2
    add t0, s5, t0
    lw t1, 0(t0)
    # print ans[i]
    mv a1, t1
    la a0, fmt
    call printf
    # next i
    addi s2, s2, 1
    j loop4

print_done:
    # print newline
    la a0, nwlne
    call printf
	
    # Step 4: free memory
    mv a0, s3
    call free
    mv a0, s4
    call free
    mv a0, s5
    call free
    # restore registers and return
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5, 8(sp)
    ld s6, 0(sp)
    addi sp, sp, 64
    ret
