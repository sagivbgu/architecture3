section .text
    global CO_SCHEDULER_CODE
    extern end_scheduler
    extern numDrones
    extern kSteps
    extern R

section .data
    index: db 0
    currDrone: db 0

%macro activeCurrDrone 0
    mov bl, [currDrone]
    inc bl
    cmp ah, bl
    jne end
    ;;active next drone
    %%end:
%endmacro 

%macro printK 0
    cmp ah, 0
    ;; call the printer
%endmacro

%macro RRounds 0
    ;;dec [numDrones]
%endmacro

CO_SCHEDULER_CODE:

    mov ax, [index]
    div numDrones ;;ah has the reminder
    activeCurrDrone
    div kSteps
    div R
    RRounds
    inc ax
    cmp byte 1, [numDrones]
    jne CO_SCHEDULER_CODE

    ;;call printer for the winner
    ret ; TODO
    jmp end_scheduler
