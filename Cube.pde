abstract class Cube {
  protected final float CUBE_LENGTH = 144;
  protected int dim;
  protected float cellLength;
  protected Cell [] cells;
  
  private TurnAnimation turn;
  protected float turnOffset;
  public char[] turnXBases;
  public char[] turnYBases;
  public char[] turnZBases;
  public int turnCount;
  private float turnSpeed;
  
  protected int scrambleTurnNum;
  protected ArrayList<TurnAnimation> solveTurnSequence;
  
  public boolean isTurning;
  public boolean isScrambling;
  public boolean isSolving;
  
  abstract public void solve();
  abstract protected void setNextTurns();
  
  // constructor
  Cube() {
    turn = new TurnAnimation();
    turnSpeed = 1;
    turnCount = 0;
    solveTurnSequence = new ArrayList<TurnAnimation>();
    isTurning = false;
    isScrambling = false;
    isSolving = false;
  }
  
  // getters and setters
  public int getDimensions() { return dim; }
  
  public float getTurnSpeed() { return turnSpeed; }
  public void setTurnSpeed(float turnSpeed) { this.turnSpeed = turnSpeed; }

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
  
  protected boolean isSolved() {
    // if any cell is not in it's solved location, then the cube is not solved
    for (Cell c : cells) {
      if (c.coloredFaces.size() > 0) { // disregard the cell in the middle of the cube
        if (!c.isSolved())
          return false;
      }
    }
    
    return true;
  }
  
  public void scramble() {
    isScrambling = true;
    
    // reset turn count
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
