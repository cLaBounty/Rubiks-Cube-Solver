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
  
  // counter to determine if parity is needed after solving centers
  private int centerSwapCount;
  // counter to determine if parity is needed after solving wings
  private int wingSwapCount;
  
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
  }
  
  public void solve() {
    isSolving = true;
    
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
    solvePhase = 1;
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
      /*
      if (!isSolved()) MUST CHANGE to account for centers and wings in wrong positions
        solveCorner();
      else
        isSolving = false;
      */
    }
  }

  private boolean areCentersSolved() {
    // loop through all center pieces to see if any are in the incorrect position
    for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
      // only check if the center pieces are unsolved
      if (cells[i].coloredFaces.size() == 1) {
        if (!((cells[i].solvedX == 0 || cells[i].solvedX == 3) && cells[i].currentX == cells[i].solvedX) &&
            !((cells[i].solvedY == 0 || cells[i].solvedY == 3) && cells[i].currentY == cells[i].solvedY) &&
            !((cells[i].solvedZ == 0 || cells[i].solvedZ == 3) && cells[i].currentZ == cells[i].solvedZ)) {
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
        if (!c.isSolved()) {
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
    
    // if less than 2 cells are off in the M slice, then the edges are fixed
    if (parityCounter > 2)
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
              if ((cells[i].currentX == 2 && cells[i].currentZ == 1 && centerSwapCount % 2 == 1) || // B Face
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
              else if ((cells[i].currentX == 1 && cells[i].currentZ == 2 && centerSwapCount % 2 == 1) || // D Face
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
      
      // if no cell was found, pick any unsolved piece
      for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
        // only check the center pieces that are are unsolved
        if (cells[i].coloredFaces.size() == 1) {
          if (!((cells[i].solvedX == 0 || cells[i].solvedX == 3) && cells[i].currentX == cells[i].solvedX) &&
              !((cells[i].solvedY == 0 || cells[i].solvedY == 3) && cells[i].currentY == cells[i].solvedY) &&
              !((cells[i].solvedZ == 0 || cells[i].solvedZ == 3) && cells[i].currentZ == cells[i].solvedZ)) {
              
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
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
          // special case - add directly to solve sequence
          println("A");
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
        }
        else if (swapCellX == 3) { // B face
          println("B");
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 3) { // C face
          // special case - add directly to solve sequence
          println("C");
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
        else if (swapCellX == 0) { // D face
          println("D");
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
          println("E");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 3) { // F face
          println("F");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellY == 3) { // G face
          println("G");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 0) { // H face
          println("H");
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
          // special case - add directly to solve sequence
          println("I");
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
          solveTurnSequence.add(new TurnAnimation('D', -1)); // D
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
        }
        else if (swapCellX == 3) { // J face
          println("J");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellY == 3) { // K face
          println("K");
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
        else if (swapCellX == 0) { // L face
          println("L");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
          println("M");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 0) { // N face
          println("N");
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellY == 3) { // O face
          println("O");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 3) { // P face
          println("P");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
          // special case - add directly to solve sequence
          println("Q");
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
        else if (swapCellX == 0) { // R face
          println("R");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
        else if (swapCellY == 3) { // S face
          // special case - add directly to solve sequence
          println("S");
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
        else if (swapCellX == 3) { // T face
          println("T");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 3) { // U face
          println("U");
          isBuffer = true;
        }
        else if (swapCellX == 3) { // V face
          println("V");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 0) { // W face
          // special case - add directly to solve sequence
          println("W");
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
        else if (swapCellX == 0) { // X face
          println("X");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved or flipped piece
      if (isBuffer) {
        // first edge is at index 1 and last is at cells.length - 1
        for (int i = 1; i < cells.length - 1; i++) {
          // only check the edge pieces and don't allow for the new cell to be the buffer
          if (cells[i].coloredFaces.size() == 2 && i != 47) {
            // if the cell is in the incorrect position or flipped
            if (!cells[i].isSolved()) {
              swapCellX = cells[i].currentX;
              swapCellY = cells[i].currentY;
              swapCellZ = cells[i].currentZ;
              
              
              // NEED TO CHOOSE THE FACE THAT IS FURTHEST CLOCKWISE
              
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
}
