section .bss
    drones_N: resd 1
    roundsTillElimination_R: resd 1
    stepsTillPrinting_K: resd 1
    destroyDistance_d: resd 1 ; float is 32 bit
    seed: resd 1

section .rodata
    newLine: db 10, 0 ; '\n'
    integerFormat: db "%d", 0
    floatFormat: db "%f", 0
    printStringFormat: db "%s", 10, 0

    ; NODEVALUE: equ 0 ; Offset of the value byte from the beginning of a node
    ; NEXTNODE: equ 1 ; Offset of the next-node field (4 bytes) from the beginning of a node

section .data
    ; var2: dd 0
    

section .text                    	
    align 16
    global main
    extern start_scheduler ; TODO
    ; extern printf
    ; extern fprintf
    ; extern sscanf
    ; extern malloc 
    ; extern calloc 
    ; extern free 
    

%macro print 1
pushad
push %1
call printf
add esp, 4
push dword [stdout]
call fflush
add esp, 4
popad
%endmacro

%macro pushReturn 0
    push edx
    push ecx
    push ebx
    push esi
    push edi
    push ebp
%endmacro

%macro popReturn 0
    pop ebp
    pop edi
    pop esi
    pop ebx
    pop ecx
    pop edx
%endmacro

; %1 is the format, %2 is the pointer to destination
%macro parseArgument %1 %2
    pushad
    push %2
    push %1
    push edx
    call sscanf
    popad
    add esp, 12
%endmacro

main:
    mov ebp, esp

    processArguments:
        mov ecx, [esp+4] ; ecx = argc
        mov ebx, [esp+8] ; ebx = argv

        ; Skip argv[0], it's just the file path
        add ebx, 4
        dec ecx

        mov edx, [ebx] ; edx = argv[i] (starting i = 1)
        parseArgument integerFormat, drones_N
        add ebx, 4
        parseArgument integerFormat, roundsTillElimination_R
        add ebx, 4
        parseArgument integerFormat, stepsTillPrinting_K
        add ebx, 4
        parseArgument floatFormat, destroyDistance_d
        add ebx, 4
        parseArgument integerFormat, seed
        add ebx, 4

    callScheduler:
        pushad
        call start_scheduler
        popad

    finishProgram:
        mov esp, ebp
        mov eax, 0 ; Program exit code
        ret