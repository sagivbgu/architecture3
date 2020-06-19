section .rodata
    num360: dd 360
    num180: dd 180
    num100: dd 100
    num0: dd 0

section .text
global CO_DRONE_CODE
extern CO_SCHEDULER
extern CO_TARGET
extern destroyDistance_d
extern dronesArray
extern currDrone
extern DRONE_POSITION_X
extern DRONE_POSITION_Y
extern DRONE_SPEED
extern DRONE_HEADING
extern DRONE_SCORE
extern DRONE_STRUCT_SIZE
extern targetXposition
extern targetYposition
extern toDiv
extern toSub
extern randomization
extern randomResult
extern floatToInt
extern resume

%macro toRadians 0
    fldpi
    fmulp
    fld dword [num180]
    fdivp
%endmacro

%macro droneMovenent 1
    fld dword [edx + DRONE_SPEED]
    fmulp
    fild dword [edx + %1]
    faddp
    fild dword [num100]

    ; Check above 100:
    fcomi
    ja %%checkBelowMinus100 ; jump if 100 > Y
    fsubp st1, st0 ; Y = Y - 100
    jmp %%save

    %%checkBelowMinus100:
    fchs ; Change sign. st0 = -100
    fcomip
    jb %%save ; jump if -100 < Y
    fiadd dword [num100] ; Y = Y + 100

    %%save: fstp dword [edx + %1]
%endmacro

CO_DRONE_CODE:
    call getCurrentDroneStructAddr
    mov edx, eax
    ; edx = Address of the current drone's struct
    
    call moveDrone
    call updateDroneHeading
    call updateDroneSpeed

    droneLoop:
    call mayDestroy
    cmp eax, 0
    je droneStep

    inc dword [edx + DRONE_SCORE]
    mov ebx, CO_TARGET
    call resume

    droneStep:
    call moveDrone
    call updateDroneHeading
    call updateDroneSpeed
    mov ebx, CO_SCHEDULER
    call resume
    jmp droneLoop

; Put address of the current drone's struct in eax
getCurrentDroneStructAddr:
    push ebx
    mov eax, [currDrone]
    mov ebx, [DRONE_STRUCT_SIZE]
    mul ebx
    ; Result in edx:eax, assuming we can ignore edx part
    add eax, [dronesArray] 
    pop ebx
    ret

moveDrone:
    finit
    fld dword [edx + DRONE_HEADING]
    toRadians
    fsincos
    droneMovenent DRONE_POSITION_Y
    droneMovenent DRONE_POSITION_X
    ffree
    ret

updateDroneHeading:
    mov dword [toDiv], 120
    mov dword [toSub], 60
    call randomization ; [-60, 60]

    finit
    fld dword [randomResult]
    fadd dword [edx + DRONE_HEADING]
    fild dword [num360]
    fcomip
    ja checkHeadingBelow0 ; jump if 360 > new heading
    fisub dword [num360]
    jmp saveDroneHeading
    
    checkHeadingBelow0:
    fild dword [num0]
    fcomip
    jb saveDroneHeading ; jump if 0 < new heading
    fiadd dword [num360]
    
    saveDroneHeading:
    fstp dword [edx + DRONE_HEADING]
    ffree
    ret

updateDroneSpeed:
    mov dword [toDiv], 20
    mov dword [toSub], 10
    call randomization ; [-10, 10]

    finit
    fld dword [randomResult]
    fadd dword [edx + DRONE_SPEED]
    fild dword [num100]
    fcomip
    ja checkSpeedBelow0 ; jump if 100 > new drone speed
    fild dword [num100]
    fstp dword [edx + DRONE_SPEED] ; new drone speed = 100
    jmp endUpdateDroneSpeed
    
    checkSpeedBelow0:
    fild dword [num0]
    fcomi
    jb endUpdateDroneSpeed ; jump if 0 < new drone speed
    fstp dword [edx + DRONE_SPEED] ; new drone speed = 0

    endUpdateDroneSpeed:
    ffree
    ret

; Returns 1 in eax if may destroy, else 0
mayDestroy:
    mov eax, 0
    finit
    fild dword [edx + DRONE_POSITION_X]
    fisub dword [targetXposition] ; st0 = droneX - targatX
    fmul st0, st0

    fild dword [edx + DRONE_POSITION_Y]
    fisub dword [targetYposition] ; st0 = droneY - targatY
    fmul st0, st0

    faddp
    fsqrt
    fld dword [destroyDistance_d]
    fcomi
    ja endMayDestroy ; jump if d > current distance from target
    mov eax, 1

    endMayDestroy:
    ffree
    ret
