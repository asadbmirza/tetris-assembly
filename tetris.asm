#####################################################################
# CSCB58 Summer 2025 Assembly Final Project - UTSC
# Asad Mirza, 1010009438, mirzaas4, asadb.mirza@mail.utoronto.ca
# Bitmap Display Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 512 
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. All tetrominoes are different colours
# 2. Gravity
# 3. Faster gravity every 10 lines cleared
# 4. Piece outlines before they drop
# Hard Features:
# 1. All tetrominoes implemented
# 2. Animation when clearing

# How to play:
# A/D Move left and right
# W Rotates
# S Move down
# Space drops piece to bottom
# Link to video demonstration for final submission:
# - https://drive.google.com/file/d/1SL4aEQRvLuvtsU_kvv0Oy1O6IaN4D5KE/view?usp=sharing
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

GRID_SPACE:
    .space 800           # 10 * 20 gameboard, each space is 4 bytes

GRAVITY_DELAY:
    .word 60, 43, 30, 10, 5, 4, 3, 2   # Base gravity delay is every 60 refreshes, increases with every 10 line clears. 

GRAVITY_INDEX:
    .word 0
    
LAST_GRAVITY_LEVEL:
    .word 0                             # Track the last gravity level(quotient) applied

LINES_CLEARED:
    .word 0
    
MAX_LINES_CLEARED:
    .word 80                            # 10 rows * 8 levels

# Colours
wallColour:
    .word 0x30434d

primaryGridColour:
    .word 0x504f52

secondaryGridColour:
    .word 0x323233
    
current_tetromino_state:
    .word 3   # piece
    .word 0   # rotation
    .word 26   # x_offset  
    .word 0   # y_offset

potential_tetromino_state:
    .word 3   # piece
    .word 0   # rotation
    .word 26   # x_offset  
    .word 0   # y_offset

outline_tetromino_state:
    .word 3   # piece
    .word 0   # rotation
    .word 26   # x_offset  
    .word 0   # y_offset

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

animation_colors:
    .word 0xffffff      # Primary: Bright orange
    .word 0xffffff      # Secondary: Red

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
    
    ## Load current tetromino
    subi $sp, $sp, 20
    sw $s0, 0($sp)              # tetromino's state
    sw $s1, 4($sp)              # tetromino's next potential state
    sw $s2, 8($sp)              # keyboard_input
    sw $s3, 12($sp)             # current gravity counter
    sw $ra, 16($sp)
    
    la $s0, current_tetromino_state
    la $s1, potential_tetromino_state
    lw $s3, GRAVITY_DELAY
    
    jal generate_new_piece         # generate random piece                  
    
    j setup_game_loop
    
setup_game_loop:
    jal draw_grid
    
    move $a0, $s0                 
	jal draw_outline               # y_outline is calculated in the function
    
    lw $a0, 0($s0)                 # current piece
	lw $a1, 4($s0)                 # rotation
	lw $a2, 8($s0)                 # x_offset
	lw $a3, 12($s0)                # y_offset 
	subi $sp, $sp, 4
	li $t0, 0
	sw $t0, 0($sp)                 # is_outline is false
	jal draw_tetromino
	
	

    j game_loop

## Helper Functions ##

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

# Helper function to get piece data
# Parameters: $a0 = piece_type (1=S, 2=Z, 3=I, 4=O, 5=T, 6=L, 7=J), $a1 = rotation (0-3)
# Returns: $v0 = piece data address, $v1 = primary color
# Note: Secondary color must be loaded separately using get_secondary_color
get_piece_data:
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    
    # Jump table for piece types
    beq $a0, 1, load_s_piece
    beq $a0, 2, load_z_piece
    beq $a0, 3, load_i_piece
    beq $a0, 4, load_o_piece
    beq $a0, 5, load_t_piece
    beq $a0, 6, load_l_piece
    beq $a0, 7, load_j_piece
    beq $a0, 8, load_animation_piece
    j get_piece_done
    
load_s_piece:
    la $t0, s_pieces
    j load_piece_common
load_z_piece:
    la $t0, z_pieces
    j load_piece_common
load_i_piece:
    la $t0, i_pieces
    j load_piece_common
load_o_piece:
    la $t0, o_pieces
    j load_piece_common
load_t_piece:
    la $t0, t_pieces
    j load_piece_common
load_l_piece:
    la $t0, l_pieces
    j load_piece_common
load_j_piece:
    la $t0, j_pieces
    j load_piece_common
load_animation_piece:
    la $t0, animation_colors
    lw $v1, 0($t0)
    # For animation, we don't need rotation data, just return a dummy address
    la $v0, animation_colors
    addi $v0, $v0, 8    # Skip the color data
    j get_piece_done
    
load_piece_common:
    # Load colors
    lw $v1, 0($t0)      # Primary color
    # Note: Secondary color at 4($t0)
    
    # Calculate rotation offset: 8 + (rotation * 64)
    li $t1, 64          # Each rotation = 16 words * 4 bytes
    mult $a1, $t1
    mflo $t1
    addi $t0, $t0, 8    # Skip color words
    add $v0, $t0, $t1   # Add rotation offset
    
get_piece_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Parameters: $a0 = piece_type (1=S, 2=Z, 3=I, 4=O, 5=T, 6=L, 7=J)
# Returns: $v0 = secondary color
get_secondary_color:
    beq $a0, 1, get_s_secondary
    beq $a0, 2, get_z_secondary
    beq $a0, 3, get_i_secondary
    beq $a0, 4, get_o_secondary
    beq $a0, 5, get_t_secondary
    beq $a0, 6, get_l_secondary
    beq $a0, 7, get_j_secondary
    beq $a0, 8, get_animation_secondary
    jr $ra
    
get_s_secondary:
    la $t0, s_pieces
    lw $v0, 4($t0)
    jr $ra
get_z_secondary:
    la $t0, z_pieces
    lw $v0, 4($t0)
    jr $ra
get_i_secondary:
    la $t0, i_pieces
    lw $v0, 4($t0)
    jr $ra
get_o_secondary:
    la $t0, o_pieces
    lw $v0, 4($t0)
    jr $ra
get_t_secondary:
    la $t0, t_pieces
    lw $v0, 4($t0)
    jr $ra
get_l_secondary:
    la $t0, l_pieces
    lw $v0, 4($t0)
    jr $ra
get_j_secondary:
    la $t0, j_pieces
    lw $v0, 4($t0)
    jr $ra
get_animation_secondary:
    la $t0, animation_colors
    lw $v0, 4($t0)
    jr $ra

## Drawing Functions ##

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
    jal draw_grid
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_grid:
    subi $sp, $sp, 4
    sw $ra, 0($sp)              # Store return address
    
    # Draw Grid Pattern
    lw $a0, ADDR_DSPL
    lw $a1, WALL_WIDTH          # x_offset = WALL_WIDTH
    li $a2, 0                   # y_offset = 0
    lw $a3, GRID_WIDTH
    subi $sp, $sp, 12
    lw $t0, primaryGridColour   # Push grid primary colour onto stack
    lw $t1, secondaryGridColour # Push grid secondary colour onto stack
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    lw $t0, GRID_HEIGHT
    sw $t0, 0($sp)              # Push height onto stack
    jal draw_rectangle
    jal fill_grid
    addi $sp, $sp, 12           # Clean up stack
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

fill_grid:
    subi $sp, $sp, 28           
    sw $s0, 0($sp)              # current grid position
    sw $s1, 4($sp)              # i (row)
    sw $s2, 8($sp)              # j (column)
    sw $s3, 12($sp)             # current grid value/primary colour later
    sw $s4, 16($sp)             # secondary colour
    sw $s5, 20($sp)             # WALL_WIDTH value
    sw $ra, 24($sp)
    
    li $s1, 0                   # i (row counter)
    lw $s5, WALL_WIDTH          # used for calculating the x_offset
    la $s0, GRID_SPACE
    
fill_row:
    beq $s1, 20, fill_row_finished    # 20 rows in the grid
    
    li $s2, 0                   # j (column counter)
    j fill_col
    
fill_row_increment:
    addi $s1, $s1, 1            # increment row by 1
    j fill_row
    
fill_col:
    beq $s2, 10, fill_col_finished    # 10 columns in the grid
    
    lw $s3, 0($s0)              # current grid value
    beqz $s3, fill_col_increment
    
    ## Otherwise will contain the tetris piece value (1 - 7)
    
    move $a0, $s3
    li $a1, 0                   # rotation doesn't matter we just want the colour
    jal get_piece_data
    move $s3, $v1               # primary colour (reuse $s3)
    jal get_secondary_color
    move $s4, $v0               # secondary colour
    subi $sp, $sp, 8
    sw $s3, 0($sp)
    sw $s4, 4($sp)              # load colours on the stack
    
    lw $a0, ADDR_DSPL
    
    # Convert grid coordinates to screen coordinates
    li $t0, 3                   # BLOCK_SIZE
    mult $s2, $t0               # j * BLOCK_SIZE
    mflo $t1
    add $a1, $t1, $s5           # x_offset = WALL_WIDTH + (j * BLOCK_SIZE)
    
    mult $s1, $t0               # i * BLOCK_SIZE  
    mflo $a2                    # y_offset = i * BLOCK_SIZE
    
    jal draw_block              # draw the block in the correct position
    addi $sp, $sp, 8
    
    
fill_col_increment:
    addi $s2, $s2, 1            # increment column by 1
    addi $s0, $s0, 4            # next grid position (4 bytes per grid cell)
    j fill_col
    
fill_col_finished:
    j fill_row_increment
    
fill_row_finished:
    lw $s0, 0($sp)          
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    
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


# Parameters: $a0 = piece (0-6), $a1 = rotation (0-3), $a2 = x_offset, $a3 = y_offset
# Stack (before call): 0($sp) = is_outline

draw_tetromino:
    subi $sp, $sp, 24
    sw $s0, 0($sp)              # Row counter
    sw $s1, 4($sp)              # x_offset
    sw $s2, 8($sp)              # Col counter
    sw $s3, 12($sp)             # BLOCK_SIZE
    sw $s4, 16($sp)             # Tetromino base address
    sw $ra, 20($sp)

    li $s0, 4                   # Max 4 rows
    move $s1, $a2               # x_offset

    # Get piece base and primary color
    jal get_piece_data          # $v0 = piece addr, $v1 = primary color
    move $s4, $v0               # Save piece base addr

    # Get secondary color
    jal get_secondary_color     # $v0 = secondary color

    # Load is_outline
    lw $t0, 24($sp)             # $t0 = is_outline
    li $t1, 1
    bne $t0, $t1, skip_outline_override

    # If is_outline == 1, overwrite both colours with white
    li $v1, 0xffffff            # Primary = white
    li $v0, 0xffffff            # Secondary = white

skip_outline_override:
    # Save colors to stack
    subi $sp, $sp, 12
    sw $v1, 0($sp)              # Primary colour
    sw $v0, 4($sp)              # Secondary colour
    # slot 8($sp) reserved for row function return address if needed

    lw $s3, BLOCK_SIZE

    # Prep draw_block parameters
    lw $a0, ADDR_DSPL           # Display base
    move $a1, $a2               # x_offset
    move $a2, $a3               # y_offset

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
    
    lw $t1, 0($s4)              # get value of current tetromino piece
    beqz $t1, draw_tetromino_col_increment    # If position of tetromino is 0, skip
    jal draw_block
    
    
draw_tetromino_col_increment:
    add $a1, $a1, $s3            # increase x_offset by 1 BLOCK_SIZE
    subi $s2, $s2, 1            
    addi $s4, $s4, 4            # move to next tetromino byte position
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
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Parameters: $a0 = current_tetromino_state
draw_outline:
    subi $sp, $sp, 8
    sw $s0, 0($sp)              # Save outline tetromino state address
    sw $ra, 4($sp)              

    move $a1, $a0
    la $s0, outline_tetromino_state
    move $a0, $s0
    jal update_tetromino_state
    
    move $a0, $s0
    jal calculate_bottom_y_offset
    
    move $t0, $v0               # this is the bottomost y_offset
    sw $t0, 12($s0)             # store in outline tetromino
    
    lw $a0, 0($s0)                 # current piece
	lw $a1, 4($s0)                 # rotation
	lw $a2, 8($s0)                 # x_offset
	lw $a3, 12($s0)                # y_offset 
	subi $sp, $sp, 4
	li $t0, 1
	sw $t0, 0($sp)                 # is_outline is true
	jal draw_tetromino
	addi $sp, $sp, 4
	
    lw $s0, 0($sp)             
    lw $ra, 4($sp)  
    addi $sp, $sp, 8
    jr $ra

# Parameters: $a0 = state of tetromino
# Returns bottom y offset in $v0
calculate_bottom_y_offset:
    subi $sp, $sp, 20
    sw $s0, 0($sp)              # Save tetromino state address
    sw $s1, 4($sp)              # Save BLOCK_SIZE
    sw $s2, 8($sp)              # Save current y_offset being tested
    sw $s3, 12($sp)             # Save original y_offset
    sw $ra, 16($sp)             # Save return address
    
    move $s0, $a0               # Store tetromino state address
    lw $s1, BLOCK_SIZE          # Load BLOCK_SIZE for incrementing
    lw $s3, 12($s0)             # Save original y_offset
    move $s2, $s3               # Start with original y_offset
    
drop_loop:
    # Increment y_offset by BLOCK_SIZE
    add $s2, $s2, $s1           # y_offset += BLOCK_SIZE
    sw $s2, 12($s0)             # Store new y_offset in tetromino state
    
    # Check collision with new position
    move $a0, $s0               # tetromino state
    li $a1, 2                   # direction = down (2)
    jal check_collision
    
    # Check collision result
    beq $v0, 1, drop_loop       # If no collision (1), continue dropping
    # If we get here, we hit something (collision type 0 or 2)
    
collision_found:
    # The previous y_offset was the last valid position
    sub $s2, $s2, $s1           # Go back one BLOCK_SIZE (last valid position)
    move $v0, $s2               # Return the bottom y_offset
    
    # Restore original y_offset in the tetromino state
    sw $s3, 12($s0)             # Restore original y_offset
    
    # Restore registers and return
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra
    

## CONTROLS ##
# Returns 0 or 1 depending on if key is pressed
check_input:
    lw $t9, ADDR_KBRD               # $t9 = base address for keyboard
    lw $v0, 0($t9)                  # Load first word from keyboard
    jr $ra


# Parameters: $a0 = potential_tetromino_state, $a1 = current_tetromino_state
keyboard_input:
    subi $sp, $sp, 24
    sw $s0, 0($sp)                  # potential tetromino state address
    sw $s1, 4($sp)                  # BLOCK_SIZE
    sw $s2, 8($sp)                  # key pressed
    sw $s3, 12($sp)                 # keyboard address
    sw $s4, 16($sp)                 # current_tetromino state address
    sw $ra, 20($sp)
    
    move $s0, $a0                   # Store potential tetromino state address
    move $s4, $a1                   # store current state address
    lw $s1, BLOCK_SIZE
    
    lw $s3, ADDR_KBRD               # $s3 = base address for keyboard
    lw $s2, 4($s3)                  # Key Pressed
    beq $s2, 0x61, move_left        # Check if the key a was pressed
    beq $s2, 0x41, move_left        # Check if the key A was pressed
    beq $s2, 0x64, move_right       # Check if the key d was pressed
    beq $s2, 0x44, move_right       # Check if the key D was pressed
    beq $s2, 0x73, move_down        # Check if the key s was pressed
    beq $s2, 0x53, move_down        # Check if the key S was pressed
    beq $s2, 0x77, rotate_piece     # Check if the key w was pressed
    beq $s2, 0x57, rotate_piece     # Check if the key W was pressed
    beq $s2, 0x20, hard_drop_piece  # Check if the space bar was pressed
    beq $s2, 0x71, quit_game        # Check if the key q was pressed
    beq $s2, 0x51, quit_game        # Check if the key Q was pressed
    j end_input
    
move_left: 
    lw $t0, 8($s0)                  # Load x_offset
    sub $t0, $t0, $s1               # Subtract BLOCK_SIZE
    sw $t0, 8($s0)                  # Store back x_offset
    li $v0, 0                       # direction = left
    j end_input
    
move_right:
    lw $t0, 8($s0)                  # Load x_offset
    add $t0, $t0, $s1               # Add BLOCK_SIZE
    sw $t0, 8($s0)                  # Store back x_offset
    li $v0, 1                       # direction = right
    j end_input

move_down:
    lw $t0, 12($s0)                 # Load y_offset
    add $t0, $t0, $s1               # Add BLOCK_SIZE
    sw $t0, 12($s0)                 # Store back y_offset
    li $v0, 2                       # direction = down
    j end_input

rotate_piece:
    lw $t0, 4($s0)                  # Load rotation
    addi $t0, $t0, 1                # Increment rotation
    li $t1, 4
    div $t0, $t1
    mfhi $t0                        # Get remainder (0-3)
    sw $t0, 4($s0)                  # Store back rotation
    li $v0, 3                       # direction = rotate
    j end_input

hard_drop_piece:
    la $t0, outline_tetromino_state
    lw $t0, 12($t0)
 
    sw $t0, 12($s4)                 # Store new y_offset in current_tetromino_state
    sw $t0, 12($s0)
    jal move_down

quit_game:
    li $v0, 10                      # Quit
    syscall

end_input:
    # Restore saved registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 16
    jr $ra
    
## Collisions ##
# Parameters: $a0 = potential tetromino state/outline_tetromino_state, $a1 = direction_pressed (0 = left, 1 = right, 2 = down, 3 = rotate)
# Returns 0 in $v0 if there is a side collision, 1 if there is not, 2 if there is a downwards collision
check_collision:
    subi $sp, $sp, 28          
    sw   $s0, 0($sp)           # tetromino state
    sw   $s1, 4($sp)           # x_offset
    sw   $s2, 8($sp)           # y_offset
    sw   $s3, 12($sp)          # piece ptr (after rotation)
    sw   $s4, 16($sp)          # BLOCK_SIZE
    sw   $s5, 20($sp)          # direction parameter
    sw   $ra, 24($sp)          
    
    # Load potential state
    move $s0, $a0
    move $s5, $a1              # store direction
    lw $s1, 8($s0)              # x_offset        
    lw $s2, 12($s0)              # y_offset
    
    lw $a0, 0($s0)             # piece type
    lw $a1, 4($s0)              # rotation
    jal get_piece_data
    move $s3, $v0               # move piece pointer into s3
    lw $s4, BLOCK_SIZE
    
    jal check_wall_collision
    beqz $v0, check_collision_end
    
    jal check_floor_collision
    beq $v0, 2, check_collision_end
    
    move $a1, $s5              # pass direction to grid collision
    jal check_grid_collision
    
    j check_collision_end

check_collision_end:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra

# Parameters: $a1 = direction_pressed (0 = left, 1 = right, 2 = down, 3 = rotate)
# Uses global registers: $s0 = tetromino state, $s1 = x_offset, $s2 = y_offset, $s3 = piece ptr, $s4 = BLOCK_SIZE
check_grid_collision:
    subi $sp, $sp, 20          
    sw   $s5, 0($sp)           # grid base address
    sw   $s6, 4($sp)           # tetromino row counter
    sw   $s7, 8($sp)           # tetromino col counter
    sw   $t0, 12($sp)          # direction parameter
    sw   $ra, 16($sp)
    
    move $t0, $a1              # store direction parameter
    la $s5, GRID_SPACE         # base address of grid
    
    # Convert screen coordinates to grid coordinates
    lw $t1, WALL_WIDTH
    sub $t2, $s1, $t1          # remove wall offset from x_offset
    div $t2, $s4               # divide by BLOCK_SIZE to get grid column
    mflo $t2                   # grid_x in $t2
    
    div $t3, $s2, $s4          # divide y_offset by BLOCK_SIZE to get grid row  
    mflo $t3                   # grid_y in $t3
    
    # Check all 4x4 tetromino positions
    li $s6, 0                  # tetromino row counter
    move $t4, $s3              # current tetromino position

grid_collision_row_loop:
    beq $s6, 4, grid_collision_no_collision
    
    li $s7, 0                  # tetromino col counter
    
grid_collision_col_loop:
    beq $s7, 4, grid_collision_next_row
    
    # Check if current tetromino position has a block
    lw $t5, 0($t4)             # load tetromino block value
    beqz $t5, grid_collision_col_increment  # skip if no block
    
    # Calculate grid position for this tetromino block
    add $t6, $t2, $s7          # grid_col = grid_x + tetromino_col
    add $t7, $t3, $s6          # grid_row = grid_y + tetromino_row
    
    # Check bounds
    bltz $t6, grid_collision_col_increment    # skip if col < 0
    bge $t6, 10, grid_collision_col_increment # skip if col >= 10
    bltz $t7, grid_collision_col_increment    # skip if row < 0
    bge $t7, 20, grid_collision_col_increment # skip if row >= 20
    
    # Calculate grid array index: (row * 10 + col) * 4
    li $t8, 10
    mult $t7, $t8              # row * 10
    mflo $t8
    add $t8, $t8, $t6          # row * 10 + col
    sll $t8, $t8, 2            # multiply by 4 for byte offset
    
    # Check if grid position is occupied
    add $t9, $s5, $t8          # grid address
    lw $t8, 0($t9)             # load grid value
    beqz $t8, grid_collision_col_increment    # skip if empty
    
    # Collision detected
    beq $t0, 2, grid_collision_down    # if direction is down, return 2
    # For left, right, or rotate (0, 1, 3) - all return 0 (side collision)
    li $v0, 0                  
    j grid_collision_end

grid_collision_down:
    li $v0, 2                  # downward collision
    j grid_collision_end

grid_collision_col_increment:
    addi $s7, $s7, 1           # increment tetromino col
    addi $t4, $t4, 4           # move to next tetromino position
    j grid_collision_col_loop

grid_collision_next_row:
    addi $s6, $s6, 1           # increment tetromino row
    j grid_collision_row_loop

grid_collision_no_collision:
    li $v0, 1                  # no collision

grid_collision_end:
    lw $s5, 0($sp)
    lw $s6, 4($sp)
    lw $s7, 8($sp)
    lw $t0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

check_wall_collision:
    subi $sp, $sp, 4          
    sw   $ra, 0($sp)
    
    lw $t6, DISPLAY_WIDTH
    lw $t7, WALL_WIDTH
    # Get LEFTMOST block
    li   $a0, 0              # starting from column 0
    move $a1, $s3            # pointer to piece
    li   $a2, 1              # direction: left to right
    jal  get_horizontal_extreme_block
    move $t8, $v0            # store leftmost column in $t8
    mult $t8, $s4            # multiply leftmost column by BLOCK_SIZE
    mflo $t8

    # Get RIGHTMOST block
    li   $a0, 3              # starting from column 3
    move $a1, $s3            # pointer to piece matrix
    addi $a1, $a1, 12        # needs to be at column 3
    li   $a2, -1             # direction: right to left
    jal  get_horizontal_extreme_block
    move $t9, $v0            # store rightmost column in $t9
    mult $t9, $s4            # multiply rightmost column by BLOCK_SIZE
    mflo $t9
    
    lw   $ra, 0($sp)
    addi $sp, $sp, 4         # add ra back  
    
    li $t0, 0                # default return value(prepped for branch_and_return)
    
    # Check left collision
    add $t1, $s1, $t8       # add leftmost column to x offset
    blt $t1, $t7, branch_and_return         # if left wall is being clipped by updated x offset, return collision
    
    # Check right collision
    sub $t7, $t6, $t7        # subtract right wall width from display width
    add $t1, $s1, $t9        # add rightmost column to x offset 
    bge $t1, $t7, branch_and_return         # if right wall is being clipped by updated x offset, return collision
    
    li $t0, 1                # No collisions occured
    j branch_and_return

# Arguments: $a0 — starting column index, $a1 — pointer to start of column, $a2 — direction (+1 = left to right, -1 = right to left)
get_horizontal_extreme_block:
    move $t0, $a0      # column index
    move $t1, $a1      # column base ptr
    move $t4, $a2      # direction: +1 or -1

loop_check_column:
    lw $t2, 0($t1)
    lw $t3, 16($t1)
    add $t2, $t2, $t3
    lw $t3, 32($t1)
    add $t2, $t2, $t3
    lw $t3, 48($t1)
    add $t2, $t2, $t3

    bgtz $t2, branch_and_return
    add $t0, $t0, $t4            # column index += direction
    mul $t5, $t4, 4              # offset = direction × 4
    add $t1, $t1, $t5            # move to next column
    j loop_check_column

branch_and_return:
    move $v0, $t0
    jr $ra

check_floor_collision:
    subi $sp, $sp, 4          
    sw   $ra, 0($sp)
    
    lw $t6, GRID_HEIGHT
    
    # Get BOTTOMMOST block
    li   $a0, 3              # starting from row 3 (bottom)
    move $a1, $s3            # pointer to piece
    addi $a1, $a1, 48        # needs to be at row 3 (48 = 3 * 16)
    li   $a2, -1             # direction: bottom to top
    jal  get_vertical_extreme_block
    move $t8, $v0            # store bottommost row in $t8
    mult $t8, $s4            # multiply bottommost row by BLOCK_SIZE
    mflo $t8
    
    lw   $ra, 0($sp)
    addi $sp, $sp, 4         # add ra back  
    
    li $t0, 2                # default return value (collision found)
    
    # Check floor collision
    add $t1, $s2, $t8        # add bottommost row to y offset
    bge $t1, $t6, branch_and_return  # if floor is being clipped by updated y offset, return collision
    
    li $t0, 1                # No collision occurred
    j branch_and_return

# Arguments: $a0 — starting row index, $a1 — pointer to start of row, $a2 — direction (+1 = top to bottom, -1 = bottom to top)
get_vertical_extreme_block:
    move $t0, $a0      # row index
    move $t1, $a1      # row base ptr
    move $t4, $a2      # direction: +1 or -1
loop_check_row:
    lw $t2, 0($t1)     # check all 4 columns in this row
    lw $t3, 4($t1)
    add $t2, $t2, $t3
    lw $t3, 8($t1)
    add $t2, $t2, $t3
    lw $t3, 12($t1)
    add $t2, $t2, $t3
    bgtz $t2, branch_and_return
    add $t0, $t0, $t4            # row index += direction
    mul $t5, $t4, 16             # offset = direction × 16
    add $t1, $t1, $t5            # move to next row
    j loop_check_row
    
break_loop:
    jr $ra
    
    
## Clear lines section
clear_lines:
    subi $sp, $sp, 24           # Allocate stack space for 5 registers ($s0-$s3, $ra)
    sw $s0, 0($sp)              # Save $s0 (current row)
    sw $s1, 4($sp)              # Save $s1 (grid base address)
    sw $s2, 8($sp)              # Save $s2 (column counter)
    sw $s3, 12($sp)             # Save $s3 (row address)
    sw $ra, 20($sp)             # Save $ra (return address)
    
    la $s1, GRID_SPACE          # Load base address of grid into $s1
    li $s0, 19                  # Start from the bottom row (row 19)

# Loop to identify and clear all full lines first
clear_all_full_lines_loop:
    bltz $s0, all_full_lines_cleared # If row < 0, all rows have been checked for clearing
    
    # Calculate address of the current row ($s0)
    li $t0, 10                  # 10 columns per row
    mult $s0, $t0               # $t0 = current_row * 10 (number of cells)
    mflo $t0                    # Move result from multiplication to $t0
    sll $t0, $t0, 2             # $t0 = $t0 * 4 (byte offset for current row)
    add $s3, $s1, $t0           # $s3 = row address = grid_base_address + offset
    
    # Check if the entire current row ($s3) is filled
    li $s2, 0                   # Initialize column counter to 0
    li $t1, 1                   # Assume row is full (flag: 1 = full, 0 = not full)

check_row_columns_for_full:
    beq $s2, 10, row_full_check_done # If column counter reaches 10, all columns checked
    
    sll $t2, $s2, 2             # $t2 = column * 4 (byte offset for current cell in row)
    add $t3, $s3, $t2           # $t3 = address of current cell
    lw $t4, 0($t3)              # Load cell value into $t4
    beqz $t4, row_not_full_for_clear # If cell value is 0, row is not full
    
    addi $s2, $s2, 1            # Increment column counter
    j check_row_columns_for_full # Continue checking next column

row_not_full_for_clear:
    li $t1, 0                   # Mark row as not full (set flag to 0)

row_full_check_done:
    beqz $t1, next_row_to_check # If row is not full, skip clearing and check next row
    
    # Row IS full, clear it (set all cells to 0)
    # The clear_current_row subroutine uses $s3, which already holds the current row address
    lw $t9, LINES_CLEARED
    addi $t9, $t9, 1
    sw $t9, LINES_CLEARED
    jal clear_current_row       # Call function to clear the identified full row
    
next_row_to_check:
    subi $s0, $s0, 1            # Move to the next row up
    j clear_all_full_lines_loop # Continue checking rows

all_full_lines_cleared:
    # After all full lines have been identified and cleared (set to 0s),
    # now shift the remaining blocks down to fill the gaps.
    jal shift_rows_down         # Call the new shifting function

clear_lines_done:
    lw $s0, 0($sp)              # Restore $s0
    lw $s1, 4($sp)              # Restore $s1
    lw $s2, 8($sp)              # Restore $s2
    lw $s3, 12($sp)             # Restore $s3
    lw $ra, 20($sp)             # Restore $ra
    addi $sp, $sp, 24           # Deallocate stack space
    jr $ra                      # Return from clear_lines
    
    
clear_current_row:
    subi $sp, $sp, 4            # Save return address
    sw $ra, 0($sp)
    
    # Fill row with value 8 for animation
    li $t0, 0                   # Initialize column counter to 0
    
animate_row_loop:
    beq $t0, 10, animate_row_done 
    
    sll $t1, $t0, 2             # $t1 = column * 4 (byte offset)
    add $t2, $s3, $t1           # $t2 = address of current cell in the row
    li $t3, 8                   # Animation value
    sw $t3, 0($t2)              # Store 8 for animation effect
    
    addi $t0, $t0, 1            # Increment column counter
    j animate_row_loop          # Continue animating next column

animate_row_done:
    # Call fill_grid to show the animation frame
    jal fill_grid
    
    li $v0, 32                  # System call for sleep
    li $a0, 150                 # Sleep for 150ms to show animation
    syscall
    
    # Clear the row
    li $t0, 0                   # Initialize column counter to 0
    
clear_row_loop:
    beq $t0, 10, clear_row_done # If column counter reaches 10, all columns cleared
    
    sll $t1, $t0, 2             # $t1 = column * 4 (byte offset)
    add $t2, $s3, $t1           # $t2 = address of current cell in the row
    sw $zero, 0($t2)            # Store 0 (from $zero register) into the cell, effectively clearing it
    
    addi $t0, $t0, 1            # Increment column counter
    j clear_row_loop            # Continue clearing next column

clear_row_done:
    lw $ra, 0($sp)              # Restore return address
    addi $sp, $sp, 4
    jr $ra                      # Return from clear_current_row
    
shift_rows_down:
    subi $sp, $sp, 32           
    sw $s0, 0($sp)              # write_row - where to write next solid row
    sw $s1, 4($sp)              # read_row - current row being examined
    sw $s2, 8($sp)              # grid base address
    sw $s3, 12($sp)             # column counter
    sw $s4, 16($sp)             # read row address
    sw $s5, 20($sp)             # write row address
    sw $s6, 24($sp)             # empty line counter
    sw $ra, 28($sp)             # return address
    
    la $s2, GRID_SPACE          # Load base address of grid
    li $s0, 19                  # write_row starts at bottom (row 19)
    li $s1, 19                  # read_row starts at bottom (row 19)
    li $s6, 0                   # empty line counter

shift_main_loop:
    bltz $s1, shift_done        # If read_row < 0, we're done
    
    # Calculate address of read row
    li $t0, 10                  # 10 columns per row
    mult $s1, $t0               # read_row * 10
    mflo $t0
    sll $t0, $t0, 2             # multiply by 4 for byte offset
    add $s4, $s2, $t0           # $s4 = read row address
    
    # Check if current read row is empty
    jal is_row_empty            # Uses $s4 as row address, returns result in $v0
    beq $v0, 1, empty_row_found # If row is empty, handle it
    
    # Row is not empty - reset empty counter and copy if needed
    li $s6, 0                   # reset empty line counter
    
    # Only copy row if write_row != read_row (this mean we've skipped some empty rows)
    beq $s0, $s1, no_copy_needed
    
    # Calculate address of write row
    li $t0, 10                  # 10 columns per row
    mult $s0, $t0               # write_row * 10
    mflo $t0
    sll $t0, $t0, 2             # multiply by 4 for byte offset
    add $s5, $s2, $t0           # $s5 = write row address
    
    # Copy row from read position to write position
    jal copy_row                # Copy from $s4 (read) to $s5 (write)
    
no_copy_needed:
    subi $s0, $s0, 1            # Move write_row up one position
    j next_read_row

empty_row_found:
    addi $s6, $s6, 1            # Increment empty line counter
    
    # Check if we've found 5 consecutive empty rows
    beq $s6, 5, shift_done      # If 5 empty rows in a row, no more line clears possible
    
    # Don't update write_row for empty rows bc we're skipping them

next_read_row:
    subi $s1, $s1, 1            # Move to next row up
    j shift_main_loop

shift_done:
    # Only clear rows above the write position if we actually moved any rows down
    # (if write_row is now different from where it started)
    beq $s0, 19, shift_complete # If write_row is still 19, no rows were moved
    
clear_remaining_rows:
    bltz $s0, shift_complete    # If write_row < 0, we're done clearing
    
    # Calculate address of row to clear
    li $t0, 10                  # 10 columns per row
    mult $s0, $t0               # row * 10
    mflo $t0
    sll $t0, $t0, 2             # multiply by 4 for byte offset
    add $s5, $s2, $t0           # $s5 = row address to clear
    
    jal clear_row               # Clear the row at $s5
    subi $s0, $s0, 1            # Move to next row up
    j clear_remaining_rows

shift_complete:
    lw $s0, 0($sp)              # Restore $s0
    lw $s1, 4($sp)              # Restore $s1  
    lw $s2, 8($sp)              # Restore $s2
    lw $s3, 12($sp)             # Restore $s3
    lw $s4, 16($sp)             # Restore $s4
    lw $s5, 20($sp)             # Restore $s5
    lw $s6, 24($sp)             # Restore $s6
    lw $ra, 28($sp)             # Restore $ra
    addi $sp, $sp, 32           # Deallocate stack space
    jr $ra                      # Return


# Input: $s4 = row address
# Returns: $v0 = 1 if empty, 0 if not empty
is_row_empty:
    li $t0, 0                   # column counter
    li $v0, 1                   # assume row is empty
    
check_empty_loop:
    beq $t0, 10, empty_check_done # If we've checked all 10 columns
    
    sll $t1, $t0, 2             # column * 4 for byte offset
    add $t2, $s4, $t1           # address of current cell
    lw $t3, 0($t2)              # load cell value
    bnez $t3, row_not_empty     # if cell is not zero, row is not empty
    
    addi $t0, $t0, 1            # increment column counter
    j check_empty_loop

row_not_empty:
    li $v0, 0                   # row is not empty

empty_check_done:
    jr $ra

# Helper function: Copy one row to another
# Input: $s4 = source row address, $s5 = destination row address
copy_row:
    li $t0, 0                   # column counter
    
copy_loop:
    beq $t0, 10, copy_done      # If we've copied all 10 columns
    
    sll $t1, $t0, 2             # column * 4 for byte offset
    add $t2, $s4, $t1           # source cell address
    add $t3, $s5, $t1           # destination cell address
    
    lw $t4, 0($t2)              # load from source
    sw $t4, 0($t3)              # store to destination
    
    addi $t0, $t0, 1            # increment column counter
    j copy_loop

copy_done:
    jr $ra

# Helper function: Clear a row (set all cells to 0)
# Input: $s5 = row address
clear_row:
    li $t0, 0                   # column counter
    
clear_loop:
    beq $t0, 10, clear_done     # If we've cleared all 10 columns
    
    sll $t1, $t0, 2             # column * 4 for byte offset
    add $t2, $s5, $t1           # cell address
    sw $zero, 0($t2)            # store 0 in cell
    
    addi $t0, $t0, 1            # increment column counter
    j clear_loop

clear_done:
    jr $ra



## Resets and updates
reset:
    # Reset potential state
    move $a1, $s0
	move $a0, $s1
	jal update_tetromino_state
    
    li 		$v0, 32
	li 		$a0, 16           # sleep for 16ms
	syscall
	
	## Gravity stuff
    subi $s3, $s3, 1          # decrease gravity count
    lw $t0, LINES_CLEARED
    li $t1, 10
    div $t0, $t1              # check if its a multiple of 10
    mfhi $t2                  # remainder
    mflo $t3                  # quotient (gravity level) in $t3
    
    # Only increase gravity if we haven't already applied this level
    lw $t4, LAST_GRAVITY_LEVEL
    bne $t3, $t4, check_if_should_increase  # If current level != last level, check further
    j game_loop 

check_if_should_increase:
    beqz $t2, increase_gravity              # If remainder is 0 AND level changed, increase gravity
    j game_loop

increase_gravity:
    lw $t1, MAX_LINES_CLEARED
    bge $t0, $t1, increase_gravity_end      # if lines cleared >= max lines
    
    # Update the last gravity level applied
    sw $t3, LAST_GRAVITY_LEVEL              # Store current gravity level
    
    lw $t1, GRAVITY_INDEX
    addi $t1, $t1, 4                        # go to next index
    sw $t1, GRAVITY_INDEX
    
    la $t0, GRAVITY_DELAY
    add $t0, $t0, $t1                       # go to correct index in array
    lw $s3, 0($t0)                          # LOAD the new gravity delay value into $s3
    
    
increase_gravity_end:
    j game_loop

# Parameters: $a0 = old state, $a1 = new state
update_tetromino_state:
    lw $t0, 0($a1)
    lw $t1, 4($a1)
    lw $t2, 8($a1)
    lw $t3, 12($a1)

    sw $t0, 0($a0)
    sw $t1, 4($a0)
    sw $t2, 8($a0)
    sw $t3, 12($a0)
    
    jr $ra
    
store_piece:
    # Save registers on stack
    subi $sp, $sp, 28
    sw $s0, 0($sp)              
    sw $s1, 4($sp)              
    sw $s2, 8($sp)          
    sw $s3, 12($sp)             
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)
    
    la $t0, current_tetromino_state
    lw $s0, 8($t0)              # x_offset (constant)
    lw $s1, 12($t0)             # y_offset (constant)
    lw $s3, 0($t0)              # piece number (constant)
     
    move $a0, $s3
    lw $a1, 4($t0)              # rotation
    jal get_piece_data
    move $s2, $v0               # piece address (constant)
    
    lw $t0, WALL_WIDTH
    sub $s0, $s0, $t0           # subtract wall width from x_offset
    li $t0, 3
    div $s0, $t0                # divide by three as each block is 3 x 3
    mflo $s0
    mul $s0, $s0, 4             # byte orient it
    
    la $s4, GRID_SPACE          # base_addr
    li $s5, 40                  # constant for 1 grid row increment
    mult $s1, $s5               # multiply y_offset by display increment
    mflo $s5
    div $s5, $t0                # divide by three as each block is 3x3
    mflo $s5
    li $t0, 0                   # row (i)
    j store_piece_index

store_piece_index:
    beq $t0, 4, restore_and_exit  # check row counter against constant
    li $t5, 0                   # col number
    mul $t3, $t0, 40            # multiply row number by display increment
    add $t6, $s5, $t3           # new y_offset 40(y_offset + row number)

column_loop:
    beq $t5, 4, next_row      # if we've checked all 4 columns, move to next row
    
    mul $t7, $t5, 4             # column offset = col * 4 bytes
    add $t8, $s2, $t7           # address = piece_base + column_offset
    lw $t9, 0($t8)              # load column value
    
    add $t7, $t7, $s0           # new x_offset
    bne $t9, 1, column_loop_increment
    
    # Store value of piece
    add $t2, $s4, $t7           # add new x_offset to base_addr
    add $t2, $t2, $t6           # add new y_offset
    
    sw $s3, 0($t2)              # store piece valid in GRID_SPACE
    
    
column_loop_increment:    
    addi $t5, $t5, 1            # col++
    j column_loop

next_row:
    addi $t0, $t0, 1            # row index += 1
    addi $s2, $s2, 16           # move to next row in piece data
    j store_piece_index

restore_and_exit:
    jal clear_lines             # Clear lines after piece is stored
    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    j generate_new_piece

generate_new_piece:  
    subi $sp, $sp, 4
    sw $ra, 0($sp)      # store ra

    la $t0, current_tetromino_state         # load current tetromino
    
    li $a0, 0           # generator ID = 0 (default)
    li $a1, 7           # upper bound on tetromino
    li $v0, 42          # system call for random int
    syscall
    addi $t1, $a0, 1    # add 1 to random number as it's from (0-6)
    li $t2, 0           # new rotation
    li $t3, 26          # x_offset
    li $t4, 0           # y_offset
    
    sw $t1, 0($t0)
    sw $t2, 4($t0)
    sw $t3, 8($t0)
    sw $t4, 12($t0)
    
     la $a0, potential_tetromino_state
     la $a1, current_tetromino_state
     jal update_tetromino_state         # copy current state to potential state
     
     lw $ra, 0($sp)
     addi $sp, $sp, 4
    
     j setup_game_loop

game_loop:
    # if the gravity counter has gone to less than zero, drop the piece and don't receive input
    bltz $s3, gravity_drop
	# 1a. Check if key has been pressed
	jal check_input
	beqz $v0, reset
	# 1b. Check which key has been pressed
	move $a0, $s1
	move $a1, $s0
    jal keyboard_input
    
	j game_loop_p2

gravity_drop:
    lw $t0, 12($s1)                 # Load y_offset
    lw $t1, BLOCK_SIZE
    add $t0, $t0, $t1               # Add BLOCK_SIZE
    sw $t0, 12($s1)                 # Store back y_offset
    
    #reset gravity
    la $t0, GRAVITY_DELAY
    lw $t1, GRAVITY_INDEX
    add $t0, $t1, $t0
    
    lw $s3, 0($t0)
    li $v0, 2

game_loop_p2:
    move $s2, $v0
    # 2a. Check for collisions
    
    move $a0, $s1
    move $a1, $s2
    jal check_collision
    beqz $v0, reset
    beq $v0, 2, store_piece
    
	# 2b. Update locations (paddle, ball)
	move $a0, $s0
	move $a1, $s1
	jal update_tetromino_state
	# 3. Draw the screen
	jal draw_grid
	
	move $a0, $s0
	jal draw_outline               # outline placement
	lw $a0, 0($s0)                 # current piece
	lw $a1, 4($s0)                 # rotation
	lw $a2, 8($s0)                 # x_offset
	lw $a3, 12($s0)                # y_offset
	subi $sp, $sp, 4
	li $t0, 0
	sw $t0, 0($sp)                 # is_outline is false
	jal draw_tetromino
	addi $sp, $sp, 4
	# 4. Sleep
	jal reset

    #5. Go back to 1
    b game_loop

end: