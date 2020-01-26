.data
	; uint32 K[]
	K dd 0428a2f98h, 071374491h, 0b5c0fbcfh, 0e9b5dba5h, 03956c25bh, 059f111f1h, 0923f82a4h, 0ab1c5ed5h, 0d807aa98h, 012835b01h, 0243185beh, 0550c7dc3h, 072be5d74h, 080deb1feh 
	  dd 09bdc06a7h, 0c19bf174h, 0e49b69c1h, 0efbe4786h, 00fc19dc6h, 0240ca1cch, 02de92c6fh, 04a7484aah, 05cb0a9dch, 076f988dah, 0983e5152h, 0a831c66dh, 0b00327c8h, 0bf597fc7h
	  dd 0c6e00bf3h, 0d5a79147h, 006ca6351h, 014292967h, 027b70a85h, 02e1b2138h, 04d2c6dfch, 053380d13h, 0650a7354h, 0766a0abbh, 081c2c92eh, 092722c85h, 0a2bfe8a1h, 0a81a664bh
	  dd 0c24b8b70h, 0c76c51a3h, 0d192e819h, 0d6990624h, 0f40e3585h, 0106aa070h, 019a4c116h, 01e376c08h, 02748774ch, 034b0bcb5h, 0391c0cb3h, 04ed8aa4ah, 05b9cca4fh, 0682e6ff3h
	  dd 0748f82eeh, 078a5636fh, 084c87814h, 08cc70208h, 090befffah, 0a4506cebh, 0bef9a3f7h, 0c67178f2h
	Kaddr dq offset K
.code
hashAsm PROC ; void hash(uint64 [rcx], int32 [rdx], uint64 [r8])
	push rbp
	mov rbp, rsp
	sub rsp, 356
	lea rax, [rbp-336]
	mov [rbp-356], rax
	mov [rbp+16], rcx
	mov [rbp+24], rdx
	mov [rbp+28], r8
	mov rax, [rbp+16]
	mov [rbp-348], rax			;M = bytes
	mov rax, [rbp+24]
	mov [rbp-340], eax
	mov dword ptr [rbp-52], 06a09e667h
	mov dword ptr [rbp-56], 0bb67ae85h
	mov dword ptr [rbp-60], 03c6ef372h
	mov dword ptr [rbp-64], 0a54ff53ah
	mov dword ptr [rbp-68], 0510e527fh
	mov dword ptr [rbp-72], 09b05688ch
	mov dword ptr [rbp-76], 01f83d9abh
	mov dword ptr [rbp-80], 05be0cd19h
	mov dword ptr [rbp-44], 0
	loop1:		
		mov eax, [rbp-44]
		cmp eax, [rbp-340]
		jge loop1end
		mov dword ptr [rbp-48], 0
		loop2:
			cmp dword ptr [rbp-48], 16
			jge loop2end
			mov eax, [rbp-44]
			shl eax, 4
			add eax, [rbp-48]
			shl eax, 2
			add rax, [rbp-348]
			mov ebx, [rax]
			mov eax, [rbp-48]
			shl eax, 2
			add rax, [rbp-356]
			mov dword ptr [rax], ebx
			inc dword ptr [rbp-48]
			jmp loop2
		loop2end:
		loop3:
			cmp dword ptr [rbp-48], 64
			jge loop3end
			
			mov eax, dword ptr [rbp-48]
			sub rax, 2
			shl rax, 2
			add rax, [rbp-356]
			mov ebx, [rax]
			sub rsp, 4
			mov [rsp], ebx
			call S_SIG1
			add rsp, 4
			mov [rbp-40], eax
			
			mov eax, dword ptr [rbp-48]
			sub rax, 7
			shl rax, 2
			add rax, [rbp-356]
			mov eax, dword ptr [rax]
			add dword ptr [rbp-40], eax
			
			mov eax, dword ptr [rbp-48]
			sub rax, 15
			shl rax, 2
			add rax, [rbp-356]
			mov ebx, [rax]
			sub rsp, 4
			mov [rsp], ebx
			call S_SIG0
			add rsp, 4
			add dword ptr [rbp-40], eax
			
			mov eax, dword ptr [rbp-48]
			sub rax, 16
			shl rax, 2
			add rax, [rbp-356]
			mov eax, dword ptr [rax]
			add dword ptr [rbp-40], eax

			mov eax, dword ptr [rbp-48]
			shl rax, 2
			add rax, [rbp-356]
			mov ebx, dword ptr [rbp-40]
			mov dword ptr [rax], ebx

			inc dword ptr [rbp-48]
			jmp loop3
		loop3end:
		mov rcx, 32
		lea rdi, [rbp-40]
		lea rsi, [rbp-80]
		rep movsb
		mov dword ptr [rbp-48], 0
		loop4:
			cmp dword ptr [rbp-48], 64
			jge loop4end
			;T1
			mov eax, [rbp-40]
			mov [rbp-4], eax
			mov eax, [rbp-28]
			sub rsp, 4
			mov [rsp], eax
			call B_SIG1
			add rsp, 4
			add [rbp-4], eax
			sub rsp, 12
			mov eax, [rbp-28]
			mov [rsp], eax
			mov eax, [rbp-32]
			mov [rsp+4], eax
			mov eax, [rbp-36]
			mov [rsp+8], eax
			call ChF
			add rsp, 12
			add [rbp-4], eax
			mov eax, dword ptr [rbp-48]
			shl rax, 2
			add rax, [Kaddr]
			mov ebx, [rax]
			add [rbp-4], ebx
			mov eax, dword ptr [rbp-48]
			shl rax, 2
			add rax, [rbp-356]
			mov ebx, [rax]
			add [rbp-4], ebx
			;T2
			mov eax, [rbp-12]
			sub rsp, 4
			mov [rsp], eax
			call B_SIG0
			add rsp, 4
			mov [rbp-8], eax
			sub rsp, 12
			mov eax, [rbp-12]
			mov [rsp], eax
			mov eax, [rbp-16]
			mov [rsp+4], eax
			mov eax, [rbp-20]
			mov [rsp+8], eax
			call MajF
			add rsp, 12
			add [rbp-8], eax
			;h...
			mov rcx, 28
			lea rdi, [rbp-40]
			lea rsi, [rbp-36]
			rep movsb
			mov eax, [rbp-4]
			add [rbp-28], eax
			add eax, [rbp-8]
			mov [rbp-12], eax
			
			inc dword ptr [rbp-48]
			jmp loop4
		loop4end:
		mov eax, [rbp-40]
		add [rbp-80], eax
		mov eax, [rbp-36]
		add [rbp-80+4], eax
		mov eax, [rbp-32]
		add [rbp-80+8], eax
		mov eax, [rbp-28]
		add [rbp-80+12], eax
		mov eax, [rbp-24]
		add [rbp-80+16], eax
		mov eax, [rbp-20]
		add [rbp-80+20], eax
		mov eax, [rbp-16]
		add [rbp-80+24], eax
		mov eax, [rbp-12]
		add [rbp-80+28], eax

		inc dword ptr [rbp-44]
		jmp loop1
	loop1end:
	mov eax, [rbp-52]
	mov rbx, [rbp+28]
	mov [rbx], eax
	mov eax, [rbp-56]
	mov [rbx+4], eax
	mov eax, [rbp-60]
	mov [rbx+8], eax
	mov eax, [rbp-64]
	mov [rbx+12], eax
	mov eax, [rbp-68]
	mov [rbx+16], eax
	mov eax, [rbp-72]
	mov [rbx+20], eax
	mov eax, [rbp-76]
	mov [rbx+24], eax
	mov eax, [rbp-80]
	mov [rbx+28], eax

	mov rsp, rbp
	pop rbp
hashAsm ENDP

; push z, y, x
ChF PROC ; uint32 Ch(uint32 x, uint32 y, uint32 z)
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	and eax, [rbp+20]
	mov [rbp-4], eax
	mov eax, [rbp+16]
	not eax
	and eax, [rbp+24]
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
ChF ENDP

MajF PROC ; uint32 Maj(uint32 x, uint32 y, uint32 z)
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	and eax, [rbp+20]
	mov [rbp-4], eax
	mov eax, [rbp+16]
	and eax, [rbp+24]
	xor [rbp-4], eax
	mov eax, [rbp+20]
	and eax, [rbp+24]
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
MajF ENDP

S_SIG0 PROC
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	ror eax, 7
	mov [rbp-4], eax
	ror eax, 11
	xor [rbp-4], eax
	mov eax, [rbp+16]
	shr eax, 3
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
S_SIG0 ENDP

S_SIG1 PROC
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	ror eax, 17
	mov [rbp-4], eax
	ror eax, 2
	xor [rbp-4], eax
	mov eax, [rbp+16]
	shr eax, 10
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
S_SIG1 ENDP

B_SIG0 PROC
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	ror eax, 2
	mov [rbp-4], eax
	ror eax, 11
	xor [rbp-4], eax
	ror eax, 9
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
B_SIG0 ENDP

B_SIG1 PROC
	push rbp
	mov rbp, rsp
	sub rsp, 4
	mov eax, [rbp+16]
	ror eax, 6
	mov [rbp-4], eax
	ror eax, 5
	xor [rbp-4], eax
	ror eax, 14
	xor eax, [rbp-4]
	mov rsp, rbp
	pop rbp
	ret
B_SIG1 ENDP

end