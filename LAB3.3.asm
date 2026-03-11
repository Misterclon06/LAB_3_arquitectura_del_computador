.data
    # Direcciones mapeadas en memoria 
    ADDR_CONTROL:  .word 0xffff0000
    ADDR_ESTADO:   .word 0xffff0004
    ADDR_SISTOL:   .word 0xffff0008
    ADDR_DIASTOL:  .word 0xffff000c

    msg_iniciando: .asciiz "Iniciando medicion de tension...\n"
    msg_resultado: .asciiz "Medicion completa. Sistolica: "
    msg_diastol:   .asciiz ", Diastolica: "

.text
.globl main

main:
    jal controlador_tension
    
    move $s0, $v0
    move $s1, $v1

    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_diastol
    syscall

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 10
    syscall

controlador_tension:

    lw $t0, ADDR_CONTROL
    lw $t1, ADDR_ESTADO
    lw $t2, ADDR_SISTOL
    lw $t3, ADDR_DIASTOL

    li $v0, 4
    la $a0, msg_iniciando
    syscall
    
    li $t4, 1
    sw $t4, 0($t0)     

bucle_espera:
    lw $t4, 0($t1)      
    beq $t4, $zero, bucle_espera 

    lw $v0, 0($t2)      
    lw $v1, 0($t3)      
    
    jr $ra