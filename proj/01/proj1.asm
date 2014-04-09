;; Name: Michael Neary (mneary1@umbc.edu)
;; File: proj1.asm
;; Date: 2-25-14
;; Description:
;;	Take in one character at a time and produce output based on the following rules:
;; 	1) if it is lowercase, output the uppercase
;; 	2) if it is uppercase, output the lowercase
;; 	3) if it is a digit, output 10 more * than the digit
;; 	4) if it is any other char, echo it back out the number of iterations it is on
;; 	5) do not process ASCII 10
;; 	6) continue prompting for characters until CTRL+D is entered
;;
;; build using:
;; nasm -f elf -g -F stabs proj1.asm
;; link with:
;; ld -o proj1 proj1.o -melf_i386
;; exceutable:
;; proj1

section .data

Input:	db "Enter one char: "	;input message
InputLen equ $-Input		;length of input message

Output:	 db "Here is the output: " ;output message
OutputLen equ $-Output		   ;length of output message
		
Goodbye: db 10,"Thank you for using this program.",10 ;goodbye message
GoodbyeLen equ $-Goodbye			      ;length of goodbye messsage
	
section .bss
	Char: resb 2 		;reserve 2 bytes to store the captured character in

section .text

global _start

_start:
	nop			;no-op to keep the gdb debugger happy

;; This code block writes to the screen
;; to ask the user to enter one char
	
	mov eax,4		;specify sys_write
	mov ebx,1		;specify writing to Standard Output
	mov ecx,Input		;pass address of input string
	mov edx,InputLen	;pass length fo input string
	int 80h			;system interrupt to use sys_write

;; This code block gets the user's input, then decides if
;; it should continue processsing it or not. Then it increments
;; the iteration counter
			
	mov eax,3		;specify the sys_read call
	mov ebx,0		;specify reading from standard input
	mov ecx,Char		;give the label to store char in
	mov edx,2		;give the size of Char  
	int 80h			;hand control to OS for sys_read call

	cmp eax, 0		;compare return value with 0 (CTRL+D)
	je Exit			;jump to Exit if CTRL+D was entered

        cmp byte [Char],10	;compare the character captured to newline (ASCII 10)
        je _start		;do not process it, go back to the start
	
	add esi, 1		;start off iteration count at 1
	                        ;each time the program goes back to start
				;this is incremented
	mov edi, esi		;store a copy of the current iteration count

;;  This block outputs the message "Here is the output:"
DispOut:
	
	mov eax,4		;specify sys_wrtie call
	mov ebx,1		;specify writing to tandard Output
	mov ecx,Output		;write the output message
	mov edx,OutputLen	;specify length of output message
	int 80h			;system interrupt for OS to use sys_write

;; now decide what output needs to be dislayed
	
;; The Upcase code block decides if the character entered is in
;; the range of lowercase letters, and makes it uppercase if so
Upcase:
	cmp byte [Char],61h	;compare first byte at Char to 'a' (ASCII: 61h)
	jb Downcase		;character is not lowercase if below 'a'
	cmp byte [Char],7Ah	;compare first byte at Char to 'z' (ASCII: 7Ah)
	ja OtherChar		;character is neither below or in range, jump to OtherChar

	sub byte [Char],20h	;the char is lowercase at this point, subtract 20h
	                        ;to make it uppercase
	jmp Print		;jump to print the character 
	
;; Downcase code block decides if the character entered in is the range
;; of uppercase letters, and makes it lowercase if so
Downcase:
	cmp byte [Char],41h	;compare first byte at Char to 'A' (ASCII: 41h)
	jb Number		;character not uppercase, jump to check if number
	cmp byte [Char],5Ah	;compare first byte at Char to 'Z' (ASCII: 5Ah)
	ja OtherChar		;chacter not in range and not lowercase, jump to OtherChar

	add byte [Char],20h	;the char is uppercase at this point, add 20h
	                        ;to make it lowercase
	jmp Print		;jump to print the character

;; Number block decides if the captured value is in the range of digits
;; if it is, then in order to print out the correct number of stars
;; I subtract A30h from the value and store it in the edi register
;; this turns the ascii value of the digit into the actual number so I can
;; loop on that value. The number is captured at the ascii value and a new line,
;; and then stored as new line then the ascii value due to the little endianess
;; of the machine. knowing this a simple subtraction is all I had to do to loop the correct
;; number of times
	
Number:
	cmp byte [Char],30h	;compare first byte at Char to '0' (ASCII: 30h)
	jb OtherChar		;character entered is not in any valid ranges, jump to other
	cmp byte [Char],39h	;compare first byte at Char to '9' (ASCII: 39h)
	ja OtherChar

	mov edi,[Char]		;move the data at the address into edi
	sub edi,0A30h		;assuming only one chracter has been entered
				;then Char will have that character and the newline
	                        ;subtract the hex code for newline and zero to get
				;the actual number entered
	add edi,10		;add 10 to this number entered by user to print 10 more * characters 

	mov byte [Char],2Ah	;overwrite the first byte of the captured char at * (ASCII: 2Ah)

	;; control moves to OtherChar as it is the same at printing out * but
	;; certain desired amount og times instead of number of iterations
	
;;  OtherChar prints out the character entered a number of times equivalent to
;;  the number of iterations the program is on
OtherChar:	

	cmp edi,1		;compare value stored in edi to 1
	je Print		;if equal, jump to print to print last item
	
	;; this code block prints a character to the screen
	mov eax,4		;specify sys_write call
	mov ebx,1		;specify standard output
	mov ecx,Char		;give address of character to print
	mov edx,1		;give size to print, 1 in this case to only print first byte
	int 80h			;system interrupt to have OS call sys_write

	
	sub edi,1		;subtract one from edi as one iteration is complete
	jmp OtherChar		;jump back up to beginning of OtherChar for another iteration

;; the Print block prints the captured character to the screen
;; the character has been manipulated at this point to the specifications required
Print:
	mov eax,4		;specify sys_write call
	mov ebx,1		;specify standard output
	mov ecx,Char		;give address of character to print
	mov edx,2		;give size to print (print both bytes)
	int 80h			;system interrupt to have OS call sys_write
	jmp _start		;jump back to start to get another character
	
;; This code block prints "Thank you for using this program"
;; then gracefully exits the program
Exit:
	mov eax,4		;specify the sys_write call
	mov ebx,1		;specify writing to Standard Output
	mov ecx,Goodbye		;pass address of the goodbye message
	mov edx,GoodbyeLen	;pass the length of the goodbye message
	int 80h			;system interrupt to call sys_write
	
	mov eax,1		;specify sys_exit 
	mov ebx,0		;return zero
	int 80h			;hand control to OS for sys_exit 