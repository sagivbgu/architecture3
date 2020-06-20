section .rodata
    num360: dd 360
    num180: dd 180
    num100: dd 100
    num0: dd 0

    DRONE_POSITION_X: equ 0
    DRONE_POSITION_Y: equ 4
    DRONE_SPEED: equ 8
    DRONE_HEADING: equ 12
    DRONE_SCORE: equ 16
    DRONE_ACTIVE: equ 20
    DRONE_STRUCT_SIZE: equ 24

section .text
global CO_DRONE_CODE
extern CO_SCHEDULER
extern CO_TARGET
extern destroyDistance_d
extern dronesArray
extern currDrone
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
    fild dword [num180]
    fdivp
%endmacro

%macro droneMovenent 1
    fld dword [edx + DRONE_SPEED]
    fmulp
    fld dword [edx + %1]
    faddp
    fild dword [num100]

    ; Check above 100:
    fcomi
    ja %%checkBelow0 ; jump if 100 > Y
    fsubp st1, st0 ; Y = Y - 100
    jmp %%save

    %%checkBelow0:
    fisub dword [num100] ; Change sign. st0 = 0
    fcomip
    jb %%save ; jump if 0 < Y
    fiadd dword [num100] ; Y = Y + 100

    %%save:
    fstp dword [edx + %1]
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
    mov ebx, DRONE_STRUCT_SIZE
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
    droneMovenent DRONE_POSITION_X
    droneMovenent DRONE_POSITION_Y
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
    pushad
    mov eax, 0
    finit
    fld dword [edx + DRONE_POSITION_X]
    fisub dword [targetXposition] ; st0 = droneX - targatX
    fmul st0, st0

    fld dword [edx + DRONE_POSITION_Y]
    fisub dword [targetYposition] ; st0 = droneY - targatY
    fmul st0, st0

    faddp
    fsqrt
    fld dword [destroyDistance_d]
    fcom
    jb endMayDestroy ; jump if d < current distance from target
    mov eax, 1

    endMayDestroy:
    ffree
    popad
    ret