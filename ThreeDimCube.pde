class ThreeDimCube extends Cube {  
  /*
    * Phase 1: Align white center to top
    * Phase 2: Align green center to front
    * Phase 3: Solve all edge pieces with M2 method
    * Phase 4: Solve all corner pieces with Modified Y Perm Algorithm
  */
  private int solvePhase;
  
  // counter to determine if parity is needed after solving edges
  private int edgeSwapCount;
  
  // custom constructor
  ThreeDimCube() {
    super();
    
    dim = 3;
    cellLength = CUBE_LENGTH / 3;
    cells = new Cell[27];
    turnOffset = 0;
    scrambleTurnNum = 30;
    
    turnXBases = new char[]{'L', 'M', 'R'};
    turnYBases = new char[]{'U', 'E', 'D'};
    turnZBases = new char[]{'B', 'S', 'F'};
    
    solvePhase = 1;
    edgeSwapCount = 0;
  }
  
  // member functions
  public void solve() {
    isSolving = true;
        
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
    solvePhase = 1;
    edgeSwapCount = 0;
  }
  
  protected void setNextTurns() {
    if (solvePhase == 1) {
      alignWhiteCenter();
      
      // next phase
      solvePhase++;
    }
    else if (solvePhase == 2) {
      alignGreenCenter();
      
      // next phase
      solvePhase++;
    }
    else if (solvePhase == 3) {
      if (!areEdgesFixed())
        solveEdge();
      else {
        // Parity Algorithm (only if an odd # of edges were moved)
        if (edgeSwapCount % 2 == 1)
          addParityAlgorithm();
        
        // next phase
        solvePhase++;
      }
    }
    else if (solvePhase == 4) {
      if (!isSolved())
        solveCorner();
      else
        isSolving = false;
    }
  }
  
  // align the white center cell to the top
  private void alignWhiteCenter() {
    if (cells[10].getCurrentY() != 0) { // do nothing if already solved
      if (cells[10].getCurrentX() == 1) {
        if (cells[10].getCurrentZ() == 0)
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        else if (cells[10].getCurrentZ() == 2)
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        else {
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        }
      }
      else if (cells[10].getCurrentX() == 0)
        solveTurnSequence.add(new TurnAnimation('S', 1)); // S
      else if (cells[10].getCurrentX() == 2)
        solveTurnSequence.add(new TurnAnimation('S', -1)); // S'
    }
  }
  
  // align the green center cell to the front
  private void alignGreenCenter() {
    if (cells[14].getCurrentZ() != 2) { // do nothing if already solved
      if (cells[14].getCurrentX() == 0)
        solveTurnSequence.add(new TurnAnimation('E', -1)); // E
      else if (cells[14].getCurrentX() == 2)
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      else if (cells[14].getCurrentX() == 1){
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      }
    }
  }
  
  private boolean areEdgesFixed() {
    // if NOT parity, then all edges should be solved
    if (edgeSwapCount % 2 == 0) {
      // loop through all edge pieces to see if any are unsolved
      for (int i = 1; i < cells.length-1; i++) { // first edge is at index 1 and the last is the 2nd to last in the array
        // only check the edge pieces
        if (cells[i].getColoredFaces().size() == 2) {
          if (!cells[i].isSolved())
            return false;
        }
      }
    }
    else { // if parity, then the cells at index 11 and 15 should be opposite, rather than solved
      for (int i = 1; i < cells.length-1; i++) {
        if (cells[i].getColoredFaces().size() == 2) {
          if (i != 11 && i != 15) {
            if (!cells[i].isSolved())
              return false;
          }
          else {
            if (cells[i].isSolved() || !cells[i].isOppositeDirection())
              return false;
          }
        }
      }
    }
    
    return true;
  }
  
  private void solveEdge() {
    // M2 Swap Algorithm
    final TurnAnimation[] M2_SWAP_ALG = {
      new TurnAnimation('M', 1), // M'
      new TurnAnimation('M', 1) // M'
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 1; i < cells.length-1; i++) { // first edge is at index 1 and the last is the 2nd to last in the array
      if (cells[i].getCurrentX() == 1 && cells[i].getCurrentY() == 2 && cells[i].getCurrentZ() == 2) {
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
    int swapCellX = 1;
    int swapCellY = 1;
    int swapCellZ = 1;

    if (bufferDownColor == #FF8D1A || bufferFrontColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferDownColor == #FF0000 || bufferFrontColor == #FF0000)
      swapCellX = 2;
    
    if (bufferDownColor == #FFFFFF || bufferFrontColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferDownColor == #FFFF00 || bufferFrontColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferDownColor == #0000FF || bufferFrontColor == #0000FF)
      swapCellZ = 0;
    else if (bufferDownColor == #00FF00 || bufferFrontColor == #00FF00)
      swapCellZ = 2;
    
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
    edgeSwapCount++;
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getEdgeSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // if no setup moves are needed or a special case, then do nothing
    if (setUpSequence.size() != 0) {
      // reverse the setup moves to put it back in it's original position
      ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
      for (int i = setUpSequence.size() - 1; i >= 0; i--) {
        char notationBase = setUpSequence.get(i).getNotationBase();
        int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
        reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
      }
      
      // add all turns to the solve sequence
      solveTurnSequence.addAll(setUpSequence);
      solveTurnSequence.addAll(Arrays.asList(M2_SWAP_ALG));
      solveTurnSequence.addAll(reverseSetUpSequence);
    }
  }
  
  private ArrayList<TurnAnimation> getEdgeSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    // swap to the opposite M slice face when it is the 2nd letter of a pair
    if (edgeSwapCount % 2 == 0) {
      if (swapCellDir.y == -1 && swapCellZ == 2) { // C face to W Face
        swapCellDir.y = 1;
        swapCellY = 2;
        swapCellZ = 0;
      }
      else if (swapCellDir.y == 1 && swapCellZ == 0) { // W face to C Face
        swapCellDir.y = -1;
        swapCellY = 0;
        swapCellZ = 2;
      }
      else if (swapCellDir.z == 1 && swapCellY == 0) { // I Face to S Face
        swapCellDir.z = -1;
        swapCellY = 2;
        swapCellZ = 0;
      }
      else if (swapCellDir.z == -1 && swapCellY == 2) { // S Face to I Face
        swapCellDir.z = 1;
        swapCellY = 0;
        swapCellZ = 2;
      }
    }
    
    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        }
        else if (swapCellX == 2) { // B face
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 2) { // C face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        }
        else if (swapCellX == 0) { // D face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 2) { // F face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellY == 2) { // G face
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 0) { // H face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('D', -1)); // D
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        }
        else if (swapCellX == 2) { // J face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellY == 2) { // K face
          isBuffer = true;
        }
        else if (swapCellX == 0) { // L face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 0) { // N face
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellY == 2) { // O face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 2) { // P face
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellX == 0) { // R face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
        else if (swapCellY == 2) { // S face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('D', -1)); // D
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
        }
        else if (swapCellX == 2) { // T face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 2) { // U face
          isBuffer = true;
        }
        else if (swapCellX == 2) { // V face
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 0) { // W face
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
        }
        else if (swapCellX == 0) { // X face
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        boolean foundNewSwapCell = false;
        
        int index = 0;
        for (Cell c : cells) {
          // only check the edge pieces and don't allow for the new cell to be the buffer or the target
          if (c.getColoredFaces().size() == 2 && index != 9 && index != 17) {
            // if the swap cell is not in M slice or the M slice is correctly oriented, then swap with any cell
            if (edgeSwapCount % 2 == 1 || c.getCurrentX() != 1) {
              if (!c.isSolved()) {
                foundNewSwapCell = true;
                break;
              }
            }           
            else { // if the swap cell is in the M slice and the M slice is off, then it won't be in it's solved location
              // choose a cell that is not in the opposite of its solved location
              if (abs(c.getSolvedY() - c.getCurrentY()) != 2 || abs(c.getSolvedZ() - c.getCurrentZ()) != 2 || !c.isOppositeDirection()) {
                foundNewSwapCell = true;
                break;
              }
            }
          }
          index++;
        }
        
        // if a new swap cell was found, then swap with it
        if (foundNewSwapCell) {
          swapCellX = cells[index].getCurrentX();
          swapCellY = cells[index].getCurrentY();
          swapCellZ = cells[index].getCurrentZ();
          
          swapCellDir.x = cells[index].getColoredFace(0).getCurrentDir().x;
          swapCellDir.y = cells[index].getColoredFace(0).getCurrentDir().y;
          swapCellDir.z = cells[index].getColoredFace(0).getCurrentDir().z;
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
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  private void addParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('D', 1), // D'
      new TurnAnimation('L', -1), // L
      new TurnAnimation('L', -1), // L
      new TurnAnimation('D', -1), // D
      new TurnAnimation('M', -1), // M
      new TurnAnimation('M', -1), // M
      new TurnAnimation('D', 1), // D'
      new TurnAnimation('L', -1), // L
      new TurnAnimation('L', -1), // L
      new TurnAnimation('D', -1) // D
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
}
