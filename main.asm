global _start

LENOUT equ 16
LENIN equ 7
LENSTACK equ 40
CONSTNOT equ 36
CONSTAND equ 37
CONSTOR equ 38

section .data          ; Data segment
	; inputTab            db 12,11,10,1,2,10,3 ; A(O(N(1),2),N(3))
	; inputTab            db CONSTNOT,8
	; inputTab            db CONSTAND,CONSTNOT,8,9
	inputTab            db CONSTAND, CONSTOR, CONSTNOT, 1, 2, CONSTNOT, 3; A(O(N(1),2),N(3))
	outTab              TIMES LENOUT db 0
	virgule             db ","
	charsList           db "0123456789abcdefghijklmnopqrstuvwwyzNAO....",10
	stackTab            TIMES LENSTACK db 0
	stackCursor      	db 0
	stackElement      	db 0


section .text

%macro new_line 0
	mov rax, 1        ; write(
	mov rdi, 1        ;   STDOUT_FILENO,
	mov rsi, newline  ;   "\n",
	mov rdx, newline_len   ;   sizeof("\n")
	syscall           ; );
%endmacro

%macro print_rsi_out 1 ; Modifie rax, rdi, rsi, rdx
	mov rax, 1        ; write(
	mov rdi, 1        ;   STDOUT_FILENO
	mov rsi, charsList   ;   outTab,
	add rsi, %1
	mov rdx, 1        ;   1;
	syscall           ; );

	mov rax, 1        ; write(
	mov rdi, 1        ;   STDOUT_FILENO,
	mov rsi, virgule  ;   ",",
	mov rdx, 1        ;   1
	syscall           ; );
%endmacro

%macro print_out 0 ; modifie rax, rcx, rdi, rsi, rdx, r14, r9, r15
	mov r15, 0
	.loop:
		movzx r14, byte [outTab + r15]
		print_rsi_out r14
		inc r15
		cmp r15, LENOUT
	jl .loop ; tant que rcx < LENOUT
%endmacro

_start:
	mov rax, 1        ; write(
	mov rdi, 1        ;   STDOUT_FILENO,
	mov rsi, msg      ;   "Hello, world!\n",
	mov rdx, msglen   ;   sizeof("Hello, world!\n")
	syscall           ; );


	mov r10, LENIN       ; Curseur de déplacement dans inputTab
	mov r11, LENOUT       ; Curseur de déplacement dans outTab
	dec r11
	dec r10
	.boucle_in:
		movzx r13, byte [inputTab + r10]
		cmp r13, CONSTNOT
		jge .isOp ; c'est un nomnbre
			; On ajoute l'élément à la fin de outTab
			; On ajoute au stack l'index de l'élément
			; On décrémente r11
			mov rax, r13
			mov byte [outTab + r11], al
			push r11
			dec r11
			jmp .end_boucle_in

		.isOp:
			cmp r13, CONSTNOT
			jne .isOp2
			; On pop le stack
			pop r12
			mov rax, r12
			mov byte [outTab + r11], al
			dec r11
			; On ajoute l'opérateur à la fin de outTab
			mov rax, CONSTNOT
			mov byte [outTab + r11], al
			push r11
			dec r11
			jmp .end_boucle_in
		.isOp2:
			pop r12
			mov rax, r12
			mov byte [outTab + r11], al
			dec r11
			pop r12
			mov rax, r12
			mov byte [outTab + r11], al
			dec r11
			; On ajoute l'opérateur à la fin de outTab
			mov rax, r13
			mov byte [outTab + r11], al
			push r11
			dec r11

	.end_boucle_in:
	dec r10
	cmp r10, 0
	jge .boucle_in





	new_line
	; Affichage des indexes
	mov rax, 1
	mov rdi, 1
	mov rsi, topline
	mov rdx, topline_len
	syscall

	print_out
	new_line

	mov rax, 60       ; exit(
	mov rdi, 0        ;   EXIT_SUCCESS
	syscall           ; );

section .rodata
	msg: db "Hello, world!", 10
	msglen: equ $ - msg
	newline: db 10
	newline_len: equ $ - newline
	topline: db "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o", 10
	topline_len: equ $ - topline