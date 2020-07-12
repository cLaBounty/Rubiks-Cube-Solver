class FourDimCube extends Cube {
  
  /*
  setUpSequence.add(new TurnAnimation('L', -1)); // L
  setUpSequence.add(new TurnAnimation('l', -1)); // l
  setUpSequence.add(new TurnAnimation('R', 1)); // R
  setUpSequence.add(new TurnAnimation('r', 1)); // r
  
  setUpSequence.add(new TurnAnimation('U', 1)); // U
  setUpSequence.add(new TurnAnimation('u', 1)); // u
  setUpSequence.add(new TurnAnimation('D', -1)); // D
  setUpSequence.add(new TurnAnimation('d', -1)); // d
  
  setUpSequence.add(new TurnAnimation('B', -1)); // B
  setUpSequence.add(new TurnAnimation('b', -1)); // b
  setUpSequence.add(new TurnAnimation('F', 1)); // F
  setUpSequence.add(new TurnAnimation('f', 1)); // f
                    
  solveTurnSequence
  */
  
  /*
  Phase 1: Solved all center pieces 
  Phase 2: Solve all wing pieces
  Phase 3: Solve all corner pieces
  */
  private int solvePhase;
  
  // counter's to determine if parity after solving centers, wings, and corners
  private int centerSwapCount;
  private int wingSwapCount;
  private int cornerSwapCount;
  
  // constructor
  FourDimCube() {
    super();
    
    dim = 4;
    cellLength = CUBE_LENGTH / 4;
    cells = new Cell[64];
    turnOffset = -0.5;
    scrambleTurnNum = 40;
    
    turnXBases = new char[]{'L', 'l', 'r', 'R'};
    turnYBases = new char[]{'U', 'u', 'd', 'D'};
    turnZBases = new char[]{'B', 'b', 'f', 'F'};
    
    solvePhase = 1;
    centerSwapCount = 0;
    wingSwapCount = 0;
    cornerSwapCount = 0;
  }
  
  public void solve() {
    isSolving = true;
    
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
    solvePhase = 1;
    centerSwapCount = 0;
    wingSwapCount = 0;
    cornerSwapCount = 0;
  }
  
  protected void setNextTurns() {
    if (solvePhase == 1) {      
      if (!areCentersSolved()) {
        solveCenter();
      }
      else {
        // Parity Algorithm (only if an odd # of centers were moved)
        if (centerSwapCount % 2 == 1)
          addCenterParityAlgorithm();
        
        // next phase
        solvePhase++;
      }
    }
    else if (solvePhase == 2) {
      if (!areWingsFixed()) {
        solveWing();
      }
      else {
        // Parity Algorithm (only if an odd # of wings were moved)
        if (wingSwapCount % 2 == 1)
          addWingParityAlgorithm();
        
        // next phase
        solvePhase++;
      }
    }
    else if (solvePhase == 3) {
      if (!isCubeFixed())
        solveCorner();
      else {
        // Parity Algorithm (only if an odd # of corners were moved)
        if (cornerSwapCount % 2 == 1)
          addCornerParityAlgorithm();
        
        // next phase
        solvePhase++;
      }
    }
    else if (solvePhase == 4) { // finished
      isSolving = false;
    }
  }

  private boolean areCentersSolved() {
    // loop through all center pieces to see if any are in an incorrect position
    for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
      // only check if the center pieces are unsolved
      if (cells[i].coloredFaces.size() == 1) {
        if ((cells[i].currentX != cells[i].solvedX && (cells[i].solvedX == 0 || cells[i].solvedX == 3)) ||
            (cells[i].currentY != cells[i].solvedY && (cells[i].solvedY == 0 || cells[i].solvedY == 3)) ||
            (cells[i].currentZ != cells[i].solvedZ && (cells[i].solvedZ == 0 || cells[i].solvedZ == 3))) {
              return false;
        }
      }
    }
    
    return true;
  }
  
  private boolean areWingsFixed() {
    // counter to determine how many cells in the r slice are unsolved of flipped
    int parityCounter = 0;
    
    // loop through all wing pieces to see if any are in the incorrect position
    for (Cell c : cells) {
      // only check the wing pieces
      if (c.coloredFaces.size() == 2) {
        // if the cell is in the incorrect position or flipped
        if ((c.currentX != c.solvedX && (c.solvedX == 0 || c.solvedX == 3)) ||
           (c.currentY != c.solvedY && (c.solvedY == 0 || c.solvedY == 3)) ||
           (c.currentZ != c.solvedZ && (c.solvedZ == 0 || c.solvedZ == 3)) || c.isFlipped()) {
            
            // Parity
            if (wingSwapCount % 2 == 1) {
              // allow for 2 cells to be off in the r slice
              if (c.currentX == 2)
                parityCounter++;
              else
                return false;
            }
            else { // if NOT parity, then all should be solved
              return false;
            }
        }
      }
    }
    
    // if less than 2 cells are off in the r slice, then the wings are fixed
    if (parityCounter > 2)
      return false;
    else
      return true;
  }
  
  private boolean isCubeFixed() {
    
    // counter to determine how many cells on the top left/back are unsolved of flipped
    int parityCounter = 0;
    
    for (Cell c : cells) {
      if (c.coloredFaces.size() == 1) { // centers
        if ((c.currentX != c.solvedX && (c.solvedX == 0 || c.solvedX == 3)) ||
            (c.currentY != c.solvedY && (c.solvedY == 0 || c.solvedY == 3)) ||
            (c.currentZ != c.solvedZ && (c.solvedZ == 0 || c.solvedZ == 3))) {
              return false;
        }
      }
      else if (c.coloredFaces.size() == 2) { // wings
        // if the cell is in the incorrect position or flipped
        if ((c.currentX != c.solvedX && (c.solvedX == 0 || c.solvedX == 3)) ||
            (c.currentY != c.solvedY && (c.solvedY == 0 || c.solvedY == 3)) ||
            (c.currentZ != c.solvedZ && (c.solvedZ == 0 || c.solvedZ == 3)) || c.isFlipped()) {
              // allow for 2 cells to be off on the top left/back
              if (c.currentY == 0 && (c.currentX == 0 || c.currentZ == 0))
                parityCounter++;
              else
                return false;
        }
      }
      else if (c.coloredFaces.size() == 3) { // corners
        if (!c.isSolved()) {
          return false; 
        }
      }
    }

    // if less than 4 cells are off on the top left/back, then the cube is fixed
    if (parityCounter > 4)
      return false;
    else
      return true;
  }
  
  private void solveCenter() {
    // U2 Swap Algorithm
    final TurnAnimation[] U2_SWAP_ALG = {
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1) // U
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
      if (cells[i].currentX == 1 && cells[i].currentY == 0 && cells[i].currentZ == 1) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the face color of the buffer cell
    color bufferColor = cells[bufferIndex].coloredFaces.get(0).col;
    
    // find where the buffer needs to go
    int swapCellX = -1;
    int swapCellY = -1;
    int swapCellZ = -1;

    if (bufferColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferColor == #FF0000)
      swapCellX = 3;
    else if (bufferColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferColor == #FFFF00)
      swapCellY = 3;
    else if (bufferColor == #0000FF)
      swapCellZ = 0;
    else if (bufferColor == #00FF00)
      swapCellZ = 3;
    
    // increment the center swap counter
    centerSwapCount++;
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getCenterSetupMoves(swapCellX, swapCellY, swapCellZ);

    // if no setup moves are needed or a special case, then do nothing
    if (setUpSequence.size() != 0) {
      // reversed setup moves to put back in it's original place
      ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
      for (int i = setUpSequence.size() - 1; i >= 0; i--) {
        char notationBase = setUpSequence.get(i).getNotationBase();
        int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
        reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
      }
      
      // add all turns to the solve sequence
      solveTurnSequence.addAll(setUpSequence);
      solveTurnSequence.addAll(Arrays.asList(U2_SWAP_ALG));
      solveTurnSequence.addAll(reverseSetUpSequence);
    }
  }
  
  private ArrayList<TurnAnimation> getCenterSetupMoves(int swapCellX, int swapCellY, int swapCellZ) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    /* 
      If all white centers are solved, a new cell is never found.
      If this happens, find any unsolved piece and swap with it
    */
    do {
      if (swapCellY == 0) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentY == swapCellY) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #FFFFFF) {
              if ((cells[i].currentX == 2 && cells[i].currentZ == 1 && centerSwapCount % 2 == 1) || // B Face and 1st in pair
                  (cells[i].currentX == 1 && cells[i].currentZ == 2 && centerSwapCount % 2 == 0)) { // D Face and 2nd in pair
                  
                  // special case - add directly to solve sequence
                  solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
                  solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
                  solveTurnSequence.add(new TurnAnimation('F', -1)); // F'
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  solveTurnSequence.add(new TurnAnimation('r', 1)); // r
                  solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
                  solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
                  solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
                  solveTurnSequence.add(new TurnAnimation('l', -1)); // l
                  solveTurnSequence.add(new TurnAnimation('F', 1)); // F
                  solveTurnSequence.add(new TurnAnimation('R', 1)); // R
                  solveTurnSequence.add(new TurnAnimation('r', 1)); // r
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  
                  return setUpSequence; // no need to search further
              }
              else if (cells[i].currentX == 2 && cells[i].currentZ == 2) { // C Face
                // special case - add directly to solve sequence
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                
                return setUpSequence; // no need to search further  
              }
              else if ((cells[i].currentX == 1 && cells[i].currentZ == 2 && centerSwapCount % 2 == 1) || // D Face and 1st in pair
                (cells[i].currentX == 2 && cells[i].currentZ == 1 && centerSwapCount % 2 == 0)) { // B Face and 2nd in pair
                
                // special case - add directly to solve sequence
                solveTurnSequence.add(new TurnAnimation('L', -1)); // L
                solveTurnSequence.add(new TurnAnimation('l', -1)); // l
                solveTurnSequence.add(new TurnAnimation('F', -1)); // F'
                solveTurnSequence.add(new TurnAnimation('r', 1)); // r
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
                solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
                solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                solveTurnSequence.add(new TurnAnimation('l', -1)); // l
                solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
                solveTurnSequence.add(new TurnAnimation('F', 1)); // F
                solveTurnSequence.add(new TurnAnimation('L', 1)); // L'
                solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                
                return setUpSequence; // no need to search further
              } 
            }
          }
        }
      }
      else if (swapCellX == 0) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentX == swapCellX) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #FF8D1A) {
              if (cells[i].currentY == 1) {
                if (cells[i].currentZ == 1) { // E Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentZ == 2) { // F Face
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentZ == 2) { // G Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentZ == 1) { // H Face
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  
                  return setUpSequence; // no need to search further
                }
              }
            }
          }
        }
      }
      else if (swapCellZ == 3) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentZ == swapCellZ) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #00FF00) {
              if (cells[i].currentY == 1) {
                if (cells[i].currentX == 1) { // I Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentX == 2) { // J Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentX == 2) { // K Face
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentX == 1) { // L Face
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'                  
                  
                  return setUpSequence; // no need to search further
                }
              }
            }
          }
        }
      }
      else if (swapCellX == 3) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentX == swapCellX) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #FF0000) {
              if (cells[i].currentY == 1) {
                if (cells[i].currentZ == 2) { // M Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentZ == 1) { // N Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentZ == 1) { // O Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentZ == 2) { // P Face
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  
                  return setUpSequence; // no need to search further
                }
              }
            }
          }
        }
      }
      else if (swapCellZ == 0) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentZ == swapCellZ) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #0000FF) {
              if (cells[i].currentY == 1) {
                if (cells[i].currentX == 2) { // Q Face
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentX == 1) { // R Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f                
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentX == 1) { // S Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentX == 2) { // T Face
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  
                  return setUpSequence; // no need to search further
                }
              }
            }
          }
        }
      }
      else if (swapCellY == 3) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentY == swapCellY) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #FFFF00) {
              // special case - add directly to solve sequence
              if (cells[i].currentX == 1 && cells[i].currentZ == 2) { // U Face
                solveTurnSequence.add(new TurnAnimation('D', -1)); // D
              }
              else if (cells[i].currentZ == 1) {
                if (cells[i].currentX == 2) { // W Face
                  solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
                }
                else if (cells[i].currentX == 1) { // X Face
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                }
              }
              
              solveTurnSequence.add(new TurnAnimation('L', 1)); // L'
              solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
              solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
              solveTurnSequence.add(new TurnAnimation('r', 1)); // r
              solveTurnSequence.add(new TurnAnimation('r', 1)); // r
              solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
              solveTurnSequence.add(new TurnAnimation('l', -1)); // l
              solveTurnSequence.add(new TurnAnimation('U', 1)); // U
              solveTurnSequence.add(new TurnAnimation('r', 1)); // r
              solveTurnSequence.add(new TurnAnimation('r', 1)); // r
              solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
              solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
              solveTurnSequence.add(new TurnAnimation('U', 1)); // U
              solveTurnSequence.add(new TurnAnimation('U', 1)); // U
              solveTurnSequence.add(new TurnAnimation('L', -1)); // L
              solveTurnSequence.add(new TurnAnimation('l', -1)); // l
              solveTurnSequence.add(new TurnAnimation('U', 1)); // U
              solveTurnSequence.add(new TurnAnimation('U', 1)); // U
              
              // invert the special setup moves
              if (cells[i].currentX == 1 && cells[i].currentZ == 2) { // U Face
                solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
              }
              else if (cells[i].currentZ == 1) {
                if (cells[i].currentX == 2) { // W Face
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                }
                else if (cells[i].currentX == 1) { // X Face
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                }
              }
              
              return setUpSequence; // no need to search further
            }
          }
        }
      }
      
      // if no cell was found and the function has not returned, then pick any unsolved piece
      for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
        // only check the center pieces that are are unsolved
        if (cells[i].coloredFaces.size() == 1) {
          if ((cells[i].currentX != cells[i].solvedX && (cells[i].solvedX == 0 || cells[i].solvedX == 3)) ||
              (cells[i].currentY != cells[i].solvedY && (cells[i].solvedY == 0 || cells[i].solvedY == 3)) ||
              (cells[i].currentZ != cells[i].solvedZ && (cells[i].solvedZ == 0 || cells[i].solvedZ == 3))) {
              
              swapCellX = cells[i].currentX;
              swapCellY = cells[i].currentY;
              swapCellZ = cells[i].currentZ;
              
              break;
          }
        }
      }
    } while (true); // repeat to get setup moves of the new cell
  }
  
  private void addCenterParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1) // U
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
  
  private void solveWing() {
    // r2 Swap Algorithm
    final TurnAnimation[] r2_SWAP_ALG = {
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('r', -1) // r'
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 1; i < (cells.length - 1); i++) { // first wing is at index 1 and last is at cells.length - 1
      if (cells[i].currentX == 2 && cells[i].currentY == 3 && cells[i].currentZ == 3) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the down and front face color of the buffer cell
    color bufferDownColor = #FFFFFF;
    color bufferFrontColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == 1) // down face
         bufferDownColor = f.col;
      else if (f.dir.z == 1) // front face
         bufferFrontColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = -1;
    int swapCellY = -1;
    int swapCellZ = -1;

    if (bufferDownColor == #FF8D1A || bufferFrontColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferDownColor == #FF0000 || bufferFrontColor == #FF0000)
      swapCellX = 3;
    
    if (bufferDownColor == #FFFFFF || bufferFrontColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferDownColor == #FFFF00 || bufferFrontColor == #FFFF00)
      swapCellY = 3;
    
    if (bufferDownColor == #0000FF || bufferFrontColor == #0000FF)
      swapCellZ = 0;
    else if (bufferDownColor == #00FF00 || bufferFrontColor == #00FF00)
      swapCellZ = 3;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferDownColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferDownColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferDownColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferDownColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferDownColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);
    
    // increment the edge swap counter
    wingSwapCount++;
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getWingSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // if no setup moves are needed or a special case, then do nothing
    if (setUpSequence.size() != 0) {
      // reversed setup moves to put back in it's original place
      ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
      for (int i = setUpSequence.size() - 1; i >= 0; i--) {
        char notationBase = setUpSequence.get(i).getNotationBase();
        int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
        reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
      }
      
      // add all turns to the solve sequence
      solveTurnSequence.addAll(setUpSequence);
      solveTurnSequence.addAll(Arrays.asList(r2_SWAP_ALG));
      solveTurnSequence.addAll(reverseSetUpSequence);
    }
  }
  
  private ArrayList<TurnAnimation> getWingSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
        
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    /*
      When the swap cell is also the buffer, it choses a random face on an unsolved cell.
      If the face chosen is not the furthest clockwise, then the other face will be chosen
    */
    boolean wrongSide;
    
    // index of the new unsolved cell when the swap cell is also the buffer
    int swapCellIndex = 0;
    
    /*
      When swap is the 2nd letter of a pair and it is a special face
      in the r slice (I, S), then swap with the opposite face instead
    */
    if (wingSwapCount % 2 == 0) {
      if (swapCellDir.z == 1 && swapCellY == 0) { // I face to S Face
        swapCellDir.z = -1;
        swapCellY = 3;
        swapCellZ = 0;
      }
      else if (swapCellDir.z == -1 && swapCellY == 3) { // S face to I Face
        swapCellDir.z = 1;
        swapCellY = 0;
        swapCellZ = 3;
      }
    }
    
    do {
      isBuffer = false;
      wrongSide = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
          // special case - add directly to solve sequence
          println("A");
          
          if (swapCellX == -1 || swapCellX == 2) {
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          }
          else
            wrongSide = true;
            
        }
        else if (swapCellX == 3) { // B face
          println("B");
          
          if (swapCellZ == -1 || swapCellZ == 2) {
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('U', 1)); // U
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 3) { // C face
          // special case - add directly to solve sequence
          println("C");
          
          if (swapCellX == -1 || swapCellX == 1) {
            solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 0) { // D face
          println("D");
          
          if (swapCellZ == -1 || swapCellZ == 1) {
            setUpSequence.add(new TurnAnimation('L', 1)); // L'
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('U', 1)); // U
          }
          else
            wrongSide = true;
          
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
          println("E");
          
          if (swapCellZ == -1 || swapCellZ == 2) {
            setUpSequence.add(new TurnAnimation('B', -1)); // B
            setUpSequence.add(new TurnAnimation('L', 1)); // L'
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 3) { // F face
          println("F");
          
          if (swapCellY == -1 || swapCellY == 2) {
            setUpSequence.add(new TurnAnimation('B', -1)); // B
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellY == 3) { // G face
          println("G");
          
          if (swapCellZ == -1 || swapCellZ == 1) {
            setUpSequence.add(new TurnAnimation('B', -1)); // B
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 0) { // H face
          println("H");
          
          if (swapCellY == -1 || swapCellY == 1) {
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('B', -1)); // B
            setUpSequence.add(new TurnAnimation('L', 1)); // L'
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
          }
          else
            wrongSide = true;
          
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
          // special case - add directly to solve sequence
          println("I");
                    
          if (swapCellX == -1 || swapCellX == 2) {
            solveTurnSequence.add(new TurnAnimation('D', -1)); // D
            solveTurnSequence.add(new TurnAnimation('r', 1)); // r
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 3) { // J face
          println("J");
                    
          if (swapCellY == -1 || swapCellY == 2) {
            setUpSequence.add(new TurnAnimation('U', 1)); // U
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellY == 3) { // K face
          println("K");
                    
          if (swapCellX == -1 || swapCellX == 1) {
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 0) { // L face
          println("L");
          
          if (swapCellY == -1 || swapCellY == 1) {
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
            setUpSequence.add(new TurnAnimation('L', 1)); // L'
            setUpSequence.add(new TurnAnimation('U', 1)); // U
          }
          else
            wrongSide = true;
          
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
          println("M");
          
          if (swapCellZ == -1 || swapCellZ == 1) {
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('B', -1)); // B
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 0) { // N face
          println("N");
                    
          if (swapCellY == -1 || swapCellY == 2) {
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('B', -1)); // B
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellY == 3) { // O face
          println("O");
                    
          if (swapCellZ == -1 || swapCellZ == 2) {
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('B', -1)); // B
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 3) { // P face
          println("P");
                    
          if (swapCellY == -1 || swapCellY == 1) {
            setUpSequence.add(new TurnAnimation('B', 1)); // B'
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('B', -1)); // B
          }
          else
            wrongSide = true;
          
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
          // special case - add directly to solve sequence
          println("Q");
                    
          if (swapCellX == -1 || swapCellX == 1) {
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 0) { // R face
          println("R");
          
          if (swapCellY == -1 || swapCellY == 2) {
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('U', 1)); // U
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellY == 3) { // S face
          // special case - add directly to solve sequence
          println("S");
                    
          if (swapCellX == -1 || swapCellX == 2) {
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('D', -1)); // D
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('r', 1)); // r
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 3) { // T face
          println("T");
                    
          if (swapCellY == -1 || swapCellY == 1) {
            setUpSequence.add(new TurnAnimation('U', 1)); // U
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
          }
          else
            wrongSide = true;
          
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 3) { // U face
          println("U");
          if (swapCellX == -1 || swapCellX == 2)
            isBuffer = true;
          else
            wrongSide = true; //<>//
        }
        else if (swapCellX == 3) { // V face
          println("V");
                    
          if (swapCellZ == -1 || swapCellZ == 1) {
            setUpSequence.add(new TurnAnimation('U', 1)); // U
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellZ == 0) { // W face
          // special case - add directly to solve sequence
          println("W");
                    
          if (swapCellX == -1 || swapCellX == 1) {
            solveTurnSequence.add(new TurnAnimation('l', -1)); // l
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('R', 1)); // R
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
            solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
            solveTurnSequence.add(new TurnAnimation('U', 1)); // U
            solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
            solveTurnSequence.add(new TurnAnimation('B', -1)); // B
            solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
            solveTurnSequence.add(new TurnAnimation('l', 1)); // l'
          }
          else
            wrongSide = true;
          
        }
        else if (swapCellX == 0) { // X face
          println("X");
                    
          if (swapCellZ == -1 || swapCellZ == 2) {
            setUpSequence.add(new TurnAnimation('U', -1)); // U'
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('L', -1)); // L
            setUpSequence.add(new TurnAnimation('U', 1)); // U
          }
          else
            wrongSide = true;
          
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        // first wing is at index 1 and last is at cells.length - 1
        for (int i = 1; i < cells.length - 1; i++) {
          // only check the wing pieces
          if (cells[i].coloredFaces.size() == 2) {
            // if the cell is in the incorrect position or flipped
            if ((cells[i].currentX != cells[i].solvedX && (cells[i].solvedX == 0 || cells[i].solvedX == 3)) ||
                (cells[i].currentY != cells[i].solvedY && (cells[i].solvedY == 0 || cells[i].solvedY == 3)) ||
                (cells[i].currentZ != cells[i].solvedZ && (cells[i].solvedZ == 0 || cells[i].solvedZ == 3)) || cells[i].isFlipped()) {
              
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                               
                swapCellDir.x = cells[i].coloredFaces.get(0).dir.x;
                swapCellDir.y = cells[i].coloredFaces.get(0).dir.y;
                swapCellDir.z = cells[i].coloredFaces.get(0).dir.z;
             
                swapCellIndex = i;
                
                // if the swap cell is not in either of the identical buffer locations
                if (swapCellY != 3 || swapCellZ != 3) {
                  // if the r slice is correctly oriented or the swap cell is not in r slice, then swap with it
                  if (wingSwapCount % 2 == 1 || swapCellX != 2)
                    break;
                }
            }
          }
        }
        
      }
      // if the wrong side is chosen when the swap cell is also the buffer
      else if (wrongSide) {
        swapCellDir.x = cells[swapCellIndex].coloredFaces.get(1).dir.x;
        swapCellDir.y = cells[swapCellIndex].coloredFaces.get(1).dir.y;
        swapCellDir.z = cells[swapCellIndex].coloredFaces.get(1).dir.z;
      }
      
    } while (isBuffer || wrongSide);
    
    return setUpSequence;
  }
  
  private void addWingParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('r', 1), // r
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('r', 1), // r
      new TurnAnimation('F', 1), // F
      new TurnAnimation('F', 1), // F
      new TurnAnimation('r', 1), // r
      new TurnAnimation('F', 1), // F
      new TurnAnimation('F', 1), // F
      new TurnAnimation('r', 1), // r
      new TurnAnimation('F', 1), // F
      new TurnAnimation('F', 1), // F
      new TurnAnimation('r', 1), // r
      new TurnAnimation('r', 1), // r
      new TurnAnimation('F', 1), // F
      new TurnAnimation('F', 1), // F
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1) // U
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
  
  private void solveCorner() {
    // Modified Y Perm Algorithm
    final TurnAnimation[] MOD_Y_PERM_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1), // F'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1) // R
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 0; i < cells.length; i++) {
      if (cells[i].currentX == 0 && cells[i].currentY == 0 && cells[i].currentZ == 0) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the up, left, and back face color of the buffer cell
    color bufferUpColor = #FFFFFF;
    color bufferLeftColor = #FFFFFF;
    color bufferBackColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == -1) // up face
        bufferUpColor = f.col;
      else if (f.dir.x == -1) // left face
        bufferLeftColor = f.col;
      else if (f.dir.z == -1) // back face
        bufferBackColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = -1;
    int swapCellY = -1;
    int swapCellZ = -1;

    if (bufferUpColor == #FF8D1A || bufferLeftColor == #FF8D1A || bufferBackColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferUpColor == #FF0000 || bufferLeftColor == #FF0000 || bufferBackColor == #FF0000)
      swapCellX = 3;
    
    if (bufferUpColor == #FFFFFF || bufferLeftColor == #FFFFFF || bufferBackColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferLeftColor == #FFFF00 || bufferBackColor == #FFFF00)
      swapCellY = 3;
    
    if (bufferUpColor == #0000FF || bufferLeftColor == #0000FF || bufferBackColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferLeftColor == #00FF00 || bufferBackColor == #00FF00)
      swapCellZ = 3;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferLeftColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferLeftColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferLeftColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferLeftColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferLeftColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);
    
    // increment the corner swap counter
    cornerSwapCount++;
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getCornerSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // reversed setup moves to put back in it's original place
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--) {
      char notationBase = setUpSequence.get(i).getNotationBase();
      int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
      reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
    }

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(MOD_Y_PERM_ALG)); 
    solveTurnSequence.addAll(reverseSetUpSequence);
  }
  
  private ArrayList<TurnAnimation> getCornerSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) {
          if (swapCellX == 0) { // A face
            isBuffer = true;
          }
          else if (swapCellX == 3) { // B face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
        else if (swapCellZ == 3) {
          if (swapCellX == 3) { // C face           
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
          else if (swapCellX == 0) { // D face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) {
          if (swapCellZ == 0) { // E face
            isBuffer = true;
          }
          else if (swapCellZ == 3) { // F face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
        else if (swapCellY == 3) {
          if (swapCellZ == 3) { // G face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellZ == 0) { // H face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) {
          if (swapCellX == 0) { // I face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
          else if (swapCellX == 3) { // J face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
        else if (swapCellY == 3) {
          if (swapCellX == 3) { // K face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
          else if (swapCellX == 0) { // L face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) {
          if (swapCellZ == 3) { // M face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 0) { // N face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
        else if (swapCellY == 3) {
          if (swapCellZ == 0) { // O face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 3) { // P face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) {
          if (swapCellX == 3) { // Q face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // R face
            isBuffer = true;
          }
        }
        else if (swapCellY == 3) {
          if (swapCellX == 0) { // S face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellX == 3) { // T face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellX == 0 && swapCellZ == 3) { // U face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
        }
        else if (swapCellZ == 0) {
          if (swapCellX == 3) { // W face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // X face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved or flipped piece
      if (isBuffer) {
        // don't allow for the new cell to be the buffer at index 0
        for (int i = 1; i < cells.length; i++) {
          // only check the corner pieces
          if (cells[i].coloredFaces.size() == 3) {
            // if the cell is in the incorrect position or flipped
            if (!cells[i].isSolved()) {
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir.x = cells[i].coloredFaces.get(0).dir.x;
                swapCellDir.y = cells[i].coloredFaces.get(0).dir.y;
                swapCellDir.z = cells[i].coloredFaces.get(0).dir.z;
                
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  private void addCornerParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('u', 1), // u
      new TurnAnimation('u', 1), // u
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('r', -1), // r'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('u', 1), // u
      new TurnAnimation('u', 1), // u
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
}
