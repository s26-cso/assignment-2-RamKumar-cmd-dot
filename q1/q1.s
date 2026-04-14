.section .data
node_size: .dword 24

.section .text
.globl make_node
.globl insert
.globl get
.globl get_At_Most
.globl malloc

# struct Node *
# long long val at offset 0 *
# Node* left at offset 8 *
# Node* right at offset 16 *
.globl make_node
make_node:
	# arguments (value in a0)
	# add stack
	addi sp, sp, -16
	# store return address
	sd ra, 8(sp)
	# store val
	sd a0, 0(sp)
	# allocate 24 bytes
	li a0, 24
	# call malloc to allocate memory
	call malloc
	# load val
	ld t0, 0(sp)
	# store val in node->val
	sd t0, 0(a0)
	# node->left = NULL
	sd x0, 8(a0)
	# node->right = NULL
	sd x0, 16(a0)
	# restore return address
	ld ra, 8(sp)
	# restore stack
	addi sp, sp, 16
	# return node pointer
	ret

.globl insert
insert:
	# arguments (root=a0, value=a1)
	# add stack
	addi sp, sp, -32
	# store return address
	sd ra, 16(sp)
	# store value
	sd a1, 8(sp)
	# store root
	sd a0, 0(sp)
	# if root == NULL create node
	beq a0, x0, create_node
	# load root->val
	ld t0, 0(a0)
	# if value < root->val go left
	blt a1, t0, left

right:
	# load root->right
	ld t1, 16(a0)
	# move to right child
	mv a0, t1
	# reload value
	ld a1, 8(sp)
	# recursive call
	call insert
	# restore original root
	ld t2, 0(sp)
	# update root->right
	sd a0, 16(t2)
	# return original root
	mv a0, t2
	j done

left:
	# load root->left
	ld t1, 8(a0)
	# move to left child
	mv a0, t1
	# reload value
	ld a1, 8(sp)
	# recursive call
	call insert
	# restore original root
	ld t2, 0(sp)
	# update root->left
	sd a0, 8(t2)
	# return original root
	mv a0, t2
	j done

create_node:
	# load value into a0
	ld a0, 8(sp)
	# call make_node
	call make_node

done:
	# restore return address
	ld ra, 16(sp)
	# restore stack
	addi sp, sp, 32
	# return
	ret

get:
	# arguments (a0=root, a1=value)
	# if root == NULL return
	beq a0, x0, not_found
	# load root->val
	ld t1, 0(a0)
	# if found
	beq a1, t1, found
	# if value < root->val go left
	blt a1, t1, go_left
	# else go right
	ld a0, 16(a0)
	j get

found:
	# return node pointer
	ret

go_left:
	# go to left child
	ld a0, 8(a0)
	j get

not_found:
	# return NULL
	mv a0, x0
	ret

.globl getAtMost
getAtMost:
	# arguments (value in a0, root in a1)
	# move value to t0
	mv t0, a0
	# move root to a0
	mv a0, a1
	# ans = -1
	li t1, -1

loop:
	# if root == NULL exit
	beq a0, x0, exit
	# load root->val
	ld t2, 0(a0)
	# if root->val <= value go right
	ble t2, t0, getright
	# else go left
	ld a0, 8(a0)
	j loop

getright:
	# update answer
	mv t1, t2
	# go right
	ld a0, 16(a0)
	j loop

exit:
	# return answer
	mv a0, t1
	ret
	