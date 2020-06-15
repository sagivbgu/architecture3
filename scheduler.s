section .text
    global CO_SCHEDULER_CODE
    extern end_scheduler
    extern drones_N
    extern stepsTillPrinting_K
    extern roundsTillElimination_R
    extern CODronesArray
    extern dronesArray
    extern currDrone

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
    inc eax
    cmp edx, eax ;edx has the reminder of index%num_drone
    jne %%end
    ; we need to turn up the i drone + take into consideration the array size bc we go down
    ;mul dword [DRONE_STRUCT_SIZE]
    mov ebx, [dronesArray]
    ;mov ecx, [ebx + eax] ; now we point at the active drone
    dec eax ;the i'th place- contra to line 39
    %%loopActive:
        cmp eax, 0
        jge %%continue ;if i is equal-bigger than 0
        mov dword [eax], drones_N ;else go to the end of the array until you find other active drone
        %%continue:
            mul dword [DRONE_STRUCT_SIZE]
            mov ecx, [ebx + eax] ; now we point at the next drone
            div dword[DRONE_STRUCT_SIZE] ; so eax will be index again
            cmp dword [ecx + DRONE_ACTIVE], 1 ;checking if the next drone in the array is active
            je %%end
            dec eax
            jmp %%loopActive
    %%end:
    mov dword[currDrone], eax
    ;change to the right co - routine to work TODO
%endmacro 

%macro printK 0
    cmp edx, 0
    jne endPrint
    ;; call the printer TODO
    endPrint:
%endmacro

%macro RRounds 0
    ;;dec [numDrones]
    cmp edx, 0
    jne endR
    mov dword ecx, [drones_N]
    mov dword [min], 0
    mov dword [toDestroy], 0
    loopRRound:
        cmp ecx, 0 ;counter
        jl endR ;needs to stop when -1 bc 0 its still valid in the array
        dec ecx ; the index is always -1 
        mov ebx, [dronesArray]
        mov dword eax, [DRONE_STRUCT_SIZE]
        mul ecx
        mov edx, [ebx + eax] ;points to drone
        cmp byte [edx + DRONE_ACTIVE], 0
        je loopRRound
        mov eax, 0
        mov dword eax, [edx + DRONE_SCORE]
        cmp dword eax, min
        jl _min
        jmp loopRRound
        _min:
        mov dword [min], eax
        mov dword [toDestroy], ecx
        jmp loopRRound
    endR:
    dec dword[liveDrones]
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
        mov edx, 0
        div dword [stepsTillPrinting_K]
        printK
        mov edx, 0
        div dword [roundsTillElimination_R]
        RRounds
        inc dword[index]
        jmp loopScheduler
        endLoop:

    ;;call printer for the winner
    ret ; TODO
    jmp end_scheduler
