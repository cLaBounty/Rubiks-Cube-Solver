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
      /*
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
      */
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
    
    // increment the edge swap counter
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
      if all white centers are solved, a new cell is never found.
      If this happens, find any unsolved piece and swap with it
    */
    do {
      if (swapCellY == 0) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentY == swapCellY) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #FFFFFF) {
              if (cells[i].currentZ == 1 && cells[i].currentX == 2) { // B Face
                // special case - add directly to solve sequence
                // if 2nd in the pair, then swap with D instead
                if (centerSwapCount % 2 == 1) {
                  // B Face
                  println("B");
                  
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
                  
                }
                else {
                  // D Face
                  println("D");
                  
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
                  
                }
                
                return setUpSequence; // no need to search further
              }
              else if (cells[i].currentZ == 2) {
                if (cells[i].currentX == 2) { // C Face
                  // special case - add directly to solve sequence
                  println("C");
                  
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  solveTurnSequence.add(new TurnAnimation('U', 1)); // U
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentX == 1) { // D Face
                  // special case - add directly to solve sequence
                  // if 2nd in the pair, then swap with B instead
                  if (centerSwapCount % 2 == 1) {
                    // D Face
                    println("D");
                    
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
                    
                  }
                  else {
                    // B Face
                    println("B");
                    
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
                    
                  }
                  
                  return setUpSequence; // no need to search further
                }
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
                  println("E");
                  
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentZ == 2) { // F Face
                  println("F");
                  
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentZ == 2) { // G Face
                  println("G");
                  
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentZ == 1) { // H Face
                  println("H");
                  
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  
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
                  println("I");
                  
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentX == 2) { // J Face
                  println("J");
                  
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentX == 2) { // K Face
                  println("K");
                  
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentX == 1) { // L Face
                  println("L");
                  
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
                  println("M");
                  
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentZ == 1) { // N Face
                  println("N");
                  
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentZ == 1) { // O Face
                  println("O");
                  
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentZ == 2) { // P Face
                  println("P");
                  
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
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
      else if (swapCellZ == 0) {
        for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
          // only check the center pieces on the side that is being swapped with
          if (cells[i].coloredFaces.size() == 1 && cells[i].currentZ == swapCellZ) {
            // only swap with a cell that is not already solved
            if (cells[i].coloredFaces.get(0).col != #0000FF) {
              if (cells[i].currentY == 1) {
                if (cells[i].currentX == 2) { // Q Face
                  println("Q");
                  
                  setUpSequence.add(new TurnAnimation('u', 1)); // u
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                
                  return setUpSequence; // no need to search further
                }
                else if (cells[i].currentX == 1) { // R Face
                  println("R");
                  
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  setUpSequence.add(new TurnAnimation('u', -1)); // u'
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'                  
                  
                  return setUpSequence; // no need to search further
                }
              }
              else if (cells[i].currentY == 2) {
                if (cells[i].currentX == 1) { // S Face
                  println("S");
                  
                  setUpSequence.add(new TurnAnimation('r', -1)); // r'
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('d', -1)); // d
                  setUpSequence.add(new TurnAnimation('r', 1)); // r
                  
                  return setUpSequence; // no need to search further  
                }
                else if (cells[i].currentX == 2) { // T Face
                  println("T");
                  
                  setUpSequence.add(new TurnAnimation('f', 1)); // f // r when y'
                  setUpSequence.add(new TurnAnimation('d', 1)); // d'
                  setUpSequence.add(new TurnAnimation('f', -1)); // f' // r' when y'
                  
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
              ArrayList<TurnAnimation> specialSetupSequence  = new ArrayList<TurnAnimation>();
              
              if (cells[i].currentZ == 2) {
                if (cells[i].currentX == 1) { // U Face
                  println("U");
                  
                  specialSetupSequence.add(new TurnAnimation('D', -1)); // D
                }
                else if (cells[i].currentX == 2) { // V Face
                  println("V");
                  
                // nothing
                }
              }
              else if (cells[i].currentZ == 1) {
                if (cells[i].currentX == 2) { // W Face
                  println("W");
                  
                  specialSetupSequence.add(new TurnAnimation('D', 1)); // D'
                }
                else if (cells[i].currentX == 1) { // X Face
                  println("X");
                  
                  specialSetupSequence.add(new TurnAnimation('D', -1)); // D
                  specialSetupSequence.add(new TurnAnimation('D', -1)); // D
                }
              }
              
              solveTurnSequence.addAll(specialSetupSequence);
            
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
              
              
              for (int j = specialSetupSequence.size() - 1; j >= 0; j--) {
                char notationBase = specialSetupSequence.get(j).getNotationBase();
                int invertedDirValue = specialSetupSequence.get(j).getDirValue() * -1;
                solveTurnSequence.add(new TurnAnimation(notationBase, invertedDirValue));
              }
              
              return setUpSequence; // no need to search further
            }
          }
        }
      }
      
      // if no cell was found, pick any unsolved piece
      for (int i = 5; i < (cells.length - 5); i++) { // first center is at index 5 and last is at cells.length - 5
        // only check if the center pieces are unsolved
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
    } while (true);
  }
  
  private void addCenterParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1) // U
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
  
  
  
}
