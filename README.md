### MIPS Assembly Tetris Project Summary

This document provides a summary of the provided MIPS assembly code for Tetris, outlining its memory layout, key routines, data structures, and implemented features.

### Video Demonstration

A video demonstration can be found here: https://drive.google.com/file/d/1SL4aEQRvLuvtsU_kvv0Oy1O6IaN4D5KE/view?usp=sharing 

#### Memory Layout

* **Framebuffer:** The bitmap display is located at the base address `0x10008000`, accessed via the `$gp` register. The display has a width of 64 units and a height of 64 units, with each unit being 8 pixels, totaling a display size of 516x512 pixels.
* **Keyboard:** The keyboard is mapped to the base address `0xffff0000`.
* **Game Grid:** The game board is a 10x20 grid stored in the `.data` section under the label `GRID_SPACE`. It is allocated 800 bytes, with each grid cell occupying 4 bytes.
* **Tetromino State:**
    * `current_tetromino_state`: Stores the active piece's type, rotation, and screen coordinates (x, y offsets).
    * `potential_tetromino_state`: Holds the state of the piece for collision checks before a move is confirmed.
    * `outline_tetromino_state`: Used to store the state of the piece's "ghost" outline, which shows where it will land.
* **Game Variables:**
    * `LINES_CLEARED`: A word storing the total number of lines cleared by the player.
    * `GRAVITY_DELAY`: An array of words that defines the delay (in refreshes) for gravity at different levels. The delay decreases as more lines are cleared.
    * `GRAVITY_INDEX`: An index into the `GRAVITY_DELAY` array to determine the current gravity level.
    * `LAST_GRAVITY_LEVEL`: A word to track when the gravity level was last increased.
    * `BLOCK_SIZE`: Defines the size of each block in the grid, which is 3 units.
* **Colours:**
    * `wallColour`, `primaryGridColour`, `secondaryGridColour`: Store the hexadecimal color values for the game's static elements.
    * `s_pieces`, `z_pieces`, `i_pieces`, `o_pieces`, `t_pieces`, `l_pieces`, `j_pieces`: Each tetromino has its own dedicated data structure that includes two colors (primary and secondary) and a 4x4 matrix for each of its four possible rotations.

#### Key Routines

* **`main`**: The entry point of the program. It initializes the game, sets up the game loop, and calls other routines.
* **`draw_rectangle`**: A generic function to draw a rectangle on the bitmap display. It takes the base address, offsets, and dimensions as arguments, and colors are passed on the stack. It also handles the alternating color pattern for the grid.
* **`draw_tetromino`**: Draws a tetromino piece using its state (piece type, rotation, and position). It can also draw a piece's outline if a flag is set.
* **`check_input` / `keyboard_input`**: Polls the keyboard to detect which key has been pressed and updates the `potential_tetromino_state` based on the input (A/D for left/right, W for rotate, S for down, Space for hard drop).
* **`check_collision`**: A primary routine that calls subroutines to check for collisions with walls, the floor, and other placed blocks in the grid.
* **`calculate_grid`**: Calculates the dimensions of the game grid and display increment based on predefined constants like `DISPLAY_WIDTH` and `WALL_WIDTH`.
* **`fill_grid`**: Renders the game grid, including any stored tetromino blocks, by iterating through the `GRID_SPACE` array.
* **`store_piece`**: Places a tetromino into the `GRID_SPACE` array after it has landed, converting screen coordinates to grid coordinates.
* **`clear_lines`**: Iterates through the game grid to check for and clear any full rows. It then shifts the remaining blocks down to fill the gaps. An animation is played before a line is fully cleared.
* **`generate_new_piece`**: Generates a new random tetromino and places it at the top of the grid.

#### Data Structures

* **Piece Data**: Tetrominoes are defined as a series of 4x4 matrices, stored as a sequence of words. Each word represents a block's presence (1) or absence (0). Each piece's data includes two associated colors at the start, followed by the four 4x4 matrices for its rotations.
* **Grid**: A linear array of words (`GRID_SPACE`), where each word represents a cell on the 10x20 game board. A value of `0` indicates an empty cell, while a value from `1` to `7` corresponds to a stored tetromino's type.
* **Game State**: The `current_tetromino_state` and related variables are structured as an array of four words to hold the piece type, rotation, x-offset, and y-offset, respectively.

#### Implemented Features

* **Milestone 5**: This project has reached Milestone 5.
* **Easy Features**:
    1.  All tetrominoes have different colors.
    2.  Gravity is implemented, causing the pieces to fall over time.
    3.  The gravity speed increases every 10 lines cleared.
    4.  An outline of the falling piece is displayed at the bottom of its potential drop location.
* **Hard Features**:
    1.  All seven standard tetrominoes (S, Z, I, O, T, L, J) are implemented.
    2.  An animation plays when a line is cleared.
