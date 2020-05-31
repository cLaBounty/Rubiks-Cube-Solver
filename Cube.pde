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
  
  ArrayList<TurnAnimation> scrambleTurnSequence;
  ArrayList<TurnAnimation> solveTurnSequence;
  
  // constructor
  Cube(int dim) {
    this.dim = dim;
    cellLength = CUBE_LENGTH / dim;
    cells = new Cell[int(pow(dim, 3))];
    turnOffset = (3 - dim) / 2.0;
    scrambleTurnNum = 10 * dim;
    
    scrambleTurnSequence = new ArrayList<TurnAnimation>(scrambleTurnNum);
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
          turn = scrambleTurnSequence.get(turnCount);
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
    
    // reset sequence
    scrambleTurnSequence.removeAll(scrambleTurnSequence);
    turnCount = 0;

    // get the set amount of random turns and store in array list
    for (int i = 0; i < scrambleTurnNum; i++)
      scrambleTurnSequence.add(getRandomTurn());    
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
    retVal = new TurnAnimation(allTurnBases[randAxis][randBase], allDir[randDir], turnSpeed);
    
    return retVal;
  }
  
  private boolean isSolved() {
    // if any cell is not in it's solved location, then the cube is not solved
    for (Cell c : cells) {
      if ((c.currentX != c.solvedX) || (c.currentY != c.solvedY) || (c.currentZ != c.solvedZ)) {
         return false;
      }
    }
    isSolving = false;
    return true;
  }
  
  public void solve() {
    isSolving = true;
    turnSpeed = 1;
        
    // reset sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
  }
 //<>//
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
  Phase 3: Align all edge pieces
  */
  int solvePhase = 1;
  
  
  int edgeSwapCount = 0;
  int lastUnsolvedIndex = -1; // might not need
  
  private void setNextTurns() {
    
    if (solvePhase == 1) {
      alignWhiteCenter();
      
      // next phase
      solvePhase++;
      return;
    }
    else if (solvePhase == 2) {
      alignGreenCenter();
      
      // next phase
      solvePhase++;
      return;
    }
    else if (solvePhase == 3) {
      solveEdges();
      
      // next phase
      //solvePhase++; // ONLY when complete
      //return;
    }
    
    // do this once at end of solving edges
    if (edgeSwapCount % 2 == 1) {
        //solveTurnSequence.addAll(Arrays.asList(PARITY_ALGO));
    }
    
///////////////////////////////////////////////////////////////////////////    

    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', -1, turnSpeed), // F'
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', 1, turnSpeed), // F
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', -1, turnSpeed) // U'
    };
    
    // Modified Y Perm Algorithm
    final TurnAnimation[] MOD_Y_PERM_ALG = {
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', -1, turnSpeed), // F'
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', 1, turnSpeed), // F
      new TurnAnimation('R', 1, turnSpeed) // R
    };
    //solveTurnSequence.addAll(Arrays.asList(T_PERM_ALGO));
    //solveTurnSequence.addAll(Arrays.asList(PARITY_ALGO));
    //solveTurnSequence.addAll(Arrays.asList(MOD_Y_PERM_ALGO));
  }
  
  // align white center cell
  void alignWhiteCenter() {
    if (cells[10].currentY != 0) { // already solved
         if (cells[10].currentX == 1) {
           if (cells[10].currentZ == 0)
             solveTurnSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
           else if (cells[10].currentZ == 2)
             solveTurnSequence.add(new TurnAnimation('M', 1, turnSpeed)); // M'
           else {
             solveTurnSequence.add(new TurnAnimation('M', 1, turnSpeed)); // M'
             solveTurnSequence.add(new TurnAnimation('M', 1, turnSpeed)); // M'
           }
         }
         else if (cells[10].currentX == 0)
           solveTurnSequence.add(new TurnAnimation('S', 1, turnSpeed)); // S
         else // currentX == 2
           solveTurnSequence.add(new TurnAnimation('S', -1, turnSpeed)); // S'
    }
  }
  
  // align green center cell
  void alignGreenCenter() {
    if (cells[14].currentZ != 2) { // already solved
          if (cells[14].currentX == 0)
            solveTurnSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
          else if (cells[14].currentX == 2)
            solveTurnSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
          else {
            solveTurnSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
            solveTurnSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
          }
    }
  }
  
  void solveEdges() {
    // T Perm Algorithm
    final TurnAnimation[] T_PERM_ALG = {
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', 1, turnSpeed), // F
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('U', -1, turnSpeed), // U'
      new TurnAnimation('R', 1, turnSpeed), // R
      new TurnAnimation('U', 1, turnSpeed), // U
      new TurnAnimation('R', -1, turnSpeed), // R'
      new TurnAnimation('F', -1, turnSpeed) // F'
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
    
    // find where buffer needs to go
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





    //////////////////////////////////////////////////////////////////////////////////
    
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
     boolean rareCase = false;
    // choose the setup moves
    do {

    if (swapCellDir.y == -1) {
      if (swapCellZ == 0) {
         // A
         println("A");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 2) {
        // B
        println("B");
        rareCase = true;
      }
      else if (swapCellZ == 2) {
         // C
         println("C");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 0) {
         // D
         println("D");
         rareCase = true;
      }
    }
    else if (swapCellDir.x == -1) {
      if (swapCellY == 0) {
         // E
         println("E");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellZ == 2) {
         // F
         println("F");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellY == 2) {
         // G
         println("G");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellZ == 0) {
         // H
         println("H");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }      
    }
    else if (swapCellDir.z == 1) {
      if (swapCellY == 0) {
         // I
         println("I");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 2) {
         // J
         println("J");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellY == 2) {
         // K
         println("K");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
         setUpSequence.add(new TurnAnimation('M', -1, turnSpeed)); // M
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 0) {
         // L
         println("L");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
    }
    else if (swapCellDir.x == 1) {
      if (swapCellY == 0) {
        // M
        println("M");
        rareCase = true;
      }
      else if (swapCellZ == 0) {
         // N
         println("N");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellY == 2) {
         // O
         println("O");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellZ == 2) {
         // P
         println("P");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('E', 1, turnSpeed)); // E'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
    }
    else if (swapCellDir.z == -1) {
      if (swapCellY == 0) {
         // Q
         println("Q");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('M', 1, turnSpeed)); // M'
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 0) {
         // R
         println("R");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', -1, turnSpeed)); // L
      }
      else if (swapCellY == 2) {
         // S
         println("S");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('M', 1, turnSpeed)); // M'
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 2) {
         // T
         println("T");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('E', -1, turnSpeed)); // E
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
    }
    else { // swapCellDir.y == 1
      if (swapCellZ == 2) {
         // U
         println("U");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', 1, turnSpeed)); // D'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 2) {
         // V
         println("V");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellZ == 0) {
         // W
         println("W");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('D', -1, turnSpeed)); // D
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
      else if (swapCellX == 0) {
         // X
         println("X");
         rareCase = false;
         
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
         setUpSequence.add(new TurnAnimation('L', 1, turnSpeed)); // L'
      }
    }
    
    
    if (rareCase) {
      int temp = lastUnsolvedIndex;

        for (int i = 0; i < cells.length; i++) {
          if (cells[i].coloredFaces.size() == 2) {
            if (cells[i].currentX == cells[i].solvedX && cells[i].currentY == cells[i].solvedY && cells[i].currentZ == cells[i].solvedZ &&
                cells[i].coloredFaces.get(0).dir == cells[i].coloredFaces.get(0).initialDir && cells[i].coloredFaces.get(1).dir == cells[i].coloredFaces.get(1).initialDir) {
                  // cell is solved
            }
            else {
               
              if (i > lastUnsolvedIndex) {
                lastUnsolvedIndex = i;
                 
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;


                if (cells[i].coloredFaces.get(0).dir.y != -1) // not an up face
                  swapCellDir = cells[i].coloredFaces.get(0).dir;
                else 
                  swapCellDir = cells[i].coloredFaces.get(1).dir;
                
                break;
              }
            }
          }
        }
        
        if (temp == lastUnsolvedIndex) {
          print("Broken");
          lastUnsolvedIndex = -1;
        }
      }

    } while (rareCase);
    
    // figure out when complete // should be at top
    
    boolean edgesSolved = true;
    
    for (Cell c : cells) {
      if (c.coloredFaces.size() == 2) {
        if (c.currentX != c.solvedX || c.currentY != c.solvedY || c.currentZ != c.solvedZ) {
          edgesSolved = false;
          break;
        }
      }
    }
    
    
    if (edgesSolved) {
      for (Cell c : cells) {
        if (c.coloredFaces.size() == 2) {
          if ((c.coloredFaces.get(0).dir.x == c.coloredFaces.get(0).initialDir.x) && (c.coloredFaces.get(0).dir.y == c.coloredFaces.get(0).initialDir.y)) {
            // solved
            println("Solved");
          }
          else {
            // a flip is needed
            println("Flip");
            break;
          }
        }
      }
    }
    
    if (edgesSolved) {
      isSolving = false;
      return; 
    }
    
    edgeSwapCount++;
    
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(T_PERM_ALG));
    
    //reversed setup
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--) {
      reverseSetUpSequence.add(setUpSequence.get(i).invert());
    }
    
    solveTurnSequence.addAll(reverseSetUpSequence);
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
