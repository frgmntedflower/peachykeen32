.section .text
.global _start

@ ====================== TODOS ==========================
@	- Replace syscall-4 with wrapper function
@
@	- Finish "fwrite" impl.
@
@	- Come up with cooler commands t-t
@
@	- CMD to create files and directories
@
@	- CMD to print file content to stdout
@
@ =======================================================
.section .bss
	.lcomm rand_buff, 4	@ 4 bytes for reading the urandom file

.section .text
_start: 
.grrr:
	bl 	print_prompt
	bl 	await_input
	@bl 	print_usr_msg
	bl 	check_cmd
	b 	.grrr
	@bl 	exit_succ

check_cmd:
	@ !! Every command must set R6 to #1 at the start or crash !! @
	mov 	r6, 	#0

	@ fwrite checks
	ldr 	r0, =input_buff
	ldr 	r1, =fwrite_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq 	fwrite_handle 
	@ ----- fwrite checks -----
	
	@ help checks
	ldr 	r0, =input_buff
	ldr 	r1, =help_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq 	help_handle	
	@ ----- help checks -----

	@ exit checks
	ldr	r0, =input_buff
	ldr 	r1, =exit_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq	exit_succ
	@ ----- exit checks -----

	@ rng checks
	ldr	r0, =input_buff
	ldr 	r1, =rand_cmd
	bl	better_strcmp
	cmp	r0, #1
	beq	rand_handle
	@ ----- rand checks -----

	cmp 	r6, 	#1	@ If R6 not set to 1, an unkown command was entered 
	bne	.unknown_cmd

	bx 	lr		@ret bc everything is fine ^~^

	.unknown_cmd:
	ldr	r1, =unknown_msg
	ldr 	r2, =unknown_msg_len
	bl 	write_stdout
	b	.grrr

await_input:
	mov	r7, #3
	mov 	r0, #0
	ldr 	r1, =input_buff
	mov	r2, #input_buff_size
	svc	#0

	mov	r10, r0
	subs 	r10, r10, #1
	mov 	r3, #0
	strb	r3, [r1, r10]
	
	cmp 	r10, #0
	beq 	.grrr

	bx	lr 	@ret

print_usr_msg:
	mov 	r7, #4
	mov 	r0, #1
	ldr	r1, =input_buff
	mov 	r2, r10
	svc 	#0
	bx	lr	@ret

print_prompt:
	mov	r7, #4
	mov	r0, #1
	ldr	r1, =prompt
	mov 	r2, #14 
	svc 	#0
	bx	lr	@ret

exit_succ:
	mov 	r7, #1
	mov	r0, #0
	svc 	#0


@ ===== Command handles ===== @
fwrite_handle:
	mov 	r6, #1	@used for the unknown cmd check

	mov 	r7, #4
	mov 	r0, #1
	ldr	r1, =fwrite_cmd
	ldr 	r2, =fwrite_cmd_len
	svc 	#0
	bx	lr	@ret

help_handle:
	mov	r6, #1

	ldr	r1, =help_text
	ldr	r2, =help_text_len
	bl 	write_stdout
	bx	lr

rand_handle:
	mov	r6, #1

	bl	rand
	bx	lr

@ ===== utils ===== @
@ better_strcmp
@ desc - Better version of strcpy ^~^
@ arg1 - r0 = ptr to first string
@ arg2 - r1 = ptr to second string
@ ret - r0 = 1 (if equal) | r0 = 0 (if not equal)
better_strcmp:
.loop:
	ldrb 	r2, [r0], #1
	ldrb 	r3, [r1], #1
	cmp 	r2, r3		@ cmp, if not equal bytes then we done
	bne 	.done 
	cmp 	r2, #0		@ if we reach null term, string should be same
	bne 	.loop		@ if not, we go recursive t~t

	mov 	r0, #1
	bx 	lr
.done:
	mov 	r0, #0 
	bx 	lr


@ write_stdout
@ desc - Just a generic syscall-4 wrapper 
@ args - (see some linux syscall table)
write_stdout:
	@ assuming r1, r2 are set before
	mov 	r7, #0x4
	mov	r0, #1
	svc 	#0
	bx 	lr

@ rand
@ generate random number :3
rand:
	mov	r7, #322
	mov	r0, #-100
	ldr	r1, =dev_urandom
	mov	r2, #0
	mov	r3, #0
	svc 	#0
	mov 	r4, r0

	mov	r0, r4
	mov	r7, #3
	ldr	r1, =rand_buff	
	mov	r2, #4
	svc	#0

	ldr	r1, =rand_buff
	mov	r2, #4
	bl	write_stdout
	bx 	lr

@ ================== Data Section ===================== @
.section .rodata
	prompt: .ascii "peachykeen32> "
	prompt_len = .-prompt
	help_text: .asciz "Commands: nothing rn \^\~\^ \n"
	help_text_len = .-help_text
	.equ input_buff_size, 100
	.comm input_buff, input_buff_size
	unknown_msg: .asciz "Unknown command \>\~\< \n"
	unknown_msg_len = .-unknown_msg
	dev_urandom: .asciz "/dev/urandom"

	
	@ == command reserved keywords ==
	fwrite_cmd: .asciz "fwrite"
	fwrite_cmd_len = .-fwrite_cmd
	
	exit_cmd: .asciz "exit"
	exit_cmd_len = .-exit_cmd

	help_cmd: .asciz "help"
	help_cmd_len = .-help_cmd

	rand_cmd: .asciz "rand"
	rand_cmd_len = .-rand_cmd


