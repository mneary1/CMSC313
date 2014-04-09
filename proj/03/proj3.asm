;; Name: Michael Neary (mneary1@umbc.edu)
;; File: proj3.asm
;; CMSC 313 - Dr. Sadeghian
;; Date: 3/27/14
;; 
;; Description:
;; 	This program takes user input of id/name pairs and then
;; stores them in an associative array wher starting with the id
;; immediately followed by the name. then accesses each by id
;; edits the name at that id, then when completed prints out
;; all the id/name pairs
;;
;; build using:
;; nasm -f elf -g -F stabs proj3.asm
;; link with:
;; ld -o proj3 proj3.o -melf_i386
;; exceutable:
;; proj3
	
section .bss
	ArrayLen equ 65
	Array: resb ArrayLen
	
	IDLen equ 3
	IDBuff:	resb IDLen

	NameLen equ 10
section .data

	InputIDMesg: db "Please enter an id: "
	InputIDMesgLen equ $-InputIDMesg

	InputNameMesg: db "Please enter a name: "
	InputNameMesgLen equ $-InputNameMesg

	NameChangeMesg:	 db "Enter ids of names to change (00 to stop)",10
	NameChangeMesgLen equ $-NameChangeMesg

	ErrorMesg: db "Invalid id",10
	ErrorMesgLen equ $-ErrorMesg

	OldNameMesg:	 db "The name was: "
	OldNameMesgLen equ $-OldNameMesg

	NewNameMesg:	 db "Enter the new name: "
	NewNameMesgLen equ $-NewNameMesg
	
	OutputID: db "ID:   "
	OutputIDLen equ $-OutputID

	OutputName: db  "NAME: "
	OutputNameLen equ $-OutputName
	
	new_line: db 0ah

section .text
	
	;; ---------------------------------------------------------
	;; Print: called sys_write to write something to the console
	;; UPDATED: 3/27/14
	;; IN: %1 - address being written %2-length of memory at address
	;; OUT: nothing
	;; MODIFIES: eax,ebx,ecx,edx
	;; RETURNS: nothing
	;; CALLS: Kernel sys_write
	;; DESCRIPTION: writes the data given to the screen
	;; --------------------------------------------------------
	%macro Print 2
	mov eax,4 		;sys_write
	mov ebx,1		;standard output
	mov ecx,%1 		;write this addresss
	mov edx,%2		;address length
	int 80h			;system interrupt
	%endmacro

	;; -----------------------------------------------------
	;; Read: called sys_read to read some input
	;; UPDATED: 3/27/14
	;; IN: %1 - address to write data to %2 - length to write to address
	;; OUT: nothing
	;; MODIFIES: eax,ebx,ecx,edx
	;; RETURNS: nothing
	;; CALLS: Kernel sys_read
	;; DESCRIPTION: reads in data and stores it at the given address
	%macro Read 2
	mov eax,3		;sys_read
	mov ebx,0		;standard input
	mov ecx,%1		;address to write to
	mov edx,%2		;length to write
	int 80h			;system interrupt
	%endmacro

	global _start

_start:
	
	;; print id message to screen
	Print new_line,1 	;print a new line character
	call ScanPairs		;call proc to get the pairs of data
	call EditNames		;call proc to edit names
	call PrintPairs		;call proc to print out all the pairs of data
	
	mov eax,1		;make sys_exit call
	mov ebx,0		;no errors
	int 80h			;system interrupt to gracefully exit
	
	;; ------------------------------------------------------------------------------------
	;; ScanPairs: reads in the id/name pairs and stores them in Arr
	;; UPDATED: 3/27/14 
	;; IN: Nothing
	;; RETURNS: Nothing
	;; MODIFIES: esi and ebp 
	;; CALLS: Print and Read macros (sys_write and sys_read)
	;; DESCRIPTION: reads in user input for the id and name pairs
	;; 		writes the id to the Array, then writes the name after the id
	;; 		advancing the effective address each time,
	;; 		checking to make sure you don't go out of bounds
	;; ------------------------------------------------------------------------------------
	
ScanPairs:
	mov esi,0		;start a count in esi at 0
	lea ebp,[Array]		;get starting effective address of ID and store it in ebp
	lea edi,[Array+IDLen]	;get starting effective address of name and store it in edi

loop:	Print InputIDMesg,InputIDMesgLen ;print input ID  message to console
	Read ebp,IDLen		;read in an ID and put it at the address in ebp
	Print new_line,1	;print a new line character
	
	Print InputNameMesg,InputNameMesgLen ;print input name message to console
	Read edi,10		;read in a name and put it at the address in edi
	Print new_line,1	;print a new line character
	
	add esi,1		;add one to the counter
	add ebp,13		;advance down the array for address to place the next ID
	add edi,13		;advance down the array for address to place next name
	cmp esi,5		;compare counter to 5, only taking 5 id/name pairs
	jne loop		;if not 5 yet. keep going 
	ret			;return back to caller

	;; --------------------------------------------------------------------------------
	;; PrintPairs: prints out each id/name pair in sequence
	;; UPDATED: 3/27/14
	;; IN: nothing
	;; RETURNS: nothing
	;; MODIFIES: esi,edi
	;; CALLS: Print macro (Kernel sys_write)
	;; DESCRIPTION: prints each id/name pair consequtively by walking down the array
	;; 		using effective addresses
	;; --------------------------------------------------------------------------------
	
PrintPairs:
	lea esi,[Array]		;get effective address of first ID and put it in esi
	mov edi,0		;start a count at 0 in edi to keep track of how many pairs have been processed
	
print:	Print OutputID,OutputIDLen ;print the output ID message
	Print esi,IDLen		   ;print the ID at the address in esi

	add esi,IDLen		;add 3 to esi to get the effective address of the name associated with the id
	Print OutputName,OutputNameLen ;print ouput name message
	Print esi,NameLen	       ;print the name at the address in esi
	Print new_line,1	       ;print a new line character
	
	add esi,NameLen		;add the length of the name to the address in esi to get the next id
	add edi,13		;add 13 to the counter, each id/name pair is separated by 13 bytes
	cmp edi,ArrayLen	;compare counter to length of array
	jne print		;if not  equal there are still pairs to process, jump back for the next one
	ret			;return to caller

	;; --------------------------------------------------------------------------------------
	;; EditPairs: edits the name associated with  an id
	;; UPDATED: 3/27/14
	;; IN: nothing
	;; RETURNS: nothing
	;; MODIFIES: ax/al, esi, edi
	;; CALLS: FindID, Print and Read macros(Kernel sys_write and sys_read)
	;; DESCRIPTION: asks the user for an ID, find the id in the array
	;; 		get the name associated with that id, zero it out by
	;; 		walking down the length of the name at the effective address of the name
	;; 		then read in a new name at that address, keep going until user enters 00
	;; ---------------------------------------------------------------------------------------
	
EditNames:
	Print NameChangeMesg,NameChangeMesgLen ;print the name change message to the console
	Print new_line,1		       ;print a new line character
	;; get id
begin:	Print InputIDMesg,InputIDMesgLen ;print input id message to console
	Read IDBuff,IDLen		 ;get an ID from the user
	Print new_line,1		 ;print a new line character
	
	mov ax,[IDBuff]		;move the given ID into ax
	cmp ax,3030h		;compare that id to '00' (3030h)
	je done			;if equal, user is done, jump to exit
	
	mov esi,0		;start a counter in esi to be able to use the next proc
	call FindID		;call the FindID proc to find the given ID in the array
	cmp eax,1337h		;check for the possible return value in eax given by FindID
	je EditNames		;if return value was there, there was an error
				;jump back and try again
	
	
	lea edi,[Array+esi+IDLen] ; Array + esi is effective address of id found, add 3 for name
	Print OldNameMesg,OldNameMesgLen ;print old name message to console
	Print edi,NameLen		 ;print the old name at the address in edi before it is changed
	Print new_line,1		 ;print a new line character
	mov esi,0			 ;start a counter in esi to keep track of position in the name
	
	;; walk down the name to zero it out
	;; so there are no leftovers if you change to a smaller name
walk:	mov al, [edi+esi]	;move the byte at the address edi+esi into al
	xor al,al		;zero out this byte by xor'ing with itself
	mov [edi+esi],al	;replace the byte at edi+esi with the now zeroed-out byte
	add esi,1		;add to the counter
	cmp esi,NameLen		;check counter against size of name
	jne walk		;if theres no more name left to zero out, continue in the proc
				;if there is nore, jump back up and do it again 
	
	;; read new name
	Print NewNameMesg,NewNameMesgLen ;print new name message to the screen
	Read edi,NameLen		 ;get input for a new name, put it at the address in edi
	Print new_line,1
	jmp begin	
done:	ret

	;; ------------------------------------------------------------------------------
	;; returns 1337h in eax if there was an error
	;; esi must be zeroed out prior to calling
	;; alters the values of ebx and eax
	;; FindID: walks down array checking ids
	;; UPDATED: 3/27/14
	;; IN: ax -> ID to check, esi->counter start at 0
	;; RETURNS: 1337h in eax if there was an error, esi will contain what to add
	;; 		to Array to get effective address of the found id
	;; MODIFIES: esi,ebx,eax
	;; CALLS: Print macro (Kernel sys_write) if the id doesn't exist
	;; DESCRIPTION: progresses down the array comparing the ids to the one entered
	;; 		if found it will return without modifying eax
	;;  		if not found it returns 1337h in eax and prints an error message
	;; -------------------------------------------------------------------------------
FindID:
	cmp esi,ArrayLen 	;compare length of array with where you are in the Array
	je error		;if they equal each toher, there's nothing left to check
	
	mov ebx,[Array+esi]	;mov the next id into ebx
	
	cmp ax,bx		;compare the next id to the id read in
	je exit			; if equal you've found the id, exit proc

	add esi,13		;advance down the array to the next id
	jmp FindID		;jump up and try again

error:	Print ErrorMesg,ErrorMesgLen ;print error message to console
	mov eax,1337h		     ;return error value in eax
	
exit:	ret			;return to caller
	