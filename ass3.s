section .bss
    ; Command line arguments
    drones_N: resd 1
    roundsTillElimination_R: resd 1
    stepsTillPrinting_K: resd 1
    destroyDistance_d: resd 1 ; float is 32 bit
    seed: resd 1destroyDistance_d

    dronesArray: resd 1 ; Pointer to array of drones_N drones, each contain:
                        ;   current position X (type: 32 bit float), position Y (float),
                        ;   speed (float), heading (float), score (32 bit int)
                        ; Note: ID is implicit, it's the index in the drones array
    targetXposition: resd 1 ; float
    targetYposition: resd 1 ; float

section .rodata
    newLine: db 10, 0 ; '\n'
    integerFormat: db "%d", 0
    floatFormat: db "%f", 0
    printStringFormat: db "%s", 10, 0

    ; Offsets from the beginning of a drone "struct"
    DRONE_POSITION_X: equ 0
    DRONE_POSITION_Y: equ 4
    DRONE_SPEED: equ 8
    DRONE_HEADING: equ 12
    DRONE_SCORE: equ 16
    DRONE_STRUCT_SIZE: equ 20

section .data
    ; var2: dd 0
    

section .text                    	
    align 16

    global main

    global drones_N
    global roundsTillElimination_R
    global stepsTillPrinting_K
    global destroyDistance_d
    global seed

    global dronesArray
    global DRONE_POSITION_X
    global DRONE_POSITION_Y
    global DRONE_SPEED
    global DRONE_HEADING
    global DRONE_SCORE
    global DRONE_STRUCT_SIZE
    
    global targetXposition
    global targetYposition

    extern start_scheduler ; TODO
    extern sscanf
    ; extern printf
    ; extern fprintf
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
%macro parseArgument 2
    add ebx, 4
    mov edx, [ebx] ; edx = argv[i] (starting i = 1)
    pushad
    push %2
    push %1
    push edx
    call sscanf
    add esp, 12
    popad
%endmacro

main:
    mov ebp, esp

    processArguments:
        ; mov ecx, [esp+4] ; ecx = argc
        mov ebx, [esp+8] ; ebx = argv

        ; Inside the macro, skips argv[0], it's just the file path
        parseArgument integerFormat, drones_N
        parseArgument integerFormat, roundsTillElimination_R
        parseArgument integerFormat, stepsTillPrinting_K
        parseArgument floatFormat, destroyDistance_d
        parseArgument integerFormat, seed

    allocateDronesArray:
        mov eax, [drones_N]
        mov ebx, DRONE_STRUCT_SIZE
        mul ebx
        ; Result in edx:eax, assuming we can ignore edx part
        
        pushad
        push eax
        call malloc
        mov dword [dronesArray], eax
        add esp, 4
        popad

    initializeTarget:
        ; TODO: call randomization function to get:
        ; x coordinate, y coordinate
        nop ; TODO: Delete this command
        
    initializeDrones:
        ; TODO: For each drone call randomization function to get (in this order):
        ; x coordinate, y coordinate, speed, angle (and convert to radians)
        ; and set score = 0
        nop ; TODO: Delete this command
        


; Initial configuration:
;     Allocate space and initialize the co-routine structures. 
;     Two additional co-routines should be initialized: scheduler and printer.


    callScheduler:
        pushad
        ; call start_scheduler
        popad

    freeDronesArray:
        pushad
        push [dronesArray]
        call free
        add esp, 4
        popad

    finishProgram:
        mov esp, ebp
        mov eax, 0 ; Program exit code
        ret