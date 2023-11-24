global _start

LENOUT equ 16           ; Longeur du tableau de sortie
LENIN equ 7             ; Longeur du tableau d'entrée
CONSTNOT equ 36         ; Constante de l'opérateur NOT, 36 car 26+10 = 36, avec 26 lettres et 10 chiffres
CONSTAND equ 37
CONSTOR equ 38

section .data          ; Data segment
	; inputTab            db 12,11,10,1,2,10,3 ; A(O(N(1),2),N(3))
	; inputTab            db CONSTNOT,8
	; inputTab            db CONSTAND,CONSTNOT,8,9
	inputTab            db CONSTAND, CONSTOR, CONSTNOT, 1, 2, CONSTNOT, 3        ; A(O(N(1),2),N(3))
	outTab              TIMES LENOUT db 0                                        ; Tableau contenant que des 0 et qui sera le tableau de sortie
																				; Faire attention qu'il soit suffisament grand pour contenir tous les éléments
																				; Mais pas trop pour ne pas se melanger avec CONSTNOT
	virgule             db ","
	charsList           db "0123456789abcdefghijklmnopqrstuvwwyzNAO....",10      ; Permet d'afficher les éléments du tableau de sortie


section .text

%macro new_line 0
	mov rax, 1
	mov rdi, 1
	mov rsi, newline
	mov rdx, newline_len
	syscall
%endmacro

%macro print_rsi_out 1 ; Modifie rax, rdi, rsi, rdx
	; On affiche le caractère
	mov rax, 1
	mov rdi, 1
	mov rsi, charsList
	add rsi, %1
	mov rdx, 1
	syscall

	; On affiche la virgule
	mov rax, 1
	mov rdi, 1
	mov rsi, virgule
	mov rdx, 1
	syscall
%endmacro

; Affichage de la table de sortie, Fonction à appeler une seule fois, car elle contient des labels
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
	; Hello, World de debug
	mov rax, 1
	mov rdi, 1
	mov rsi, msg
	mov rdx, msglen
	syscall


	; On initialise les curseurs, sachant que on part de la fin des tableaux
	mov r10, LENIN       ; Curseur de déplacement dans inputTab
	mov r11, LENOUT       ; Curseur de déplacement dans outTab
	dec r11      ; On enlève 1 car on commence à 0, et finit a n-1
	dec r10      ; idem

	; On parcours inputTab, jusqu'à r10 = 0
	.boucle_in:
		movzx r13, byte [inputTab + r10]       ; On prend le dernier element de inputTab
		cmp r13, CONSTNOT
		jge .isOp ; c'est un nomnbre
			; On ajoute l'élément à la fin de outTab
			; On ajoute au stack l'index de l'élément
			; On décrémente r11
			mov rax, r13
			mov byte [outTab + r11], al         ; J'utilise al car rax ne marche pas, problème du nombre de bits
			push r11
			dec r11
			jmp .end_boucle_in

		.isOp:
			cmp r13, CONSTNOT
			jne .isOp2
			; On pop le stack
			pop r12
			; On ajoute l'élément à la fin de outTab
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
		    ; On pop le stack
			pop r12
			; On ajoute l'élément à la fin de outTab
			mov rax, r12
			mov byte [outTab + r11], al
			dec r11
			; On pop le stack
			pop r12
			; On ajoute l'élément à la fin de outTab
			mov rax, r12
			mov byte [outTab + r11], al
			dec r11
			; On ajoute l'opérateur à la fin de outTab
			mov rax, r13
			mov byte [outTab + r11], al
			push r11
			dec r11

	.end_boucle_in:
	; On verifie si on a finit de parcourir inputTab
	dec r10
	cmp r10, 0
	; Si on a pas finit, on revient au debut
	jge .boucle_in





	new_line
	; Affichage des indexes
	mov rax, 1
	mov rdi, 1
	mov rsi, topline
	mov rdx, topline_len
	syscall

	; Affichage du tableau de sortie
	print_out
	new_line

	; On quitte le programme, de manière "propre"
	mov rax, 60       ; exit(
	mov rdi, 0        ;   EXIT_SUCCESS
	syscall           ; );

section .rodata
	msg: db "Hello, world!", 10
	msglen: equ $ - msg
	newline: db 10                            ; Le 10 c'est le code ASCII de la nouvelle ligne
	newline_len: equ $ - newline
	topline: db "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o", 10
	topline_len: equ $ - topline
