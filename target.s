section .text
global CO_TARGET_CODE
global createTarget
extern CODronesArray
extern currDrone
extern CO_DRONE_STRUCT_SIZE
extern targetXposition
extern targetYposition
extern toDiv
extern toSub
extern randomization
extern randomResult
extern floatToInt
extern resume

; Get a random number in [0, %1] and put it in %2
; NOTE: %2 can't be eax
%macro getRandomIntInto 2
    push eax
    mov dword [toDiv], %1
    mov dword [toSub], 0
    call randomization
    call floatToInt
    mov eax, [randomResult]
    mov %2, eax
    pop eax
%endmacro

CO_TARGET_CODE:
    call createTarget
    call getNextDroneCoRoutine
    call resume
    jmp CO_TARGET_CODE

createTarget:
    getRandomIntInto 100, [targetXposition]
    getRandomIntInto 100, [targetYposition]
    ret

getNextDroneCoRoutine:
    mov eax, [currDrone]
    mov ebx, [CO_DRONE_STRUCT_SIZE]
    mul ebx
    ; Result in edx:eax, assuming we can ignore edx part
    add eax, [CODronesArray]
    mov ebx, eax
    ret
