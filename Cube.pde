class Cube {  
  private int dim;
  private final float CUBE_LENGTH = 144;
  private float cellLength;
  public Cell [] cells;
  
  private float turnOffset;
  
  public char[] turnXBases;
  public char[] turnYBases;
  public char[] turnZBases;
   
  public TurnAnimation turn = new TurnAnimation();
  
  private int scrambleTurnNum;
  
  int turnSpeed = 1;
  
  int turnCount = 0;
  
  boolean isTurning = false;
  boolean isScrambling = false;
  boolean isSolving = false;
  
  ArrayList<TurnAnimation> solveTurnSequence;
  
  // constructor
  Cube(int dim) {
    this.dim = dim;
    cellLength = CUBE_LENGTH / dim;
    cells = new Cell[int(pow(dim, 3))];
    turnOffset = (3 - dim) / 2.0;
    scrambleTurnNum = 10 * dim;
    
    solveTurnSequence = new ArrayList<TurnAnimation>();
    
    // determine all possible turns based on dimensions of cube
    switch(dim) {
      case 2: {
        turnXBases = new char[]{'L', 'R'};
        turnYBases = new char[]{'U', 'D'};
        turnZBases = new char[]{'B', 'F'};
        break;
      }
      case 3: {
        turnXBases = new char[]{'L', 'M', 'R'};
        turnYBases = new char[]{'U', 'E', 'D'};
        turnZBases = new char[]{'B', 'S', 'F'};
        break;
      }
      case 4: {
        turnXBases = new char[]{'L', 'l', 'r', 'R'};
        turnYBases = new char[]{'U', 'u', 'd', 'D'};
        turnZBases = new char[]{'B', 'b', 'f', 'F'};
        break;
      }
    }
  }
  
  public int getDimensions() { return dim; }

  // member functions
  public void build() {
    // calculate offset for displaying cells
    float cellOffset = ((dim - 1) * cellLength) / 2;
    
    // create a new cell and track position using nested loop
    int index = 0;
    for (int x = 0; x < dim; x++) {
      for (int y = 0; y < dim; y++) {
        for (int z = 0; z < dim; z++) {
          PMatrix3D matrix = new PMatrix3D();
          matrix.translate((cellLength * x) - cellOffset, (cellLength * y) - cellOffset, (cellLength * z) - cellOffset);
          
          cells[index] = new Cell(x, y, z, matrix, dim, cellLength);
          index++;
        }
      }
    }
  }
   
  public void show() {
    for (Cell c : cells) {
      push();
      if (c.currentX == turn.x) {
        rotateX(turn.angle);
      }
      else if (c.currentY == turn.y) {
        rotateY(-turn.angle);
      }
      else if (c.currentZ == turn.z) {
        rotateZ(turn.angle);
      }
      
      c.show();
      pop();  
    } 
  }
   
  public void update() {
    // if cube is being solved or scrambled
    if (isSolving || isScrambling) {
      // if cube is in the middle of a turn
      if (isTurning) {
        turn.update();
      }
      else {
        // if cube is scrambling and has not reached the set amount of turns
        if (isScrambling && turnCount < scrambleTurnNum) {
          turn = getRandomTurn();
          turn.start();
          turnCount++;
        }
        else if (isSolving) {
          if (turnCount > solveTurnSequence.size()-1) {
            setNextTurns();
          }
          else {
            turn = solveTurnSequence.get(turnCount);
            turn.start();
            turnCount++;
          }
        }
        else {
          isSolving = false;
          isScrambling = false;
        }
      }
    }
  }
  
  public void scramble() {
    isScrambling = true;
    turnSpeed = 6;
    
    // reset the turn count
    turnCount = 0; 
  }
    
  private TurnAnimation getRandomTurn() {
    // arrays to hold all turn possibilities
    final int[] allDir = {-1, 1};
    final char[][] allTurnBases = {turnXBases, turnYBases, turnZBases};
    
    // random index values
    int randDir = round(random(1));
    int randAxis = round(random(2));
    int randBase = round(random(turnXBases.length - 1));
    
    // new turn with random base and direction
    TurnAnimation retVal;
    retVal = new TurnAnimation(allTurnBases[randAxis][randBase], allDir[randDir]);
    
    return retVal;
  }
  
  public void solve() {
    isSolving = true;
    turnSpeed = 1;
        
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
  }
  
  private boolean isSolved() {
    // if any cell is not in it's solved location, then the cube is not solved
    for (int i = 0; i < cells.length; i++) {
      if (cells[i].currentX != cells[i].solvedX || cells[i].currentY != cells[i].solvedY || cells[i].currentZ != cells[i].solvedZ ||
          cells[i].coloredFaces.get(0).dir.x != cells[i].coloredFaces.get(0).initialDir.x ||
          cells[i].coloredFaces.get(0).dir.y != cells[i].coloredFaces.get(0).initialDir.y) {
          return false;
      }
    }
    
    isSolving = false;
    return true;
  }

  public void turn() {
    // check each turn posibility
    for (int i = 0; i < turnXBases.length; i++) {
      // check if X turn and if so, which one
      if (i == turn.x) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.currentX == i) {
            float x = (c.currentX - 1) + turnOffset;
            float y = (c.currentY - 1) + turnOffset;
            float z = (c.currentZ - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(turn.dirValue * HALF_PI);
            matrix.translate(y, z);
            
            c.update(x, matrix.m02, matrix.m12, turnOffset);
            c.turnFaces('X', turn.dirValue);
          }
        }
        return; // no need to search further
      }
      // check if Y turn and if so, which one
      else if (i == turn.y) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.currentY == i) {
            float x = (c.currentX - 1) + turnOffset;
            float y = (c.currentY - 1) + turnOffset;
            float z = (c.currentZ - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(turn.dirValue * HALF_PI);
            matrix.translate(x, z);
            
            c.update(matrix.m02, y, matrix.m12, turnOffset);
            c.turnFaces('Y', turn.dirValue);
          }
        }
        return; // no need to search further
      } // check if Z turn and if so, which one
      else if (i == turn.z) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.currentZ == i) {
            float x = (c.currentX - 1) + turnOffset;
            float y = (c.currentY - 1) + turnOffset;
            float z = (c.currentZ - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(turn.dirValue * HALF_PI);
            matrix.translate(x, y);
            
            c.update(matrix.m02, matrix.m12, z, turnOffset);
            c.turnFaces('Z', turn.dirValue);
          }
        }
        return; // no need to search further
      }
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  /*
  Phase 1: Align white center to top
  Phase 2: Align green center to front
  Phase 3: Solve all edge pieces
  Phase 4: Solve all corner pieces
  */
  int solvePhase = 1;
  
  int edgeSwapCount = 0;
  
  private void setNextTurns() {
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
      if (!areEdgesSolved())
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
    }
  }
  
  // align the white center cell
  void alignWhiteCenter() {
    if (cells[10].currentY != 0) { // already solved
      if (cells[10].currentX == 1) {
        if (cells[10].currentZ == 0)
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        else if (cells[10].currentZ == 2)
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        else {
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        }
      }
      else if (cells[10].currentX == 0)
        solveTurnSequence.add(new TurnAnimation('S', 1)); // S
      else // currentX == 2
        solveTurnSequence.add(new TurnAnimation('S', -1)); // S'
    }
  }
  
  // align the green center cell
  void alignGreenCenter() {
    if (cells[14].currentZ != 2) { // already solved
      if (cells[14].currentX == 0)
        solveTurnSequence.add(new TurnAnimation('E', -1)); // E
      else if (cells[14].currentX == 2)
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      else {
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      }
    }
  }
  
  boolean areEdgesSolved() {   
    // loop through all edge pieces to see if any are flipped or in the incorrect position
    for (Cell c : cells) {
      if (c.coloredFaces.size() == 2) {
        if (c.currentX != c.solvedX || c.currentY != c.solvedY || c.currentZ != c.solvedZ ||
            c.coloredFaces.get(0).dir.x != c.coloredFaces.get(0).initialDir.x ||
            c.coloredFaces.get(0).dir.y != c.coloredFaces.get(0).initialDir.y) {
              return false;
        }
      }
    }

    return true;
  }
  
  void solveEdge() {
    // T Perm Algorithm
    final TurnAnimation[] T_PERM_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1), // R
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1) // F'
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 0; i < cells.length; i++) {
      if (cells[i].currentX == 2 && cells[i].currentY == 0 && cells[i].currentZ == 1)
        bufferIndex = i;
    }
    
    // getting the up and right face color of the buffer cell
    color bufferUpColor = #FFFFFF;
    color bufferRightColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == -1) // up face
         bufferUpColor = f.col;
      else if (f.dir.x == 1) // right face
         bufferRightColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = 1;
    int swapCellY = 1;
    int swapCellZ = 1;

    if (bufferUpColor == #FF8D1A || bufferRightColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferUpColor == #FF0000 || bufferRightColor == #FF0000)
      swapCellX = 2;
    
    if (bufferUpColor == #FFFFFF || bufferRightColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferRightColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferUpColor == #0000FF || bufferRightColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferRightColor == #00FF00)
      swapCellZ = 2;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferUpColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferUpColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferUpColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferUpColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferUpColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);

    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getEdgeSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // reversed setup moves to put back in it's original place
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--)
      reverseSetUpSequence.add(setUpSequence.get(i).invert());

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(T_PERM_ALG));
    solveTurnSequence.addAll(reverseSetUpSequence);
    
    // increment the swap counter
    edgeSwapCount++;
  }
  
  
  
  
  
  
  
  
  
  
  void solveCorner() {
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
      if (cells[i].currentX == 0 && cells[i].currentY == 0 && cells[i].currentZ == 0)
        bufferIndex = i;
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
      swapCellX = 2;
    
    if (bufferUpColor == #FFFFFF || bufferLeftColor == #FFFFFF || bufferBackColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferLeftColor == #FFFF00 || bufferBackColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferUpColor == #0000FF || bufferLeftColor == #0000FF || bufferBackColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferLeftColor == #00FF00 || bufferBackColor == #00FF00)
      swapCellZ = 2;
    
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
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getCornerSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // reversed setup moves to put back in it's original place
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--)
      reverseSetUpSequence.add(setUpSequence.get(i).invert());

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(MOD_Y_PERM_ALG)); 
    solveTurnSequence.addAll(reverseSetUpSequence);
  }
  
  
  
  
  
  
  
  ArrayList<TurnAnimation> getCornerSetupMoves (int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
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
          else if (swapCellX == 2) { // B face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
        else if (swapCellZ == 2) {
          if (swapCellX == 2) { // C face           
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
          else if (swapCellZ == 2) { // F face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
        else if (swapCellY == 2) {
          if (swapCellZ == 2) { // G face
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
          else if (swapCellX == 2) { // J face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
        else if (swapCellY == 2) {
          if (swapCellX == 2) { // K face
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
          if (swapCellZ == 2) { // M face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 0) { // N face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
        else if (swapCellY == 2) {
          if (swapCellZ == 0) { // O face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 2) { // P face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) {
          if (swapCellX == 2) { // Q face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // R face
            isBuffer = true;
          }
        }
        else if (swapCellY == 2) {
          if (swapCellX == 0) { // S face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellX == 2) { // T face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellX == 0 && swapCellZ == 2) { // U face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
        }
        else if (swapCellZ == 0) {
          if (swapCellX == 2) { // W face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // X face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        for (int i = 1; i < cells.length; i++) {
          if (cells[i].coloredFaces.size() == 3) {
            if (cells[i].currentX != cells[i].solvedX || cells[i].currentY != cells[i].solvedY || cells[i].currentZ != cells[i].solvedZ ||
                cells[i].coloredFaces.get(0).dir.x != cells[i].coloredFaces.get(0).initialDir.x ||
                cells[i].coloredFaces.get(0).dir.y != cells[i].coloredFaces.get(0).initialDir.y) {
                  
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir = cells[i].coloredFaces.get(0).dir;
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  ArrayList<TurnAnimation> getEdgeSetupMoves (int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;

    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // B face
          isBuffer = true;
        }
        else if (swapCellZ == 2) { // C face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 2) { // F face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // G face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 0) { // H face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // J face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // K face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // L face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
          isBuffer = true;
        }
        else if (swapCellZ == 0) { // N face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // O face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 2) { // P face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('M', 1)); // M'
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // R face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // S face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('M', 1)); // M'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // T face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 2) { // U face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // V face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellZ == 0) { // W face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // X face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        for (int i = 0; i < cells.length; i++) {
          if (cells[i].coloredFaces.size() == 2) {
            if (cells[i].currentX != cells[i].solvedX || cells[i].currentY != cells[i].solvedY || cells[i].currentZ != cells[i].solvedZ ||
                cells[i].coloredFaces.get(0).dir.x != cells[i].coloredFaces.get(0).initialDir.x ||
                cells[i].coloredFaces.get(0).dir.y != cells[i].coloredFaces.get(0).initialDir.y) {
                  
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir = cells[i].coloredFaces.get(0).dir;
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  void addParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1), // F'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1) // U'
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
