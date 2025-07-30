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
# - yes
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

GRID_WIDTH:
    .word 0             # Calculated at run time
    
FLOOR_HEIGHT:
    .word 4
    
GRID_HEIGHT:
    .word 0             # Calculated at run time

BLOCK_SIZE:
    .word 3
    
DISPLAY_INCREMENT:
    .word 256           # Calculated at run time(should be 4*display_width)

# Colours
wallColour:
    .word 0x30434d

primaryGridColour:
    .word 0x504f52

secondaryGridColour:
    .word 0x323233
    

## Blocks (Stored in a 4 x 4 grid)

# S-piece
s_pieces:
    # Colours
    .word 0xff7e70      # Primary Colour (orange-red)
    .word 0xffc107      # Secondary Colour (yellow)
    # Rotation 0
    .word 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0
    # Rotation 3
    .word 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0

# Z-piece
z_pieces:
    # Colours
    .word 0xff0000      # Primary Colour (red)
    .word 0xff6b6b      # Secondary Colour (light red)
    # Rotation 0
    .word 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
    # Rotation 3
    .word 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

# I-piece (line)
i_pieces:
    # Colours
    .word 0x00ffff      # Primary Colour (cyan)
    .word 0x4dd0e1      # Secondary Colour (light cyan)
    # Rotation 0 (horizontal)
    .word 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1 (vertical)
    .word 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
    # Rotation 2 (horizontal)
    .word 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0
    # Rotation 3 (vertical)
    .word 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0

# O-piece (square)
o_pieces:
    # Colours
    .word 0xffff00      # Primary Colour (yellow)
    .word 0xfff176      # Secondary Colour (light yellow)
    # Rotation 0
    .word 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 3
    .word 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

# T-piece
t_pieces:
    # Colours
    .word 0x800080      # Primary Colour (purple)
    .word 0xba68c8      # Secondary Colour (light purple)
    # Rotation 0
    .word 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
    # Rotation 3
    .word 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0

# L-piece
l_pieces:
    # Colours
    .word 0xffa500      # Primary Colour (orange)
    .word 0xffcc80      # Secondary Colour (light orange)
    # Rotation 0
    .word 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
    # Rotation 3
    .word 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0

# J-piece
j_pieces:
    # Colours
    .word 0x0000ff      # Primary Colour (blue)
    .word 0x64b5f6      # Secondary Colour (light blue)
    # Rotation 0
    .word 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    # Rotation 1
    .word 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
    # Rotation 2
    .word 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
    # Rotation 3
    .word 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0
    

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    
    jal calculate_grid
    jal draw_frame
    
    # Draw one block
    li $a0, 3
    li $a1, 17
    li $a2, 0
    la $a3, t_pieces
    
    jal draw_tetromino
    
    # Draw one block
    li $a0, 0
    li $a1, 17
    li $a2, 12
    la $a3, l_pieces
    
    jal draw_tetromino
    
    # Draw one block
    li $a0, 0
    li $a1, 26
    li $a2, 12
    la $a3, j_pieces
    
    jal draw_tetromino
    
    # Draw one block
    li $a0, 0
    li $a1, 23
    li $a2, 0
    la $a3, z_pieces
    
    jal draw_tetromino
    
    
    j end
    
calculate_grid:
    # Load grid width
    lw $t0, DISPLAY_WIDTH
    lw $t1, WALL_WIDTH
    sub $t0, $t0, $t1
    sub $t0, $t0, $t1           # width = DISPLAY_SIZE - 2*WALL_WIDTH
    sw $t0, GRID_WIDTH
    
    # Load grid height
    lw $t0, DISPLAY_HEIGHT
    lw $t1, FLOOR_HEIGHT
    sub $t0, $t0, $t1            # height = DISPLAY_HEIGHT - FLOOR_HEIGHT
    sw $t0, GRID_HEIGHT
    
    # Calculate Display Increment
    lw $t0, DISPLAY_WIDTH
    li $t1, 4
    mult $t0, $t1
    mflo $t0                    # Compute DISPLAY_WIDTH*4
    sw $t0, DISPLAY_INCREMENT
    
    jr $ra

draw_frame:
    subi $sp, $sp, 4
    sw $ra, 0($sp)              # Store main location in memory
    
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
    lw $a1, WALL_WIDTH           # x_offset = WALL_WIDTH
    lw $a2, GRID_HEIGHT          # y_offset = GRID_HEIGHT
    lw $a3, GRID_WIDTH           # width = GRID_WIDTH
    lw $t1, FLOOR_HEIGHT
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
    lw $a3, GRID_WIDTH
    subi $sp, $sp, 12
    lw $t0, primaryGridColour   # Push grid p colour onto stack
    lw $t1, secondaryGridColour   # Push grid p colour onto stack
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    lw $t0, GRID_HEIGHT
    sw $t0, 0($sp)               # Push height onto stack
    jal draw_rectangle
    addi $sp, $sp, 12             # Clean up stack
    
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

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
    
    # Check if drawn BLOCK_SIZE pixels (swap every BLOCK_SIZE pixel)
    lw $t7, BLOCK_SIZE
    div $t6, $t7
    mfhi $t8                    # remainder of t6 / BLOCK_SIZE
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

# Parameters: $a0 = base_addr, $a1 = x_offset, $a2 = y_offset
# Stack: Primary Colour, Secondary Colour
draw_block:
    subi $sp, $sp, 32 
    sw $s0, 0($sp)              # Primary color
    sw $s1, 4($sp)              # Secondary color
    sw $s2, 8($sp)              # Row increment (DISPLAY_WIDTH * 4)
    sw $s3, 12($sp)             # Current row address
    sw $s4, 16($sp)             # BLOCK_SIZE
    sw $s5, 20($sp)             # BLOCK_SIZE - 1 (border check)
    sw $s6, 24($sp)             # Row counter
    sw $ra, 28($sp)
    
    lw $s0, 32($sp)             # Primary Colour
    lw $s1, 36($sp)             # Secondary Colour
    
    # Calculate starting address
    move $s3, $a0               
    sll $t0, $a1, 2             # x_offset *= 4
    add $s3, $s3, $t0           # base_addr + x_offset
    
    lw $s2, DISPLAY_INCREMENT
    mult $a2, $s2               # y_offset * row_increment
    mflo $t0
    add $s3, $s3, $t0           # Final starting address in $s3
    
    lw $s4, BLOCK_SIZE          # BLOCK_SIZE in $s4
    subi $s5, $s4, 1            # BLOCK_SIZE - 1 in $s5 (for border check)
    move $s6, $s4               # Row counter in $s6

draw_block_row:
    beqz $s6, draw_block_row_finished
    
    move $t0, $s4               # BLOCK_SIZE = column counter
    move $t1, $s3               # Current pixel address
    
    sub $t2, $s4, $s6           # i = BLOCK_SIZE - row_counter
    
    jal draw_block_col
   
    subi $s6, $s6, 1            # Decrement row counter
    add $s3, $s3, $s2           # Move to next row address
    j draw_block_row

draw_block_col:
    beqz $t0, draw_block_col_finished
    
    sub $t3, $s4, $t0           # j = BLOCK_SIZE - column_counter
    
    # if i==0 || j==0 || i==last || j==last
    beqz $t2, use_primary       # i == 0 (top border)
    beqz $t3, use_primary       # j == 0 (left border)  
    beq $t2, $s5, use_primary   # i == BLOCK_SIZE-1 (bottom border)
    beq $t3, $s5, use_primary   # j == BLOCK_SIZE-1 (right border)
    
    # Interior pixel - use secondary color
    move $t4, $s1
    j store_pixel

use_primary:
    move $t4, $s0

store_pixel:
    sw $t4, 0($t1)              # Store the color
    addi $t1, $t1, 4            # Move to next pixel
    subi $t0, $t0, 1            # Decrement column counter
    j draw_block_col

draw_block_col_finished:
    jr $ra

draw_block_row_finished:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32
    jr $ra


# Parameters: $a0 = tetromino_offset(0, 1, 2, 3), $a1 = x_offset, $a2 = y_offset, $a3 = tetromino_piece
draw_tetromino:
    subi $sp, $sp, 20
    sw $s0, 0($sp)              # Row counter
    sw $s1, 4($sp)              # x_offset
    sw $s2, 8($sp)              # Col counter
    sw $s3, 12($sp)             # BLOCK_SIZE
    sw $ra, 16($sp)
    
    li $s0, 4                   # Tetromino's are 4 x 4 at max
    move $s1, $a1
    
    # Store colours on the stack
    lw $t0, 0($a3)               # Primary Colour
    lw $t1, 4($a3)              # Secondary Colour
    addi $a3, $a3, 8            # Move past the colours
    
    # Calculate the offset
    sll $a0, $a0, 6             # offset*64
    add $a3, $a3, $a0           # Add the offset
    
    subi $sp, $sp, 12
    sw $t0, 0($sp)              # Primary Colour
    sw $t1, 4($sp)              # Secondary Colour
    # the rows's ra will be stored in the 8th index
    
    lw $s3, BLOCK_SIZE
    lw $a0, ADDR_DSPL           # base_addr

draw_tetromino_row:
    beqz $s0, draw_tetromino_row_finished
    
    li $s2, 4                   # Tetromino's are 4 x 4 at max
    move $a1, $s1
    jal store_row_link          # Store link, then branch to draw_tetromino_col
    
    
    add $a2, $a2, $s3            # increase y_offset by 1 BLOCK_SIZE
    subi $s0, $s0, 1            
    j draw_tetromino_row
    
store_row_link:
    sw $ra, 8($sp)              # store draw_tetromino_row's link
    j draw_tetromino_col

draw_tetromino_col:
    beqz $s2, draw_tetromino_col_finished
    
    lw $t1, 0($a3)              # get value of current tetromino piece
    beqz $t1, draw_tetromino_col_increment    # If position of tetromino is 0, skip
    jal draw_block
    
    
draw_tetromino_col_increment:
    add $a1, $a1, $s3            # increase x_offset by 1 BLOCK_SIZE
    subi $s2, $s2, 1            
    addi $a3, $a3, 4            # move to next tetromino byte position
    j draw_tetromino_col

draw_tetromino_col_finished:
    lw $ra, 8($sp)
    jr $ra

draw_tetromino_row_finished:
    addi $sp, $sp, 12            # For getting rid of the colours and rows RA
    lw $s0, 0($sp)              
    lw $s1, 4($sp) 
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 16
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