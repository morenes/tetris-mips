# Version completa del tetris 
# Sincronizada con tetris.s:r2236
        
	.data	

	.align	2
pantalla:
	.word	0
	.word	0
	.space	1024

	.align	2
campo:
	.word	0
	.word	0
	.space	1024

	.align	2
pieza_actual:
	.word	0
	.word	0
	.space	1024
	
	.align	2
pieza_siguiente:
	.word	0
	.word	0
	.space	1024

	.align 2
pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

puntuacion:
	.word 0
tiempo_pausa:
	.word 500
tiempo_pausa_guardar:
	.word 0
tiempo_pausa_cont:
	.word 0

	.align	2
buffer:	.space 256

	.align	2
buffer2: 
	.space 256

	.align	2
imagen_auxiliar:
	.word	0
	.word	0
	.space	1024
	
	.align	2
mensaje_puntuacion:
	.word	6
	.word	1	
	.asciiz		"score:"
	
	.align	2
mensaje_fin:
	.word	17
	.word	7
	.ascii		"+---------------+|               ||FIN DE PARTIDA ||               ||Pulse una tecla||               |+---------------+"

recuadro_pieza_sig:
	.word	5
	.word	6
	.ascii		"+---+|\0\0\0||\0\0\0||\0\0\0||\0\0\0|+---+"

	.align	2
pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

	.align	2
pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

	.align	2
pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

	.align	2
pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

	.align	2
pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

	.align	2
pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

	.align	2
pieza_te:
	.word	3
	.word	2
	.asciiz		"\0#\0###\0\0"

	.align	2
piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'p'
	.space	3
	.word	tecla_pausa
	.byte	'm'
	.space	3
	.word	tecla_secreta
	.byte	'a'
	.space	3
	.word	tecla_izquierda
	.byte	'd'
	.space	3
	.word	tecla_derecha
	.byte	's'
	.space	3
	.word	tecla_abajo
	.byte	'w'
	.space	3
	.word	tecla_rotar

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n 3 - Configuracion\n\nElige una opcion:\n"
str001:
	.asciiz		"\nAdios!\n"
str002:
	.asciiz		"\nOpcion incorrecta. Pulse cualquier tecla para seguir.\n"
str003:
	.asciiz		"\nElige el ancho del juego(10 minimo).\n"
str004:
	.asciiz		"\nElige el alto del juego.\n"
str005:
	.asciiz		"\nNivel de dificultad\n\n 1 - Principiante\n 2 - Veterano\n 3 - Chuck Norris\n\nElige una opcion:\n"

	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = direcci贸n de la imagen 
					# $t1 鈫? ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 鈫? direcci贸n del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_set_pixel:			# ($a0, $a1, $a2,$a3) = (img, x, y,color)
	addiu	$sp, $sp, -8
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	sw	$s3, 4($sp)
	move	$s3,$a3
	jal	imagen_pixel_addr	# (img, x, y,char) ya en ($a0, $a1, $a2)
	sb	$s3, 0($v0)		# lee el pixel a devolver
	lw	$s3, 4($sp)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_clean:			# ($a0, $a1) = (img,color)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s1, $a1		# color
	move	$s0, $a0		#img
	
	# for (int y = 0; y<img->ancho; ++y) {
	lw	$s5, 4($s0)		#img->alto
	beqz	$s5, C_4
	li	$s2, 0			# y = 0
	#   for (int x = 0; x < img->alto; ++x) {
	lw	$s4, 0($s0)		#img->ancho
C_1:	beqz	$s4, C_3
	li	$s3, 0			# x = 0
C_2:	
	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s2
	move	$a3, $s1
	jal	imagen_set_pixel	# imagen_set_pixel(img,x,y,color)

	addiu	$s3, $s3, 1		# ++x
	bltu	$s3, $s4, C_2		# sigue si x <img->ancho
        #   } // for j
C_3:	
	addiu	$s2, $s2, 1		# ++y
	bltu	$s2, $s5, C_1 	# sigue si y < img->alto
        # } // for i

C_4:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp, $sp, 28
	jr	$ra
        
imagen_init:				# ($a0, $a1, $a2,$a3) = (img,ancho,alto,color)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	move	$s3,$a3
	sw	$a1,0($a0)
	sw	$a2,4($a0)
	move $a1,$a3
	jal	imagen_clean		# (img,color) ya en ($a0, $a1)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
imagen_copy:				# ($a0, $a1) = (dst,src)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s1, $a1		#src
	move	$s0, $a0		#dst
	lw	$s2,0($s1)	#src->ancho
	sw	$s2,0($s0)	#dst->ancho=src->ancho
	lw	$s3,4($s1)	#src->alto
	sw	$s3,4($s0)	#dst->alto=src->alto
	# for (int y = 0; y<img->alto; ++y) {
	beqz	$s3, C_13
	li	$s4, 0			# y = 0
	#   for (int x = 0; x < img->ancho; ++x) {
C_6:	beqz	$s2, C_11
	li	$s5, 0			# x = 0
C_8:	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel	# imagen_get_pixel(src,x,y)
	move	$a0, $s0
	move	$a1, $s5
	move	$a2, $s4
	move	$a3, $v0
	jal	imagen_set_pixel	# imagen_set_pixel(dst,x,y,color)	
	addiu	$s5, $s5, 1		# ++x
	bltu	$s5, $s2, C_8		# sigue si x <img->ancho
        #   } // for j
C_11:	
	addiu	$s4, $s4, 1		# ++y
	bltu	$s4, $s3, C_6 	# sigue si y < img->alto
        # } // for i

C_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp, $sp, 28
	jr	$ra
        
imagen_print:				# $a0 = img
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
        #  for (int y = 0; y < img->alto; ++y)
	lw	$t1, 4($s0)		# img->alto
	beqz	$t1, B6_5
	li	$s1, 0			# y = 0
	#    for (int x = 0; x < img->ancho; ++x)
B6_2:	lw	$t1, 0($s0)		# img->ancho
	beqz	$t1, B6_4
	li	$s2, 0			# x = 0
B6_3:	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	lw	$t1, 0($s0)		# img->ancho
	bltu	$s2, $t1, B6_3		# sigue si x < img->ancho
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	lw	$t1, 4($s0)		# img->alto
	bltu	$s1, $t1, B6_2		# sigue si y < img->alto
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra

imagen_dibuja_imagen:			# ($a0, $a1,$a2,$a3) = (dst,src,dst_x,dst_y)
	addiu	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s1, $a1		#src
	move	$s0, $a0		#dst
	lw	$s2,0($s1)	#src->ancho
	lw	$s3,4($s1)	#src->alto
	move $s6,$a2		#dst_x
	move $s7,$a3		#dst_y
	# for (int y = 0; y<src->alto; ++y) {
	beqz	$s3, C_25
	li	$s4, 0			# y = 0
	#   for (int x = 0; x < src->ancho; ++x) {
C_21:	beqz	$s2, C_25
	li	$s5, 0			# x = 0
C_22:	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel	# imagen_get_pixel(src,x,y)
	beqz 	$v0,C_23
	move	$a0, $s0
	add		$a1, $s5,$s6
	add		$a2, $s4,$s7
	move	$a3, $v0
	jal	imagen_set_pixel	# imagen_set_pixel(dst,x,y,color)	
	
C_23	: addiu	$s5, $s5, 1		# ++x
	bltu		$s5, $s2, C_22		# sigue si x src->ancho
        #   } // for x
	addiu	$s4, $s4, 1		# ++y
	bltu	$s4, $s3, C_21 	# sigue si y < src->alto
        # } // for y

C_25:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36
	jr	$ra

imagen_dibuja_imagen_rotada:		# ($a0, $a1,$a2,$a3) = (dst,src,dst_x,dst_y)
	addiu	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s1, $a1		#src
	move	$s0, $a0		#dst
	lw	$s2,0($s1)	#src->ancho
	lw	$s3,4($s1)	#src->alto
	move $s6,$a2		#dst_x
	move $s7,$a3		#dst_y
	# for (int y = 0; y<img->alto; ++y) {
	beqz	$s3, C_35
	li	$s4, 0			# y = 0
	#   for (int x = 0; x < img->ancho; ++x) {
C_31:	beqz	$s2, C_35
	li	$s5, 0			# x = 0
C_32:	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel	# imagen_get_pixel(src,x,y)
	beqz 	$v0,C_33
	move	$a0, $s0
	subi		$t3,$s3,1
	sub		$t3,$t3,$s4
	add		$a1, $t3,$s6
	add		$a2, $s5,$s7
	move	$a3, $v0
	jal	imagen_set_pixel	# imagen_set_pixel(dst,x,y,color)	
	
C_33	: addiu	$s5, $s5, 1		# ++x
	bltu		$s5, $s2, C_32		# sigue si x <src->ancho
        #   } // for x	
	addiu	$s4, $s4, 1		# ++y
	bltu	$s4, $s3, C_31 	# sigue si y < src->alto
        # } // for y

C_35:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36
	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 6	
	jal	random_int_range	# $v0 鈫? random_int_range(0, 6)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 鈫? piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$s0, pantalla
	la	$s2, campo
	move	$a0, $s0
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	lw	$t1, 4($s2)		# campo->alto
	beqz	$t1, B10_3		# sale del bucle si campo->alto == 0
	li	$s1, 0			# y = 0
B10_2:	addiu	$s1, $s1, 1		# ++y
	move	$a0, $s0
	li	$a1, 0
	move	$a2, $s1
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	lw	$t1, 0($s2)		# campo->ancho
	move	$a0, $s0
	addiu	$a1, $t1, 1		# campo->ancho + 1
	move	$a2, $s1
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
	lw	$t1, 4($s2)		# campo->alto
	bltu	$s1, $t1, B10_2		# sigue si y < campo->alto
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:	lw	$t1, 4($s2)		# campo->alto
	move	$a0, $s0
	move	$a1, $s1
	addiu	$a2, $t1, 1		# campo->alto + 1
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$t1, $t1, 2		# campo->ancho + 2
	bltu	$s1, $t1, B10_5		# sigue si x < campo->ancho + 2
        # } // for x
B10_6:	la	$s0, pantalla
	move	$a0, $s0
	move	$a1, $s2
	li	$a2, 1
	li	$a3, 1
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 1)
	lw	$t1, pieza_actual_y
	lw	$v0, pieza_actual_x
	move	$a0, $s0
	la	$a1, pieza_actual
	addiu	$a2, $v0, 1		# pieza_actual_x + 1
	addiu	$a3, $t1, 1		# pieza_actual_y + 1
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + 1, pieza_actual_y + 1)
	lw	$a0,puntuacion
	la	$a1,buffer2
	jal integer_to_string
	move		$a0,$s0
	la		$a1,mensaje_puntuacion
	li		$a2,0
	li		$a3,0
	jal		imagen_dibuja_imagen 	#imprime el mensaje previo a la puntuacion
	move	$a0,$s0
	lw		$t5,mensaje_puntuacion  #mensaje_puntuacion->ancho
	move	$a1,$t5
	li		$a2,0
	la		$a3,buffer2	
	jal imagen_dibuja_cadena		#imprime la puntuacion
	move	$a0,$s0
	la		$a1,pieza_siguiente
	lw		$t6,campo
	addi		$s6,$t6,3
	move	$a2,$s6
	li		$a3,4
	jal		imagen_dibuja_imagen	#imprime la imagen siguiente
	move	$a0,$s0
	la		$a1,recuadro_pieza_sig
	subi		$a2,$s6,1
	li		$a3,3
	jal		imagen_dibuja_imagen	#imprime el recuadro de la imagen siguiente
	jal	clear_screen		# clear_screen()
	move	$a0, $s0
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
nueva_pieza_siguiente:
	addiu	$sp, $sp, -4
	sw		$ra, 0($sp)
	jal		pieza_aleatoria	# $v0 鈫?pieza_aleatoria()
	move	$a1,$v0
	la		$a0,pieza_siguiente
	jal		imagen_copy
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr		$ra
nueva_pieza_actual:			# (void) = (void)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	la	$a1,pieza_siguiente
	la	$a0,pieza_actual
	jal	imagen_copy
	lw	$t1,campo
	div	$t1,$t1,2
	sw	$t1,	pieza_actual_x
	sw	$zero,pieza_actual_y
	jal	nueva_pieza_siguiente
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:		# ($a0, $a1) = ( x, y)
	addiu	$sp, $sp, -12
	sw	$ra,8($sp)
	sw	$s1, 4($sp)	
	sw	$s0, 0($sp)
	move $s0,$a0
	move $s1,$a1
	move $a2,$a1
	move $a1,$a0
	la	$a0,pieza_actual
	jal	probar_pieza
	beqz $v0,C_41
	sw	$s0,pieza_actual_x
	sw	$s1,pieza_actual_y
C_41:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

bajar_pieza_actual: #($a0)=(si baja o sube)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	bne	$a0,-2,C_48			#comprobacion para ver si se ha pulsado la tecla magica
	move $t1,$a0
	j	C_49
C_48: li 	$t1,1				#si no se ha pulsado baja normal
C_49: lw	$a0,pieza_actual_x
	lw	$a1,pieza_actual_y
	add 	$a1,$a1,$t1
	jal	intentar_movimiento		#algoritmo basico de bajar_pieza_actual
	bnez $v0,C_51
	la	$a0,campo
	la	$a1,pieza_actual
	lw	$a2,pieza_actual_x
	lw	$a3,pieza_actual_y
	jal	imagen_dibuja_imagen
	
	lw	$t1,puntuacion			#cuando llega una pieza al final se suma un punto
	addi	$t1,$t1,1
	sw	$t1,puntuacion
	jal	borrar_linea_llena
C_53: 	la 	$a0,campo			#comprueba si se ha llegado a la cima del campo y si es asi se acaba la partida
	lw	$a1,0($a0)
	div	$a1,$a1,2
	li	$a2,0
	jal 	imagen_get_pixel
	beqz	$v0,C_50
	li	$t2,1
	sb  	$t2,acabar_partida
	j	C_51
C_50: jal	nueva_pieza_actual		#aparece una nueva pieza
	lw	$t1,puntuacion			#cada 50 puntos la velocidad aumenta un 10%
	li	$t2,50
	div	$t1,$t2
	mflo	$t1
	lw	$t4,tiempo_pausa_cont
	beq	$t1,$t4,C_51
	lw	$t3,tiempo_pausa
	mul	$t3,$t3,9
	div	$t1,$t3,10
	sw	$t1,tiempo_pausa
C_51:	lw	$ra, 0($sp)
	addiu $sp, $sp, 4
	jr	$ra

borrar_linea_llena:
	addiu	$sp, $sp, -24
	sw	$ra,20($sp)
	sw	$s4, 16($sp)	
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)	
	sw	$s0, 0($sp)
	li	$s1,0			#y=0 para comprobar
	la	$s0,campo
	lw	$s4,0($s0)		#campo->ancho
C_52a:	lw	$t0,4($s0)		#campo->alto
	beq	$s1,$t0,C_52e
	move	$a0,$s1
	jal	comprobar_linea_llena	#si la hay lineas llenas las elimina y baja todo el campo una linea
	beqz	$v0,C_52d
	lw	$t1,puntuacion		#si la hay lineas llenas suma 10 puntos por cada una
	addi	$t1,$t1,10
	sw	$t1,puntuacion
	move	$s2,$s1			#y=linea llena, para borrar
C_52b:	beqz	$s2,C_52d		#salta si hemos llegado a la linea que hay que borrar
	li	$s3,0			#x=0 para borrar
C_52c:	move	$a0, $s0
	move	$a1, $s3
	subi	$a2, $s2,1
	jal	imagen_get_pixel	# imagen_get_pixel(src,x,y)
	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s2
	move	$a3, $v0
	jal	imagen_set_pixel	# imagen_set_pixel(dst,x,y,color)	
 	addiu	$s3, $s3, 1		# ++x
	bltu	$s3, $s4, C_52c		# sigue si x<src->ancho
	subiu	$s2, $s2, 1		# --y
	j	C_52b 	
C_52d:	addi 	$s1,$s1,1		#sigue buscando lineas llenas
	j	C_52a	
C_52e:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s4, 16($sp)	
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra
comprobar_linea_llena:	#($a0)=(l韓ea a comprobar)
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3,12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$s0,campo
	lw	$s1,0($s0)	#campo->ancho
	move	$s2,$a0
	li	$s3,0		#x=0
	
C_80: 	beq $s3,$s1,C_81
	move $a0,$s0
	move $a1,$s3
	move $a2,$s2
	jal imagen_get_pixel
	addi	$s3,$s3,1
	bnez	$v0,C_80
	
	
C_81: 	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3,12($sp)
	lw	$ra, 16($sp)
	addiu $sp, $sp, 20
	jr	$ra
	

intentar_rotar_pieza_actual:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	la	$a0,imagen_auxiliar
	la	$t1,pieza_actual
	lw	$a1,4($t1)
	lw	$a2,0($t1)
	li	$a3,0
	jal 	imagen_init
	la	$a0,imagen_auxiliar
	la	$a1,pieza_actual
	li	$a2,0
	li	$a3,0
	jal 	imagen_dibuja_imagen_rotada
	la	$a0,imagen_auxiliar
	lw	$a1,pieza_actual_x
	lw	$a2,pieza_actual_y
	jal 	probar_pieza
	beqz $v0,C_61
	la	$a0,pieza_actual
	la	$a1,imagen_auxiliar
	jal	imagen_copy
C_61:lw	$ra, 0($sp)
	addiu $sp, $sp, 4
	jr	$ra

integer_to_string:           	# ($a0, $a1) = (n, buffer2)
	move	$t7,$a1
	la   	 	$t0, buffer		# char *p = buffer
	# for (int i = n; i > 0; i = i /10) {
	move	$t1, $a0		# int i = n
	li		$t4,10
B0_13:   blez	$t1, B0_17		# si i <= 0 salta el bucle
	div		$t1, $t4		# i / 10
	mflo		$t1			# i = i / 10
	mfhi		$t2			# d = i % 10
	addiu	$t2, $t2, '0'		# d + '0'
	sb		$t2, 0($t0)		# *p = $t2 
	addiu	$t6,$t6,1
	addiu	$t0, $t0, 1		# ++p
	j		B0_13			# sigue el bucle
B0_17:	sb	$zero, 0($t0)	# *p = '\0'
	 move	$t1, $zero		# int i = 0
B0_14:   beq 	$t1,$t6,B0_18	# si i >= num salta el bucle
	    subiu   	$t0,$t0,1
	   lb   	$t2, 0($t0)
	   sb		$t2, 0($t7)		# *p = $t2
	   addiu	$t7, $t7, 1		# ++p
	   addiu	$t1, $t1, 1		# i++
	   j	B0_14			# sigue el bucle
B0_18:	sb	$zero, 0($t7)		# *p = '\0
B0_110:	jr	$ra	

imagen_dibuja_cadena:  #{$a0,$a1,$a2,$a3}={img,x,y,buffer2}
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	move	$s0, $a0		#dst
	move	$s3, $a3		#buffer2
	move 	$s1,$a1		#dst_x
	move 	$s2,$a2		#dst_y
C_71	:
	lbu		$a3,0($s3)	
	beqz		$a3, C_74		# salta si es el final de la cadena	
	move	$a2,$s2
	move	$a1,$s1
	move	$a0,$s0
	jal	imagen_set_pixel	# imagen_set_pixel(dst,x,y,color)	
	addiu	$s3, $s3, 1		# ++i
	addiu	$s1, $s1, 1		# ++x
	j	C_71

C_74:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra
tecla_pausa:
	lw	$t1,tiempo_pausa
	li	$t2,1000000000
	blt	$t1,$t2,C_90
	lw	$t3,tiempo_pausa_guardar
	sw	$t3,tiempo_pausa
	j	C_91
C_90:	sw	$t1,tiempo_pausa_guardar
	sw	$t2,tiempo_pausa
C_91:	jr	$ra
tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0,1
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
tecla_secreta:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0,-2
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 56			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B21_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B21_3		# if (opciones[i].tecla != c) siguiente iteraci贸n
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B21_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B21_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	beqz	$v0,B22_3
	li	$a1, 19		#campo ancho
	li	$a2, 20		#campo alto
	j	B22_31
B22_3:
	li	$t3,1	
	beq	$a0,$t3,B22_31
	li	$t3,3	
	beq	$a0, $t3, B22_33		# if (opc == '3') saltar
	li	$t1,500
	j	B22_323
B22_33: 	li	$t1,250
B22_323: sw $t1,tiempo_pausa
B22_31:
	la	$a0, campo
	li	$a3, 0
	addi	$s0,$a1,7
	addi $s1,$a2,2
	jal	imagen_init		# imagen_init(campo, 19, 20, PIXEL_VACIO)
	la	$a0, pantalla
	move $a1, $s0		#pantalla ancho
	move $a2, $s1		#pantalla alto
	li	$a3, 32
	jal	imagen_init	# imagen_init(pantalla, 26, 22, ' ')
	jal 	nueva_pieza_siguiente
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B22_2
        # while (!acabar_partida) { 
B22_2:	lbu	$t1, acabar_partida
	bnez	$t1, B22_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	lw	$t7,tiempo_pausa
	addi	$t7,$t7,1
	bltu	$t1, $t7, B22_2	# if (transcurrido < pausa + 1) siguiente iteraci贸n
B22_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B22_2			# siguiente iteraci贸n
       	# } 
B22_5:	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B23_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n 3 - Configuracion\n\nElige una opci贸n:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0,'3',B23_3
	beq	$v0, '2', B23_1		# if (opc == '2') salir
	bne	$v0, '1', B23_5		# if (opc != '1') mostrar error
B23_4:	jal	jugar_partida		# jugar_partida()
	la	$a0,campo
	la	$a1, mensaje_fin
	lw	$t1,4($a0)
	lw	$t2,0($a0)
	div	$a3,$t1,2
	div	$a2,$t2,2
	subi	$a2,$a2,8
	subi	$a3,$a3,3
	jal	imagen_dibuja_imagen
	jal	actualizar_pantalla	# actualizar_pantalla()
	jal	read_character
		j	B23_2
B23_1:	la	$a0, str001
	jal	print_string		# print_string("\nAdios!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B23_2
B23_3: 	
	jal	clear_screen		# clear_screen()
	la	$a0, str003
	jal	print_string		# print_string
	jal	read_integer		# char opc = read_integer()
	move $a1,$v0
	la	$a0, str004
	jal	print_string		# print_string
	jal	read_integer		# char opc = read_integer()
	move $a2,$v0
	blt	$a1,10,B23_5
	mul	$t2,$a1,$a2
	bgt	$t2,1024,B23_5
	la	$a0, str005
	jal	print_string		# print_string
	jal	read_integer		# char opc = read_integer()
	move $a0,$v0
	blt	$a0,1,B23_5
	bgt	$a0,3,B23_5
	li 	$v0,0
	j	B23_4
	
B23_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpcion incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B23_2
	sw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librer铆a del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra
read_integer:
	li	$v0, 5
	syscall	
	jr	$ra
clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
