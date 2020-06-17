section .rodata
    floatFormat: db "%.2f", 0
    newLine: db 10, 0 ; '\n'
    separator: db "," , 0

section .text
global CO_PRINTER_CODE
extern CO_SCHEDULER
extern drones_N
extern dronesArray
extern DRONE_POSITION_X
extern DRONE_POSITION_Y
extern DRONE_SPEED
extern DRONE_HEADING
extern DRONE_SCORE
extern DRONE_ACTIVE
extern CO_DRONE_STRUCT_SIZE
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
    push dword floatFormat
    push %1
    call printf
    add esp, 8
    ; push dword [stdout]
    ; call fflush
    ; add esp, 4
    popad
%endmacro

%macro printInt 1
    pushad
    push dword integerFormat
    push %1
    call printf
    add esp, 8
    ; push dword [stdout]
    ; call fflush
    ; add esp, 4
    popad
%endmacro

CO_PRINTER_CODE:
    printFloat dword [targetXposition]
    print separator
    printFloat dword [targetYposition]
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
        printInt dword [ebx + DRONE_POSITION_X]
        print separator
        printInt dword [ebx + DRONE_POSITION_Y]
        print separator
        printInt dword [ebx + DRONE_HEADING]
        print separator
        printFloat dword [ebx + DRONE_SPEED]
        print separator
        printInt dword [ebx + DRONE_SCORE]
        print newLine

    proceedPrintLoop:
        add ebx, CO_DRONE_STRUCT_SIZE
        inc ecx
        cmp ecx, [drones_N]
        jne printLoop
    
    mov ebx, [CO_SCHEDULER]
    call resume
    jmp CO_PRINTER_CODE