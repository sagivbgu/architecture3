section .text
    global CO_SCHEDULER_CODE
    extern CO_PRINTER
    extern end_scheduler
    extern drones_N
    extern stepsTillPrinting_K
    extern roundsTillElimination_R
    extern CODronesArray
    extern dronesArray
    extern currDrone
    extern resume

section .data
    index: dd 0
    min: dd 0
    toDestroy: dd 0
    liveDrones: dd 0

section .rodata
    CO_STKSZ: equ 16*1024 ; Co-routine stack size

    ; Offsets from the beginning of a co-routine "struct"
    CO_CODE: equ 0 ; Address of code to execute (IP)
    CO_STACK: equ 4
    CO_STRUCT_SIZE: equ 8

    CO_DRONE_START_OF_STACK: equ 8
    CO_DRONE_STRUCT_SIZE: equ 12

    ; Offsets from the beginning of a drone "struct"
    DRONE_POSITION_X: equ 0
    DRONE_POSITION_Y: equ 4
    DRONE_SPEED: equ 8
    DRONE_HEADING: equ 12
    DRONE_SCORE: equ 16
    DRONE_ACTIVE: equ 20
    DRONE_STRUCT_SIZE: equ 24

%macro activeCurrDrone 0 
    mov dword eax, [currDrone]
    cmp edx, eax ;edx has the reminder of index%num_drone
    jne %%end
    mov ebx, [dronesArray]
    %%loopActive:
        cmp eax, [drones_N]
        jl %%continue ;has to be smaller- else we need to go to the beginning of the array
        mov dword [eax], 0 ;else go to the end of the array until you find other active drone
        %%continue:
            mul dword [DRONE_STRUCT_SIZE]
            mov ecx, [ebx + eax + DRONE_ACTIVE] ; now we point at the next drone
            div dword[DRONE_STRUCT_SIZE] ; so eax will be index again
            cmp dword ecx, 1 ;checking if the next drone in the array is active
            je %%changeActive
            inc eax
            jmp %%loopActive
        %%changeActive:
            mov dword[currDrone], eax
            mul dword [CO_DRONE_STRUCT_SIZE]
            mov ebx, [CODronesArray + eax + CO_CODE ]
            jmp resume
    %%end:
%endmacro 

%macro printK 0
    cmp edx, 0
    jne endPrint
    mov ebx, CO_PRINTER
    jmp resume
    endPrint:
%endmacro

%macro RRounds 0
    ;;dec [numDrones]
    cmp edx, 0
    jne endR
    mov dword ecx, 0
    mov dword [min], 0
    mov dword [toDestroy], 0
    loopRRound:
        cmp ecx, [drones_N] ;counter
        je endR ;needs to stop when -1 bc 0 its still valid in the array 
        mov ebx, [dronesArray]
        cmp dword [ebx + DRONE_ACTIVE], 0
        je _step
        cmp dword [ebx + DRONE_SCORE] , min
        jle _min
        jmp _step
        _min:
            mov eax, [ebx + DRONE_SCORE]
            mov dword [min], eax
            mov dword [toDestroy], ecx
        _step:
            add ebx, DRONE_STRUCT_SIZE
            inc ecx
            jmp loopRRound
    endR:
        dec dword[liveDrones]
        mov eax, [toDestroy]
        mul dword[DRONE_STRUCT_SIZE]
        mov ebx, [dronesArray]
        mov [ebx + eax + DRONE_ACTIVE], 0
%endmacro

CO_SCHEDULER_CODE:
    mov eax, 0 
    mov eax, [drones_N]
    mov dword [liveDrones], eax
    loopScheduler:
        mov ebx, 1
        cmp ebx, [liveDrones] ;checking if there is only one drone left
        je endLoop
        ;;------------------ we have more than one drone
        mov eax, [index]
        mov edx, 0
        div dword [drones_N] ;;edx has the reminder
        activeCurrDrone
        mov eax, [index]
        mov edx, 0
        div dword [stepsTillPrinting_K]
        ;printK
        mov eax, [index]
        mov edx, 0
        div dword [roundsTillElimination_R]
        RRounds
        inc dword[index]
        jmp loopScheduler
        endLoop:

    ;;call printer for the winner
    ret ; TODO
    jmp end_scheduler
