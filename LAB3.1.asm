.data
    # direcciones de memoria
    LuzControl: .word 0xffff0000
    LuzEstado:  .word 0xffff0004
    LuzDatos:   .word 0xffff0008

    # Mensajes
    msg_init:   .asciiz "Inicializando sensor...\n"
    msg_ready:  .asciiz "Sensor listo.\n"
    msg_error:  .asciiz "Error en el sensor.\n"
    msg_valor:  .asciiz "Valor de luminosidad: "
    salto:      .asciiz "\n"

.text
.globl main

main:
    # 1. Inicializar y esperar
    jal InicializarSensorLuz
    
    # 2. Leer sensor
    jal LeerLuminosidad
    
    li $v0, 10         
    syscall

InicializarSensorLuz:
    # Imprimir mensaje inicial
    la $a0, msg_init
    li $v0, 4
    syscall

    lw $t0, LuzControl   # Cargar dirección
    li $t1, 1
    sw $t1, 0($t0)       # Escribir 0x1 en LuzControl

esperar_listo:
    lw $t0, LuzEstado    # Cargar dirección LuzEstado
    lw $t1, 0($t0)       # Leer valor de estado
    
    beq $t1, $zero, esperar_listo # Si es 0, esperar
    beq $t1, -1, error_sensor    # Si es -1, error
    
    la $a0, msg_ready
    li $v0, 4
    syscall
    jr $ra

LeerLuminosidad:
    lw $t0, LuzEstado
    lw $t1, 0($t0)
    
    # Verificar si sigue listo
    li $t2, 1
    bne $t1, $t2, error_sensor
    
    lw $t0, LuzDatos      # Cargar dirección LuzDatos
    lw $v0, 0($t0)        # Cargar el valor (0-1023)
    li $v1, 0             # Estado 0: OK
    
    # Imprimir valor
    move $t3, $v0
    la $a0, msg_valor
    li $v0, 4
    syscall
    move $a0, $t3
    li $v0, 1
    syscall
    jr $ra

error_sensor:
    la $a0, msg_error
    li $v0, 4
    syscall
    li $v0, -1
    jr $ra
