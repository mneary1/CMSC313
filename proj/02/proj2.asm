;; Name: Michael Neary (mneary1@umbc.edu)
;; Assignment: Project 2
;; File: proj2.asm
;; Date: 3/6/2014
;; CMSC 313 - Dr. Sadeghian
;; 
;; This program loops three times, each time asking the user for input
;; then stripping that input of all characters that are not lowercase letters.
;;  
;; After the stripping of characters, a selection sort is performed. 
;; Each time a swap is made, the new string is printed out to the screen
;;
;; build using:
;; nasm -f elf -g -F stabs proj2.asm
;; link with:
;; ld -o proj2 proj2.o -melf_i386
;; exceutable:
;; proj2

section .data
	
Input: db "Enter the input: "	;input message
InputLen equ $-Input		;length of input message

Sort: db "Sorting string: "	;sorting message
SortLen equ $-Sort		;sorting message length

Counter: db 0x00  		;keep a counter in memory, start at 0 
CounterLen equ $-Counter 	;length of counter

newLine: db 0Ah 		;save a spot in memory for the newline character to print out later

section .bss

BuffLen equ 500	   		;length of buffer should be 500 bytes
Buff: resb BuffLen 		;reserve memory for the Buffer of entered characters

StringLen equ 500     	        ;String length will be a max of 500 bytes
String: resb StringLen 		;reserve memory for the processed string

StrSize: resb 1 		;reserve a byte to store actual length of string

section .text

	global _start

_start:
	nop 		 ;nop keeps the debugger happy

	; following blocks to ask user for input: 
	; writes input message to screen
Read:
	mov eax,4	 ;specify sys_write call
	mov ebx,1	 ;write to standard output
	mov ecx,Input	 ;pass address of Input message
	mov edx,InputLen ;pass lenght of input message
	int 80h		 ;system interrupt so message can be written

	; gets input from user

	mov eax,3	 ;specify sys_read call
	mov ebx,0	 ;read from standard input
	mov ecx,Buff	 ;write input to address at String
	mov edx,BuffLen	 ;500 bytes of room at this address
	int 80h		 ;system interrupt to actually get the input

	;block to process buffer
	;store all lowercase characters at the memory address String

	;set up registers
	mov esi,eax 	;store length of buffer in esi
	mov eax,1   	;start counter of buff length in eax
	mov ebp, Buff 	;store starting address of buffer at ebp
	dec ebp 	;prevent off by one error
	mov ebx,String  ;store strating addres of string in ebx
	dec ebx 	;prevent off by one error
	mov ecx,1	;start string length count at 1


	;find lowercase characters
Scan:
	cmp byte [ebp+eax],61h  ;compare byte of input buffer with 'a'
	jb Next			;jump if the input char is below 'a'

	cmp byte [ebp+eax],7Ah  ;compare byte of input buffer with 'z'
	ja Next			;jump if the input char is above 'z'

	;store lowercase at String
        mov edx,[ebp+eax] ;store the char in dl
	mov [ebx+ecx],edx ;move char to the string
	inc ecx           ;increment length of string
Next:  
	cmp eax,esi ;compare counter with length of buffer
	je Print    ;if equal, keep going in program
	inc eax	    ;if not equal, increment counter of length
	jmp Scan    ;jump to scan anotehr character	

Print:
	mov [StrSize],ecx ;save actual size of string in memory
	
	mov eax,4	;specify sys_write call
	mov ebx,1	;specify writing to standard output
	mov ecx,Sort	;pass the address of the sort message
	mov edx,SortLen	;pass the length of that message
	int 80h		;system interrupt to write string to screen

	mov eax,4         ;specify sys_write call
	mov ebx,1	  ;specify writing to standard output
	mov ecx,String-1  ;pass starting off by one address for string
	mov edx,[StrSize] ;pass length of string
	int 80h		  ;system interrupt to write string to screen 
	
	;print new line
	mov eax,4	;specify sys_write call
	mov ebx,1	;specify writing to standard output
	mov ecx,newLine ;write newline character
	mov edx,1	;one byte long
	int 80h		;system interrupt to print new line



	; now perform selection sort on the string of lowercase characters

	;intial state of esi register before going into sort
	mov esi,1 ;to keep track of stationary position in string

	
Outer:
	;set up registers and perform a check
	;to be able ot find the smallest character to the right, then swap

	cmp esi,[StrSize]	   ;compare stationary position to string size
	je Continue		   ;if equal, jump ot Continue
	mov byte ah,[String-1+esi] ;mov stationary char into ah, ah will contain
				   ;the smallest char in a given iteration
	mov bh,ah		   ;store a copy in bh of the character at ah
	mov edi,esi		   ;save a copy of stationary position in string
				   ;to use as jumping point for traversing down the string
	mov ebp,edi		   ;save a copy of where that character is in the string
				   ;necessary for swapping characters later

		;search for the smallest character to the right
	Inner:
		inc edi			;go one character to the right
		cmp edi,[StrSize]	;compare that number to size of string
		je Swap			;if equal, jump to Swap
		
		mov byte al,[String-1+edi] ;mov the next character into a register
		cmp ah,al		   ;compare the stationary char with the one just grabbed
		jb Inner		   ;if stationary is less than one grabbed, check next char 	
		mov ah,al		   ;that char that was grabbed is less than stationary char
					   ;char that was grabbed becomes new smallest char	
		mov ebp,edi		   ;update where the character exists in the string
		jmp Inner		   ;check the next char
		
	;swaps the characters in ah and bh in the string
	Swap:   cmp ah,bh		   ;compare the two characters in ah and bh
		je OuterEnd		   ;don't swap if they are the same	
		mov [String-1+esi],ah	   ;put ah where bh was in the string
		mov [String-1+ebp],bh	   ;put bh where ah was in the string	
		jmp Write		   ;write the new string to the screen

OuterEnd:
	inc esi 	;increment where the stationary character is
	jmp Outer       ;repeat the traversing process again
				
Write:		
	;write the string to the screen
	mov eax,4	  ;specify sys_write
	mov ebx,1	  ;specify writing to standard output
	mov ecx,String-1  ;pass starting point for string
	mov edx,[StrSize] ;pass length of string
	int 80h		  ;system interrupt to print string to the screen

        ;write a new line
        mov eax,4	;specify sys_write
        mov ebx,1	;specify writing to standard output
        mov ecx,newLine ;pass newline character
        mov edx,2	;pass 2 bytes
        int 80h		;system interrupt to print newline

	jmp OuterEnd    ;jump to end of outer loop   
	
Continue:
	;write a new line
	mov eax,4	;specify sys_write
	mov ebx,1	;specify writing to standard output
	mov ecx,newLine ;pass newline character
	mov edx,1	;write one byte
	int 80h		;system interrupt to write newline to screen

	;block to increment the counter in memory
	mov al,[Counter]  ;store value the Counter points to in eax
	cmp al,02h 	  ;compare the counter to 2
	je Exit		  ;if equal, program has run three times so exit			
	inc al		  ;increment that the counter 
	mov [Counter], al ;store the counter back in memory
	jmp Read	  ;jump to beginning of program 
	
	;block to exit the program
Exit: 
	mov eax,1 ;specify sys_exit call
	mov ebx,0 ;return 0
	int 80h	  ;system interrupt to exit
