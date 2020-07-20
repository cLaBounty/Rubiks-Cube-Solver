abstract class Cube {
  public final float CUBE_LENGTH = 144;
  protected int dim;
  protected float cellLength;
  protected Cell[] cells;
  
  private TurnAnimation currentTurn;
  protected float turnOffset;
  protected char[] turnXBases;
  protected char[] turnYBases;
  protected char[] turnZBases;
  protected int turnCount;
  private float turnSpeed;
  
  protected int scrambleTurnNum;
  protected ArrayList<TurnAnimation> solveTurnSequence;
  
  // current state of the cube
  public boolean isBeingMoved;
  public boolean isTurning;
  public boolean isScrambling;
  public boolean isSolving;
  
  // abstract methods for different dimension cubes
  abstract public void solve();
  abstract protected void setNextTurns();
  
  // getters and setters
  public int getDimensions() { return dim; }
  public float getCellLength() { return cellLength; }
  public TurnAnimation getCurrentTurn() { return currentTurn; }
  public char getTurnXBase(int index) { return turnXBases[index]; }
  public char getTurnYBase(int index) { return turnYBases[index]; }
  public char getTurnZBase(int index) { return turnZBases[index]; }
  public float getTurnSpeed() { return turnSpeed; }
  public void setTurnSpeed(float turnSpeed) { this.turnSpeed = turnSpeed; }
  
  // default constructor
  Cube() {
    this.currentTurn = new TurnAnimation();
    this.turnSpeed = 1;
    this.turnCount = 0;
    this.solveTurnSequence = new ArrayList<TurnAnimation>();
    this.isBeingMoved = false;
    this.isTurning = false;
    this.isScrambling = false;
    this.isSolving = false;
  }
  
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
      if (c.getCurrentX() == currentTurn.getSameXPos()) {
        rotateX(currentTurn.getAngle());
      }
      else if (c.getCurrentY() == currentTurn.getSameYPos()) {
        rotateY(-currentTurn.getAngle());
      }
      else if (c.getCurrentZ() == currentTurn.getSameZPos()) {
        rotateZ(currentTurn.getAngle());
      }
      
      c.show();
      pop();
    } 
  }
  
  public void update() {
    // if the turns are automated
    if (isSolving || isScrambling) {
      // if cube is in the middle of a turn
      if (isTurning) {
        currentTurn.update();
      }
      else {
        // if cube is scrambling and has not reached the set amount of turns
        if (isScrambling && turnCount < scrambleTurnNum) {
          currentTurn = getRandomTurn();
          currentTurn.start();
          turnCount++;
        }
        else if (isSolving) {
          if (turnCount > solveTurnSequence.size()-1) {
            setNextTurns();
          }
          else {
            currentTurn = solveTurnSequence.get(turnCount);
            currentTurn.start();
            turnCount++;
          }
        }
        else {
          isSolving = false;
          isScrambling = false;
        }
      }
    }
    else if (isBeingMoved) { // user is moving the cube
      currentTurn.update();
    }
  }
  
  protected boolean isSolved() {
    // if any cell is not in it's solved location, then the cube is not solved
    for (Cell c : cells) {
      if (c.getColoredFaces().size() > 0) { // disregard the cell in the middle of the cube
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
      if (i == currentTurn.getSameXPos()) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.getCurrentX() == i) {
            float x = (c.getCurrentX() - 1) + turnOffset;
            float y = (c.getCurrentY() - 1) + turnOffset;
            float z = (c.getCurrentZ() - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(currentTurn.getDirValue() * HALF_PI);
            matrix.translate(y, z);
            
            c.update(x, matrix.m02, matrix.m12, turnOffset);
            c.turnFaces('X', currentTurn.getDirValue());
          }
        }
        return; // no need to search further
      }
      // check if Y turn and if so, which one
      else if (i == currentTurn.getSameYPos()) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.getCurrentY() == i) {
            float x = (c.getCurrentX() - 1) + turnOffset;
            float y = (c.getCurrentY() - 1) + turnOffset;
            float z = (c.getCurrentZ() - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(currentTurn.getDirValue() * HALF_PI);
            matrix.translate(x, z);
            
            c.update(matrix.m02, y, matrix.m12, turnOffset);
            c.turnFaces('Y', currentTurn.getDirValue());
          }
        }
        return; // no need to search further
      } // check if Z turn and if so, which one
      else if (i == currentTurn.getSameZPos()) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on specific side
          if (c.getCurrentZ() == i) {
            float x = (c.getCurrentX() - 1) + turnOffset;
            float y = (c.getCurrentY() - 1) + turnOffset;
            float z = (c.getCurrentZ() - 1) + turnOffset;
            
            PMatrix2D matrix = new PMatrix2D();
            matrix.rotate(currentTurn.getDirValue() * HALF_PI);
            matrix.translate(x, y);
            
            c.update(matrix.m02, matrix.m12, z, turnOffset);
            c.turnFaces('Z', currentTurn.getDirValue());
          }
        }
        return; // no need to search further
      }
    }
  }
  
  private int[] getClickedCellandFace() {
    int[] retVal = new int[] {-1, -1};
    float prevZPos = 100;
    
    int cellIndex = 0;
    for (Cell c : cells) {
      int faceIndex = 0;
      for (Face f : c.getColoredFaces()) {
        if (f.checkIfClicked() && f.getCenterScrnPos().z < prevZPos) {
          retVal[0] = cellIndex;
          retVal[1] = faceIndex;
          
          prevZPos = f.getCenterScrnPos().z;
        }
        faceIndex++;
      }
      
      cellIndex++;
    }
    
    return retVal;
  }
  
  public void move(int startMouseX, int startMouseY, int clickedCellIndex, int clickedFaceIndex) {
    isBeingMoved = true;
    
    PVector clickedCellPos = new PVector(cells[clickedCellIndex].getCurrentX(), cells[clickedCellIndex].getCurrentY(), cells[clickedCellIndex].getCurrentZ());
    PVector clickedFaceDir = cells[clickedCellIndex].getColoredFace(clickedFaceIndex).getCurrentDir();

    currentTurn = new ControlledTurn(startMouseX, startMouseY, clickedCellPos, clickedFaceDir);
  }
}
