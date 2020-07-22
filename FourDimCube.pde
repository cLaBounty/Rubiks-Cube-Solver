class FourDimCube extends Cube {
  /*
    * Phase 1: Solved all center pieces with U2 method
    * Phase 2: Solve all wing pieces with r2 method
    * Phase 3: Solve all corner pieces with Modified Y Perm Algorithm
  */
  private int solvePhase;
  
  // counter's to determine if parity after centers, wings, and corners
  private int centerSwapCount;
  private int wingSwapCount;
  private int cornerSwapCount;
  
  // custom constructor
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
  
  // member functions
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
      if (!areCornersSolved()) {
        solveCorner();
        cornerSwapCount++;
      }
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
  
  /*
    On a 2x2 and 3x3 cube, there is only one correct location where a cell can be solved.
    On a 4x4 cube, there is more than one location where a cell can be solved because the faces on some cells are identical.
    This only checks to see if all faces are corrently positioned since the inital solved locations are irrelevant.
  */
  @Override
  protected boolean isSolved() {
    // if any faces are not facing the corrent direction, then the cube is not solved
    for (Cell c : cells) {
      if (c.getColoredFaces().size() > 0) { // disregard the cells in the middle of the cube
        if (c.isWrongDirection())
          return false;
      }
    }
    
    return true;
  }

  private boolean areCentersSolved() {
    // loop through all center pieces to see if any are in an incorrect position
    for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
      // only check if the center pieces are unsolved
      if (cells[i].getColoredFaces().size() == 1) {
        if ((cells[i].getCurrentX() != cells[i].getSolvedX() && (cells[i].getSolvedX() == 0 || cells[i].getSolvedX() == 3)) ||
          (cells[i].getCurrentY() != cells[i].getSolvedY() && (cells[i].getSolvedY() == 0 || cells[i].getSolvedY() == 3)) ||
          (cells[i].getCurrentZ() != cells[i].getSolvedZ() && (cells[i].getSolvedZ() == 0 || cells[i].getSolvedZ() == 3)))
            return false;
      }
    }
    
    return true;
  }
  
  private boolean areWingsFixed() {
    // if NOT parity, then all should be solved
    if (wingSwapCount % 2 == 0) {
      // loop through all wing pieces to see if any are in the incorrect position or flipped
      for (Cell c : cells) {
        // only check the wing pieces
        if (c.getColoredFaces().size() == 2) {
          // if the cell is in the incorrect position or flipped
          if ((c.getCurrentX() != c.getSolvedX() && (c.getSolvedX() == 0 || c.getSolvedX() == 3)) ||
            (c.getCurrentY() != c.getSolvedY() && (c.getSolvedY() == 0 || c.getSolvedY() == 3)) ||
            (c.getCurrentZ() != c.getSolvedZ() && (c.getSolvedZ() == 0 || c.getSolvedZ() == 3)) || c.isWrongDirection())
              return false;
        }
      }
    }
    else { // if parity, then the cells in the r slice at index 19, 28, 35 or 44 should be opposite, rather than solved
      int index = 0;
      for (Cell c : cells) {
        // only check the wing pieces
        if (c.getColoredFaces().size() == 2) {
          if ((index == 19 || index == 28 || index == 35 || index == 44) && c.getCurrentX() == 2) {
            if (((c.getCurrentX() == c.getSolvedX() || c.getSolvedX() == 1 || c.getSolvedX() == 2) &&
              (c.getCurrentY() == c.getSolvedY() || c.getSolvedY() == 1 || c.getSolvedY() == 2) &&
              (c.getCurrentZ() == c.getSolvedZ() || c.getSolvedZ() == 1 || c.getSolvedZ() == 2) && !c.isWrongDirection()) || !c.isOppositeDirection())
                return false;
          }
          else {
            if ((c.getCurrentX() != c.getSolvedX() && (c.getSolvedX() == 0 || c.getSolvedX() == 3)) ||
              (c.getCurrentY() != c.getSolvedY() && (c.getSolvedY() == 0 || c.getSolvedY() == 3)) ||
              (c.getCurrentZ() != c.getSolvedZ() && (c.getSolvedZ() == 0 || c.getSolvedZ() == 3)) || c.isWrongDirection())
                return false;
          }
        }
        index++;
      }
    }
    
    return true;
  }
  
  private boolean areCornersSolved() {
    for (Cell c : cells) {
      // only check the corner pieces
      if (c.getColoredFaces().size() == 3 && !c.isSolved())
        return false;
    }
    
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

    for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
      if (cells[i].getCurrentX() == 1 && cells[i].getCurrentY() == 0 && cells[i].getCurrentZ() == 1) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the face color of the buffer cell
    color bufferColor = cells[bufferIndex].getColoredFace(0).col;
    
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
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentY() == swapCellY) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #FFFFFF) {
              if ((cells[i].getCurrentX() == 2 && cells[i].getCurrentZ() == 1 && centerSwapCount % 2 == 1) || // B Face and 1st in pair
                (cells[i].getCurrentX() == 1 && cells[i].getCurrentZ() == 2 && centerSwapCount % 2 == 0)) { // D Face and 2nd in pair
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
              else if (cells[i].getCurrentX() == 2 && cells[i].getCurrentZ() == 2) { // C Face
                // special case - add directly to solve sequence
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                return setUpSequence; // no need to search further  
              }
              else if ((cells[i].getCurrentX() == 1 && cells[i].getCurrentZ() == 2 && centerSwapCount % 2 == 1) || // D Face and 1st in pair
                (cells[i].getCurrentX() == 2 && cells[i].getCurrentZ() == 1 && centerSwapCount % 2 == 0)) { // B Face and 2nd in pair
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
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentX() == swapCellX) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #FF8D1A) {
              if (cells[i].getCurrentY() == 1) {
                if (cells[i].getCurrentZ() == 1) { // E Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].getCurrentZ() == 2) { // F Face
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].getCurrentY() == 2) {
                if (cells[i].getCurrentZ() == 2) { // G Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].getCurrentZ() == 1) { // H Face
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
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentZ() == swapCellZ) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #00FF00) {
              if (cells[i].getCurrentY() == 1) {
                if (cells[i].getCurrentX() == 1) { // I Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].getCurrentX() == 2) { // J Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].getCurrentY() == 2) {
                if (cells[i].getCurrentX() == 2) { // K Face
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].getCurrentX() == 1) { // L Face
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
      else if (swapCellX == 3) {
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentX() == swapCellX) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #FF0000) {
              if (cells[i].getCurrentY() == 1) {
                if (cells[i].getCurrentZ() == 2) { // M Face
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].getCurrentZ() == 1) { // N Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].getCurrentY() == 2) {
                if (cells[i].getCurrentZ() == 1) { // O Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].getCurrentZ() == 2) { // P Face
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
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentZ() == swapCellZ) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #0000FF) {
              if (cells[i].getCurrentY() == 1) {
                if (cells[i].getCurrentX() == 2) { // Q Face
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].getCurrentX() == 1) { // R Face
                  setUpSequence.add(new TurnAnimation('f', -1)); // f'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].getCurrentY() == 2) {
                if (cells[i].getCurrentX() == 1) { // S Face
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].getCurrentX() == 2) { // T Face
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
        for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
          // only check the center pieces on the side that is being swapped with
          if (cells[i].getColoredFaces().size() == 1 && cells[i].getCurrentY() == swapCellY) {
            // only swap with a cell that is not already solved
            if (cells[i].getColoredFace(0).getColor() != #FFFF00) {
              // special case - add directly to solve sequence
              if (cells[i].getCurrentX() == 1 && cells[i].getCurrentZ() == 2) { // U Face
                solveTurnSequence.add(new TurnAnimation('D', -1)); // D
              }
              else if (cells[i].getCurrentZ() == 1) {
                if (cells[i].getCurrentX() == 2) { // W Face
                  solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
                }
                else if (cells[i].getCurrentX() == 1) { // X Face
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
              if (cells[i].getCurrentX() == 1 && cells[i].getCurrentZ() == 2) { // U Face
                solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
              }
              else if (cells[i].getCurrentZ() == 1) {
                if (cells[i].getCurrentX() == 2) { // W Face
                  solveTurnSequence.add(new TurnAnimation('D', -1)); // D
                }
                else if (cells[i].getCurrentX() == 1) { // X Face
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
      for (int i = 5; i < cells.length-5; i++) { // the first center is at index 5 and the last is the 6th to last in the array
        // only check the center pieces that are are unsolved
        if (cells[i].getColoredFaces().size() == 1) {
          if ((cells[i].getCurrentX() != cells[i].getSolvedX() && (cells[i].getSolvedX() == 0 || cells[i].getSolvedX() == 3)) ||
            (cells[i].getCurrentY() != cells[i].getSolvedY() && (cells[i].getSolvedY() == 0 || cells[i].getSolvedY() == 3)) ||
            (cells[i].getCurrentZ() != cells[i].getSolvedZ() && (cells[i].getSolvedZ() == 0 || cells[i].getSolvedZ() == 3))) {
              swapCellX = cells[i].getCurrentX();
              swapCellY = cells[i].getCurrentY();
              swapCellZ = cells[i].getCurrentZ();
              break;
          }
        }
      }
    } while (true); // repeat to get the setup moves for the new swap cell
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

    for (int i = 1; i < cells.length-1; i++) { // first wing is at index 1 and the last is the 2nd to last in the array
      if (cells[i].getCurrentX() == 2 && cells[i].getCurrentY() == 3 && cells[i].getCurrentZ() == 3) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the down and front face color of the buffer cell
    color bufferDownColor = #FFFFFF;
    color bufferFrontColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].getColoredFaces()) {
      if (f.getCurrentDir().y == 1) // down face
         bufferDownColor = f.col;
      else if (f.getCurrentDir().z == 1) // front face
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
    
    // increment the wing swap counter
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
      If the face chosen is not the furthest clockwise, then the other face will be chosen.
    */
    boolean wrongSide;
    
    // index of the new swap cell when it is also the buffer
    int swapCellIndex = -1;
    
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
      wrongSide = true;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0 && (swapCellX == -1 || swapCellX == 2)) { // A face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          solveTurnSequence.add(new TurnAnimation('r', -1)); // r'
          wrongSide = false;
        }
        else if (swapCellX == 3 && (swapCellZ == -1 || swapCellZ == 2)) { // B face
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          wrongSide = false;
        }
        else if (swapCellZ == 3 && (swapCellX == -1 || swapCellX == 1)) { // C face
          setUpSequence.add(new TurnAnimation('l', 1)); // l'
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellX == 0 && (swapCellZ == -1 || swapCellZ == 1)) { // D face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          wrongSide = false;
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0 && (swapCellZ == -1 || swapCellZ == 2)) { // E face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          wrongSide = false;
        }
        else if (swapCellZ == 3 && (swapCellY == -1 || swapCellY == 2)) { // F face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          wrongSide = false;
        }
        else if (swapCellY == 3 && (swapCellZ == -1 || swapCellZ == 1)) { // G face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          wrongSide = false;
        }
        else if (swapCellZ == 0 && (swapCellY == -1 || swapCellY == 1)) { // H face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          wrongSide = false;
        }
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0 && (swapCellX == -1 || swapCellX == 2)) { // I face
          // special case - add directly to solve sequence
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
          wrongSide = false;
        }
        else if (swapCellX == 3 && (swapCellY == -1 || swapCellY == 2)) { // J face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          wrongSide = false;
        }
        else if (swapCellY == 3 && (swapCellX == -1 || swapCellX == 1)) { // K face
          setUpSequence.add(new TurnAnimation('l', -1)); // l
          setUpSequence.add(new TurnAnimation('l', -1)); // l
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellX == 0 && (swapCellY == -1 || swapCellY == 1)) { // L face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          wrongSide = false;
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0 && (swapCellZ == -1 || swapCellZ == 1)) { // M face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellZ == 0 && (swapCellY == -1 || swapCellY == 2)) { // N face
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellY == 3 && (swapCellZ == -1 || swapCellZ == 2)) { // O face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellZ == 3 && (swapCellY == -1 || swapCellY == 1)) { // P face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0 && (swapCellX == -1 || swapCellX == 1)) { // Q face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellX == 0 && (swapCellY == -1 || swapCellY == 2)) { // R face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          wrongSide = false;
        }
        else if (swapCellY == 3 && (swapCellX == -1 || swapCellX == 2)) { // S face
          // special case - add directly to solve sequence
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
          wrongSide = false;
        }
        else if (swapCellX == 3 && (swapCellY == -1 || swapCellY == 1)) { // T face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          wrongSide = false;
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 3 && swapCellX == -1) { // U face
          isBuffer = true;
        }
        else if (swapCellX == 3 && (swapCellZ == -1 || swapCellZ == 1)) { // V face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          wrongSide = false;
        }
        else if (swapCellZ == 0 && (swapCellX == -1 || swapCellX == 1)) { // W face
          setUpSequence.add(new TurnAnimation('l', -1)); // l
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          wrongSide = false;
        }
        else if (swapCellX == 0 && (swapCellZ == -1 || swapCellZ == 2)) { // X face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          wrongSide = false;
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        boolean foundNewSwapCell = false;
        
        int index = 0;
        for (Cell c : cells) {
          // only check the wing pieces and don't allow for the new cell to be the buffer or the target
          if (c.getColoredFaces().size() == 2 && index != 16 && index != 31 && index != 32 && index != 47) {
            // if the swap cell is not in r slice or the r slice is correctly oriented, then swap with any cell
            if (wingSwapCount % 2 == 1 || c.getCurrentX() != 2) {
              if ((c.getCurrentX() != c.getSolvedX() && (c.getSolvedX() == 0 || c.getSolvedX() == 3)) ||
                (c.getCurrentY() != c.getSolvedY() && (c.getSolvedY() == 0 || c.getSolvedY() == 3)) ||
                (c.getCurrentZ() != c.getSolvedZ() && (c.getSolvedZ() == 0 || c.getSolvedZ() == 3)) || c.isWrongDirection()) {
                  foundNewSwapCell = true;
                  swapCellIndex = index;
                  break;
              }
            }
            else { // if the swap cell is in the r slice and the r slice is off, then it won't be in it's solved location
              // chose a cell that is not in the corresponding solved location with a flipped r slice
              if (abs(c.getSolvedY() - c.getCurrentY()) != 3 || abs(c.getSolvedZ() - c.getCurrentZ()) != 3 || !c.isOppositeDirection()) {
                foundNewSwapCell = true;
                swapCellIndex = index;
                break;
              }
            }
          }
          index++;
        }
        
        // if a new swap cell was found, then swap with it
        if (foundNewSwapCell) {
          swapCellX = cells[swapCellIndex].getCurrentX();
          swapCellY = cells[swapCellIndex].getCurrentY();
          swapCellZ = cells[swapCellIndex].getCurrentZ();
          
          swapCellDir.x = cells[swapCellIndex].getColoredFace(0).getCurrentDir().x;
          swapCellDir.y = cells[swapCellIndex].getColoredFace(0).getCurrentDir().y;
          swapCellDir.z = cells[swapCellIndex].getColoredFace(0).getCurrentDir().z;
        }
        else { // when only the target and buffer are left to be solved
          // swap to Q so that it will not loop continuously
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          
          return setUpSequence;
        }
      }
      // if the wrong side is chosen when the swap cell is also the buffer
      else if (wrongSide) {
        swapCellDir.x = cells[swapCellIndex].getColoredFace(1).getCurrentDir().x;
        swapCellDir.y = cells[swapCellIndex].getColoredFace(1).getCurrentDir().y;
        swapCellDir.z = cells[swapCellIndex].getColoredFace(1).getCurrentDir().z;
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
