.data
    PresionControl: .word 0xffff0000
    PresionEstado:  .word 0xffff0004
    PresionDatos:   .word 0xffff0008

    msg_error:      .asciiz "Error critico detectado: fallo tras reintento.\n"
    msg_exito:      .asciiz "Lectura exitosa: "

.text
.globl main

main:
    jal InicializarSensorPresion
    jal LeerPresion
    
    beq $v1, -1, imprimir_error

    move $t2, $v0
    li $v0, 4
    la $a0, msg_exito
    syscall
    
    li $v0, 1
    move $a0, $t2
    syscall
    j terminar

imprimir_error:
    li $v0, 4
    la $a0, msg_error
    syscall

terminar:
    li $v0, 10
    syscall

InicializarSensorPresion:
    lw $t0, PresionControl
    li $t1, 0x5
    sw $t1, 0($t0)
    jr $ra

LeerPresion:
    li $t7, 0               

bucle_lectura:
    lw $t0, PresionEstado
    lw $t1, 0($t0)          
    
    beq $t1, $zero, bucle_lectura 
    beq $t1, -1, manejar_error    
    
    lw $t0, PresionDatos
    lw $v0, 0($t0)          
    li $v1, 0               
    jr $ra

manejar_error:
    bne $t7, $zero, error_final 
    
    li $t7, 1               
    addi $sp, $sp, -4       
    sw $ra, 0($sp)
    jal InicializarSensorPresion
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    j bucle_lectura         

error_final:
    li $v0, 0               
    li $v1, -1              
    jr $ra