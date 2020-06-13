section .text
    global CO_SCHEDULER_CODE
    extern end_scheduler
    extern drones_N
    extern stepsTillPrinting_K
    extern roundsTillElimination_R

section .data
    index: dd 0
    currDrone: dd 0

%macro activeCurrDrone 0
    mov ebx, [currDrone]
    inc ebx
    cmp edx, ebx
    jne end
    ;;active next drone
    %%end:
%endmacro 

%macro printK 0
    cmp ebx, 0
    ;; call the printer
%endmacro

%macro RRounds 0
    ;;dec [numDrones]
%endmacro

CO_SCHEDULER_CODE:

    mov eax, [index]
    mov edx, 0
    div [drones_N] ;;edx has the reminder
    activeCurrDrone
    div stepsTillPrinting_K
    printK
    div roundsTillElimination_R
    RRounds
    inc eax
    cmp byte 1, [numDrones]
    jne CO_SCHEDULER_CODE

    ;;call printer for the winner
    ret ; TODO
    jmp end_scheduler
