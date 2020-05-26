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
  
  // constructor
  Cube(int dim) {
    this.dim = dim;
    cellLength = CUBE_LENGTH / dim;
    cells = new Cell[int(pow(dim, 3))];
    turnOffset = (3 - dim) / 2.0;
    scrambleTurnNum = 10 * dim;
    
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
        if (isScrambling && turnCount < scrambleTurnNum) {
          turn = getRandomTurn();
          turnCount++;
        }
        else if (isSolving && !isSolved()) {
          turn = getNextTurn();
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
    turn = getRandomTurn();
    turnCount = 1;
  }
    
  private TurnAnimation getRandomTurn() {
    // arrays to hold all turn possibilities
    int[] allDir = {-1, 1};
    char[][] allTurnBases = {turnXBases, turnYBases, turnZBases};
    
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
    // if any cell is not is it's solved location, then the cube is not solved
    for (Cell c : cells) {
      if ((c.currentX != c.solvedX) || (c.currentY != c.solvedY) || (c.currentZ != c.solvedZ)) {
         return false;
      }
    } 
    
    return true;
  }
  
  public void solve() {
    isSolving = true;
    turnSpeed = 1;
    turn = getNextTurn();
  }
  
  private TurnAnimation getNextTurn() {
    
    /*
    // X
    new TurnAnimation('L', -1, turnSpeed); // L
    new TurnAnimation('L', 1, turnSpeed); // L'
    new TurnAnimation('l', -1, turnSpeed); // l
    new TurnAnimation('l', 1, turnSpeed); // l'
    new TurnAnimation('M', -1, turnSpeed); // M
    new TurnAnimation('M', 1, turnSpeed); // M'
    new TurnAnimation('r', 1, turnSpeed); // r
    new TurnAnimation('r', -1, turnSpeed); // r'
    new TurnAnimation('R', 1, turnSpeed); // R
    new TurnAnimation('R', -1, turnSpeed); // R'

    // Y
    new TurnAnimation('U', 1, turnSpeed); // U
    new TurnAnimation('U', -1, turnSpeed); // U'
    new TurnAnimation('u', 1, turnSpeed); // u
    new TurnAnimation('u', -1, turnSpeed); // u'
    new TurnAnimation('E', -1, turnSpeed); // E
    new TurnAnimation('E', 1, turnSpeed); // E'
    new TurnAnimation('d', -1, turnSpeed); // d
    new TurnAnimation('d', 1, turnSpeed); // d'
    new TurnAnimation('D', -1, turnSpeed); // D
    new TurnAnimation('D', 1, turnSpeed); // D'

    // Z
    new TurnAnimation('F', 1, turnSpeed); // F
    new TurnAnimation('F', -1, turnSpeed); // F'
    new TurnAnimation('f', 1, turnSpeed); // f
    new TurnAnimation('f', -1, turnSpeed); // f'
    new TurnAnimation('S', 1, turnSpeed); // S
    new TurnAnimation('S', -1, turnSpeed); // S'
    new TurnAnimation('b', -1, turnSpeed); // b
    new TurnAnimation('b', 1, turnSpeed); // b'
    new TurnAnimation('B', -1, turnSpeed); // B
    new TurnAnimation('B', 1, turnSpeed); // B'
    */
    
    // calculated turn using solve algorithm
    TurnAnimation retVal;
    retVal = new TurnAnimation('B', -1, turnSpeed); // B
    
    return retVal;
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
}
