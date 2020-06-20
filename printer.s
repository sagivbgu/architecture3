section .rodata
    floatFormat: db "%.2f", 0
    newLine: db 10, 0 ; '\n'
    separator: db "," , 0

    DRONE_POSITION_X: equ 0
    DRONE_POSITION_Y: equ 4
    DRONE_SPEED: equ 8
    DRONE_HEADING: equ 12
    DRONE_SCORE: equ 16
    DRONE_ACTIVE: equ 20
    DRONE_STRUCT_SIZE: equ 24

section .text
global CO_PRINTER_CODE
extern CO_SCHEDULER
extern drones_N
extern dronesArray
extern targetXposition
extern targetYposition
extern integerFormat
extern resume
extern printf

%macro print 1
    pushad
    push %1
    call printf
    add esp, 4
    ; push dword [stdout]
    ; call fflush
    ; add esp, 4
    popad
%endmacro

%macro printFloat 1
    pushad
    
    finit
    fld dword %1
    sub esp, 8
    fstp qword [esp]
    ffree
    
    push dword floatFormat
    call printf
    add esp, 12
    ; push dword [stdout]
    ; call fflush
    ; add esp, 4
    popad
%endmacro

%macro printInt 1
    pushad
    push dword %1
    push dword integerFormat
    call printf
    add esp, 8
    ; push dword [stdout]
    ; call fflush
    ; add esp, 4
    popad
%endmacro

CO_PRINTER_CODE:
    printInt [targetXposition]
    print separator
    printInt [targetYposition]
    print newLine
    
    mov ebx, [dronesArray]
    mov ecx, 0

    printLoop:
        mov eax, dword [ebx + DRONE_ACTIVE]
        cmp eax, 0
        je proceedPrintLoop

        inc ecx ; So the first index will be 1
        printInt ecx
        dec ecx
        print separator
        printInt [ebx + DRONE_POSITION_X]
        print separator
        printInt [ebx + DRONE_POSITION_Y]
        print separator
        printFloat [ebx + DRONE_HEADING]
        print separator
        printFloat [ebx + DRONE_SPEED]
        print separator
        printInt [ebx + DRONE_SCORE]
        print newLine

    proceedPrintLoop:
        add ebx, DRONE_STRUCT_SIZE
        inc ecx
        cmp ecx, [drones_N]
        jne printLoop
    
    mov ebx, CO_SCHEDULER
    call resume
    jmp CO_PRINTER_CODE