# Rubik's Cube Solver

## Brief Summary
A 3D Rubik's Cube simulation capable of solving a 2x2, 3x3, and 4x4 cube using a popular blindfolded solving method. Users can also manually edit the cube by clicking a face and dragging the mouse in the direction that they want the turn to go.

## The Solving Method
The blindfolded method I chose to implement starts by solving all of the center pieces, then all of the edges, and finally the corners. "U2" is the name of the method used to solve the centers, "M2" is the method to solve the edges, and "Old Pochmann" is the method to solve the corners. Each method is explained extremely well in [this](https://www.youtube.com/watch?v=dG4J_ro_dDQ) video, but the general idea behind each of them is the same. Each method solves one piece at a time using an algorithm that only swaps two pieces. These pieces are called the buffer and the target. You start by looking at the buffer and find where it needs to be moved to in order to be solved. The piece that is currently in that position can be moved to the target using a specific sequence of turns called the  setup moves. The pieces can then be swapped using the swapping algorithm, however, it is not solved just yet. It is currently still in the target position, not its solved position where it needs to be. It must be moved back to its solved position by reversing the setup moves that were used to get it there in the first place. The piece is now solved and there is a new unsolved piece in the buffer position. The same process can be repeated for that piece and every piece after it until all of the centers, edges, or corners are solved.

## What I Learned
- Built-in Processing Events, Functions, and Variables
- 2D and 3D Matrix Transformations
- 3D Vector Directions
- Java Syntax and Keywords
- OOP Concepts in Java
