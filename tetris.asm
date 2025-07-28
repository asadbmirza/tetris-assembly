#####################################################################
# CSCB58 Summer 2025 Assembly Final Project - UTSC
# Asad Mirza, 1010009438, mirzaas4, asadb.mirza@mail.utoronto.ca
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed) 
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 516 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# Hard Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

UNIT_SIZE:
    .word 8

DISPLAY_WIDTH:
    .word 64

DISPLAY_HEIGHT:
    .word 64

WALL_WIDTH:
    .word 17
    
FLOOR_HEIGHT:
    .word 4

BLOCK_SIZE:
    .word 3

wallColour:
    .word 0x30434d

primaryGridColour:
    .word 0x504f52

secondaryGridColour:
    .word 0x323233

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    
    # Draw Left Wall
    lw $a0, ADDR_DSPL
    li $a1, 0                    # x_offset = 0
    li $a2, 0                    # y_offset = 0  
    lw $a3, WALL_WIDTH           # width = WALL_WIDTH
    lw $t0, DISPLAY_HEIGHT       # height = DISPLAY_HEIGHT
    subi $sp, $sp, 12
    lw $t1, wallColour           # Push wall colour onto stack(this will be both primary and secondarry colours)
    sw $t1, 8($sp)
    sw $t1, 4($sp)
    sw $t0, 0($sp)               # Push height onto stack
    jal draw_rectangle
    addi $sp, $sp, 12             # Clean up stack
    
    # Draw Right Wall
    lw $a0, ADDR_DSPL
    lw $t0, DISPLAY_WIDTH
    lw $t1, WALL_WIDTH
    sub $a1, $t0, $t1            # x_offset = DISPLAY_WIDTH - WALL_WIDTH
    li $a2, 0                    # y_offset = 0
    move $a3, $t1                # width = WALL_WIDTH  
    lw $t0, DISPLAY_HEIGHT       # height = DISPLAY_HEIGHT
    subi $sp, $sp, 12
    lw $t1, wallColour           # Push wall colour onto stack(this will be both primary and secondarry colours)
    sw $t1, 8($sp)
    sw $t1, 4($sp)
    sw $t0, 0($sp)               # Push height onto stack
    jal draw_rectangle
    addi $sp, $sp, 12             # Clean up stack
    
    # Draw Bottom Wall
    lw $a0, ADDR_DSPL
    li $a1, 0                    # x_offset = 0
    lw $t0, DISPLAY_HEIGHT
    lw $t1, FLOOR_HEIGHT
    sub $a2, $t0, $t1            # y_offset = DISPLAY_HEIGHT - FLOOR_HEIGHT
    lw $a3, DISPLAY_WIDTH        # width = DISPLAY_WIDTH
    subi $sp, $sp, 12
    lw $t0, wallColour           # Push wall colour onto stack(this will be both primary and secondarry colours)
    sw $t0, 8($sp)
    sw $t0, 4($sp)
    sw $t1, 0($sp)               # Push height onto stack
    jal draw_rectangle
    addi $sp, $sp, 12             # Clean up stack
    
    # Draw Grid Pattern
    lw $a0, ADDR_DSPL
    lw $a1, WALL_WIDTH          # x_offset = WALL_WIDTH
    li $a2, 0                   # y_offset = 0
    lw $a3, DISPLAY_WIDTH
    sub $a3, $a3, $a1
    sub $a3, $a3, $a1           # width = DISPLAY_SIZE - 2*WALL_WIDTH
    subi $sp, $sp, 12
    lw $t0, primaryGridColour   # Push grid p colour onto stack
    lw $t1, secondaryGridColour   # Push grid p colour onto stack
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    lw $t0, DISPLAY_HEIGHT
    lw $t1, FLOOR_HEIGHT
    sub $t0, $t0, $t1            # height = DISPLAY_HEIGHT - FLOOR_HEIGHT
    sw $t0, 0($sp)               # Push height onto stack
    jal draw_rectangle
    addi $sp, $sp, 12             # Clean up stack
    
    j end

# Parameters: $a0 = base_addr, $a1 = x_offset, $a2 = y_offset, $a3 = width
# Stack parameter: height, primary colour, secondary colour
draw_rectangle:
    # Save registers and get height from stack
    subi $sp, $sp, 28
    sw $ra, 24($sp)
    sw $s0, 20($sp) 
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)
    
    lw $s3, 28($sp)             # Load height from stack
    lw $s4, 32($sp)             # Load secondary colour from stack
    lw $s5, 36($sp)             # Load primary colour from stack
    # Load constants
    lw $t1, DISPLAY_WIDTH
    sll $t1, $t1, 2             # bytes_per_row = DISPLAY_WIDTH * 4
    
    # Calculate starting address
    sll $t2, $a2, 2             # y_offset * 4
    mult $a2, $t1               # y_offset * bytes_per_row
    mflo $t2                    
    sll $t3, $a1, 2             # x_offset * 4
    add $t2, $t2, $t3           # total offset
    add $s0, $a0, $t2           # starting address
    
    # Setup loop variables
    move $s1, $s3               # height counter
    move $s2, $a3               # width to draw
    
draw_rect_row:
    beqz $s1, draw_rect_done    # if height == 0, done
    
    # Draw one row
    move $t4, $s0               # current position
    move $t5, $s2               # width counter
    li $t6, 0                   # reset column counter for grid pattern
    
draw_rect_col:
    beqz $t5, draw_rect_next_row # if width == 0, next row
    sw $s5, 0($t4)              # draw pixel
    addiu $t4, $t4, 4           # next pixel
    subi $t5, $t5, 1            # width--
    addi $t6, $t6, 1            # increment column counter
    
    # Check if we've drawn BLOCK_SIZE pixels (swap every BLOCK_SIZE pixel)
    lw $t7, BLOCK_SIZE
    div $t6, $t7
    mfhi $t8                    # remainder of t6 / 3
    bnez $t8, draw_rect_col     # if remainder != 0, don't swap
    
    # Swap primary and secondary colours every 3rd pixel
    move $t0, $s5
    move $s5, $s4
    move $s4, $t0
    
    j draw_rect_col
    
draw_rect_next_row:
    add $s0, $s0, $t1           # next row
    subi $s1, $s1, 1            # height--
    
    # Get current row number for swapping logic
    sub $t9, $s3, $s1           # current row = original_height - remaining_height
    
    # Check if we've drawn BLOCK_SIZE rows (swap every BLOCK_SIZE row)
    lw $t7, BLOCK_SIZE
    div $t9, $t7
    mfhi $t8                    # remainder of current_row / 3
    bnez $t8, draw_rect_row     # if remainder != 0, don't swap
    
    #Swap primary and secondary colour's
    move $t0, $s5
    move $s5, $s4
    move $s4, $t0
    j draw_rect_row
    
draw_rect_done:
    # Restore registers
    lw $s5, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra
        
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    j end
    b game_loop

end: