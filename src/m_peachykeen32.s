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


.section .text
_start: 
.grrr:
	bl 	print_prompt
	bl 	await_input
	bl 	check_cmd
	b 	.grrr

check_cmd:
	@ !! Every command must set R6 to #1 at the start or crash !! @
	mov 	r6, 	#0
	
	push	{lr} 		@ Save link register entry for check_cmd on stack

	@ exit checks
	ldr	r0, =arg1_cli_buff
	ldr 	r1, =exit_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq	exit_handle
	@ ----- exit checks -------

	@ fwrite checks
	ldr 	r0, =arg1_cli_buff
	ldr 	r1, =fwrite_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	
	beq 	fwrite_handle
	.fwrite_done:
	@ ----- fwrite checks -----
	
	@ help checks
	ldr 	r0, =arg1_cli_buff
	ldr 	r1, =help_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq 	help_handle
	.help_done:
	@ ----- help checks -----

	@ ndir checks
	ldr	r0, =arg1_cli_buff
	ldr 	r1, =ndir_cmd
	bl 	better_strcmp
	cmp 	r0, #1
	beq	ndir_handle
	.ndir_done:
	@ ----- ndir checks -------
	
	@ rng checks
	ldr	r0, =arg1_cli_buff
	ldr 	r1, =rand_cmd
	bl	better_strcmp
	cmp	r0, #1
	beq	rand_handle
	.rand_done:
	@ ----- rand checks -----


	cmp 	r6, 	#1	@ If R6 not set to 1, an unkown command was entered 
	bne	.unknown_cmd

	pop 	{lr}		@ restore link register from stack before ret
	bx 	lr		@ ret bc everything is fine ^~^

	.unknown_cmd:
	ldr	r1, =unknown_msg
	ldr 	r2, =unknown_msg_len
	bl 	write_stdout
	b	.grrr

await_input:
	push {lr}

	mov  r7, #3              @ syscall: read
	mov  r0, #0              @ stdin
	ldr  r1, =input_buff     @ temp read buffer
	mov  r2, #input_buff_size
	svc  #0                  @ read(input_buff, size)

	mov  r10, r0             @ r10 = byte count
	ldr  r0, =input_buff     @ r0 = input pointer
	ldr  r4, =arg1_cli_buff  @ r4 = dest1
	ldr  r5, =arg2_cli_buff  @ r5 = dest2
	ldr  r6, =arg3_cli_buff  @ r6 = dest3

	mov  r7, #0              @ arg index: 0=arg1, 1=arg2, 2=arg3
	mov  r9, #0              @ byte index in word

	.read_loop:
	cmp  r10, #0
	beq  .fin

	ldrb r1, [r0], #1        @ load byte from input
	subs r10, r10, #1

	cmp  r1, #' '
	beq  .next_word

	cmp  r1, #10             @ newline?
	beq  .fin

	cmp  r7, #0
	beq  .write_arg1
	cmp  r7, #1
	beq  .write_arg2
	cmp  r7, #2
	beq  .write_arg3
	b    .read_loop          @ ignore extra words

	.write_arg1:
	strb r1, [r4], #1
	b .read_loop
	.write_arg2:
	strb r1, [r5], #1
	b .read_loop
	.write_arg3:
	strb r1, [r6], #1
	b .read_loop

	.next_word:
	add  r7, r7, #1          @ move to next buffer
	cmp  r7, #3
	bge  .fin               @ max 3 words
	b .read_loop

	.fin:
	@ null terminate all
	mov r1, #0
	strb r1, [r4]
	strb r1, [r5]
	strb r1, [r6]

	pop {lr}
	bx lr


print_prompt:
	mov	r7, #4
	mov	r0, #1
	ldr	r1, =prompt
	mov 	r2, #14 
	svc 	#0
	bx	lr	


@ ===== Command handles ===== @
fwrite_handle:
	mov 	r6, #1	@used for the unknown cmd check

	mov 	r7, #4
	mov 	r0, #1
	ldr	r1, =fwrite_cmd
	ldr 	r2, =fwrite_cmd_len
	svc 	#0

	b	.fwrite_done
	
help_handle:
	mov	r6, #1

	ldr	r1, =help_text
	ldr	r2, =help_text_len
	bl 	write_stdout
	
	b	.help_done


rand_handle:
	mov	r6, #1

	bl	rand
	b	.rand_done

ndir_handle:
@ mkdir wrapper
	mov 	r6, #1

	@ parse arguments
	bl	parse_cmd_args

	@ error handling
	cmp	r0, #0
	b	.ndir_done

	@ save pathname arg
	mov	r4, r1		
	
	

	b	.ndir_done

exit_handle:
	mov 	r7, #1
	mov	r0, #0
	svc 	#0

@ ===== utils ===== @
@ better_strcmp
@ desc - Better version of strcpy ^~^
@ arg1 - r0 = ptr to first string
@ arg2 - r1 = ptr to second string
@ ret - r0 = 1 (if equal) | r0 = 0 (if not equal)
better_strcmp:
.loop:
	ldrb 	r2, [r0], #1	@ load byte from input_buff
	ldrb 	r3, [r1], #1	@ load byte from known command
	cmp 	r2, r3		@ cmp, if not equal bytes then we done
	bne 	.done 		@ mismatch, not equal

	cmp 	r2, #0		@ if we reach null term, string should be same
	beq 	.success	@ if not, we go recursive t~t

	b 	.loop		@ if not, we go recursive t~t

.success:
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
	@ Must be called with bl!!
	mov 	r7, #0x4
	mov	r0, #1
	svc 	#0
	bx 	lr

@ rand
@ generate random number :3
rand:
	push	{lr}

	@ open /dev/urandom
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
	mov	r2, #16
	svc	#0

	ldr	r1, =rand_buff
	mov	r2, #16
	bl	write_stdout

	bl	print_nl

	pop	{lr}
	bx 	lr


@ print_nl
@ desc - not gonna explain this
print_nl:
	push 	{lr}
	ldr	r1, =new_line
	mov	r2, #1
	bl 	write_stdout

	pop	{lr}
	bx 	lr

@ parse_arg 
@ desc - Extract up to three arguments of a used commmand  
@ args - r0 = Command string used
@ ret  - r0 will be 0 if failed | r1,r2,r3 = Each argument used in order 
parse_cmd_args:
	push	{lr}
	
.again:
	@ Prepare arg buffers
	ldr 	r4, =arg1_buffer
	ldr 	r5, =arg2_buffer
	ldr 	r6, =arg3_buffer

	ldrb 	r1, [r0], #1	@ load byte from input_buff

	cmp	r1, #0		@ Is null term, no args supplied t-t
	beq	.no_args

	cmp 	r1, #' '	@ if we see space, we start parsing args
	bne	.again

	b	.parse_arg_one	@ Here we should be at the first arg, start chain

	cmp 	r2, #0		@ if we reach null term, string should be same
	beq 	.exit		

	b 	.again		@ if not, we go recursive t~t

.parse_arg_one:
	ldrb 	r1, [r0], #1	@ load byte from arg into cmp register
	strb	r1, [r4], #1 	@ store byte from cmp register into arg buffer 
	cmp 	r1, #' '	@ if we hit space, next arg
	beq	.parse_arg_two
	cmp 	r1, #0
	mov 	r0, #1
	beq	.exit
.parse_arg_two:
	ldrb 	r2, [r0], #1
	strb	r2, [r5], #1 	 
	cmp	r2, #' '
	beq	.parse_arg_three
	cmp 	r2, #0
	mov 	r0, #1
	beq	.exit
.parse_arg_three:
	ldrb 	r3, [r0], #1
	strb	r3, [r6], #1 	 
	cmp 	r3, #0		@ if we reach null term, command is done
	mov 	r0, #1
	beq	.exit
.no_args:
	ldr	r1, =no_args_txt
	ldr	r2, =no_args_txt_len
	bl	write_stdout
	mov 	r0, #0
	b	.exit
.exit:
	mov 	r1, r4
	mov	r2, r5
	mov	r3, r6
	pop 	{lr}
	bx 	lr

@ ================== Data Section ===================== @
.section .rodata
	prompt: .ascii "peachykeen32> "
	prompt_len = .-prompt
	help_text: .asciz "Help Menu:\n Commands:\n  help     - Show this help message\n  exit     - Exit the shell\n  fwrite   - Echo command (test command)\n  ndir     - Create a new directory (incomplete)\n  rand     - Generate and print 16 random bytes\n"
	help_text_len = .-help_text
	.equ input_buff_size, 100
	.comm input_buff, input_buff_size
	unknown_msg: .asciz "Unknown command \>\~\< \n"
	unknown_msg_len = .-unknown_msg
	dev_urandom: .asciz "/dev/urandom"
	new_line: .ascii "\n"
	no_args_txt: .asciz "No arguments supplied - Please provide at least one argument for this command"
	no_args_txt_len = .-no_args_txt

	@ == command reserved keywords ==
	fwrite_cmd: .asciz "fwrite"
	fwrite_cmd_len = .-fwrite_cmd
	
	exit_cmd: .asciz "exit"
	exit_cmd_len = .-exit_cmd

	help_cmd: .asciz "help"
	help_cmd_len = .-help_cmd

	ndir_cmd: .asciz "ndir"
	ndir_cmd_len = .-ndir_cmd

	rand_cmd: .asciz "rand"
	rand_cmd_len = .-rand_cmd


.section .bss
	.lcomm rand_buff, 16	@ 16 bytes for reading the urandom file
	.lcomm arg1_cli_buff, 64
	.lcomm arg2_cli_buff, 64
	.lcomm arg3_cli_buff, 64
	.lcomm arg1_buffer, 64	@ 64 bytes for arguments
	.lcomm arg2_buffer, 64	@ 64 bytes for arguments
	.lcomm arg3_buffer, 64	@ 64 bytes for arguments
