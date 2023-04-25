abstract class Cube {
  
  public final int CUBE_LENGTH = 144;
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
  public boolean isTurning;
  public boolean isMoveable;
  public boolean isScrambling;
  public boolean isSolving;
  public boolean isBeingMoved;
  
  // abstract methods for different dimension cubes
  abstract public Cube newInstance();
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
  public void setTurnSpeed(float turnSpeed) { 
    if (!isSolving) { return; }
    this.turnSpeed = turnSpeed;
  }
  
  // default constructor
  Cube() {
    this.currentTurn = new TurnAnimation();
    this.turnSpeed = 1;
    this.turnCount = 0;
    this.solveTurnSequence = new ArrayList<TurnAnimation>();
    this.isTurning = false;
    this.isMoveable = false;
    this.isScrambling = false;
    this.isSolving = false;
    this.isBeingMoved = false;
  }
  
  // member functions
  public void initialize() {
    //  offset for where the cells are displayed
    float cellOffset = ((dim - 1) * cellLength) / 2;
    
    // create a new cell and track its position using a nested loop
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
      
      // rotate cells that have the same position as the axis that is being turned
      if (c.getCurrentX() == currentTurn.getSameXPos())
        rotateX(currentTurn.getAngle());
      else if (c.getCurrentY() == currentTurn.getSameYPos())
        rotateY(-currentTurn.getAngle());
      else if (c.getCurrentZ() == currentTurn.getSameZPos())
        rotateZ(currentTurn.getAngle());
      
      c.show();
      pop();
    } 
  }
  
  public void update() {
    if (isSolving || isScrambling) {
      // if cube is in the middle of a turn, then keep updating the angle
      if (isTurning) {
        currentTurn.update();
      }
      else {
        // when scrambling, get a random turn until the limit is reached
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
    else if (isBeingMoved) { // the user is moving the cube
      currentTurn.update();
    }
  }
  
  public void onMousePressed() {
    if (!isMoveable || isScrambling || isSolving) { return; }
    
    int[] clickedCellandFace = getClickedCellandFace();
    if (clickedCellandFace[0] != -1) {
      move(mouseX, mouseY, clickedCellandFace[0], clickedCellandFace[1]);
    }
  }
  
  public void onMouseReleased() {
    if (!isMoveable || isScrambling || isSolving) { return; }
    
    if (currentTurn.angle > QUARTER_PI) {
      currentTurn.setAngle(HALF_PI);
    } else if (currentTurn.angle < -QUARTER_PI) {
      currentTurn.setAngle(-HALF_PI);
    } else {
      currentTurn.setAngle(0);
      isBeingMoved = false;
      isTurning = false;
    }
  }

  protected boolean isSolved() {
    // if any cell is not solved, then the cube is not solved
    for (Cell c : cells) {
      if (c.getColoredFaces().size() > 0) { // disregard the cell(s) in the middle of the cube
        if (!c.isSolved())
          return false;
      }
    }
    
    return true;
  }
  
  public void scramble() {
    isScrambling = true;
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
    for (int i = 0; i < dim; i++) {
      // check if X turn and if so, which one is it
      if (i == currentTurn.getSameXPos()) {
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on the specific side
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
      else if (i == currentTurn.getSameYPos()) { // check if Y turn and if so, which one is it
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on the specific side
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
      }
      else if (i == currentTurn.getSameZPos()) { // check if Z turn and if so, which one is it
        // loop through all cells to find all on the side being changed
        for (Cell c : cells) {
          // turn all cells on the specific side
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
  
  // determine if the face of any cell on the cube was clicked
  private int[] getClickedCellandFace() {
    int[] retVal = new int[] {-1, -1};
    float prevZPos = 100;
    
    // loop through all cells
    int cellIndex = 0;
    for (Cell c : cells) {
      int faceIndex = 0;
      for (Face f : c.getColoredFaces()) {
        // if the face was clicked and if it is closer to the screen
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
  
  // when the user begins to manually move the cube
  public void move(int startMouseX, int startMouseY, int clickedCellIndex, int clickedFaceIndex) {
    isBeingMoved = true;
    
    PVector clickedCellPos = new PVector(cells[clickedCellIndex].getCurrentX(), cells[clickedCellIndex].getCurrentY(), cells[clickedCellIndex].getCurrentZ());
    PVector clickedFaceDir = cells[clickedCellIndex].getColoredFace(clickedFaceIndex).getCurrentDir();
    currentTurn = new ControlledTurn(startMouseX, startMouseY, clickedCellPos, clickedFaceDir);
  }
  
  // common swapping algorithm for solving corners
  protected void addModYPermAlgorithm() {
    // Modified Y Perm Algorithm
    final TurnAnimation[] ALGORITHM = {
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
    
    solveTurnSequence.addAll(Arrays.asList(ALGORITHM));
  }
  
  // common method to solve the corners of each cube
  protected void solveCorner() {
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;
    
    for (int i = 0; i < cells.length; i++) {
      if (cells[i].getCurrentX() == 0 && cells[i].getCurrentY() == 0 && cells[i].getCurrentZ() == 0) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the up, left, and back face color of the buffer cell
    color bufferUpColor = #FFFFFF;
    color bufferLeftColor = #FFFFFF;
    color bufferBackColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].getColoredFaces()) {
      if (f.getCurrentDir().y == -1) // up face
        bufferUpColor = f.col;
      else if (f.getCurrentDir().x == -1) // left face
        bufferLeftColor = f.col;
      else if (f.getCurrentDir().z == -1) // back face
        bufferBackColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = -1;
    int swapCellY = -1;
    int swapCellZ = -1;
    
    if (bufferUpColor == #FF8D1A || bufferLeftColor == #FF8D1A || bufferBackColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferUpColor == #FF0000 || bufferLeftColor == #FF0000 || bufferBackColor == #FF0000)
      swapCellX = dim - 1;
    
    if (bufferUpColor == #FFFFFF || bufferLeftColor == #FFFFFF || bufferBackColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferLeftColor == #FFFF00 || bufferBackColor == #FFFF00)
      swapCellY = dim - 1;
    
    if (bufferUpColor == #0000FF || bufferLeftColor == #0000FF || bufferBackColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferLeftColor == #00FF00 || bufferBackColor == #00FF00)
      swapCellZ = dim - 1;
    
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

    // reverse the setup moves to put it back in it's original position
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--) {
      char notationBase = setUpSequence.get(i).getNotationBase();
      int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
      reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
    }

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    addModYPermAlgorithm();
    solveTurnSequence.addAll(reverseSetUpSequence);
  }
  
  // common method to get the setup moves for the corners of each cube
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
          else if (swapCellX == dim - 1) { // B face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
        else if (swapCellZ == dim - 1) {
          if (swapCellX == dim - 1) { // C face           
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
          else if (swapCellZ == dim - 1) { // F face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
        else if (swapCellY == dim - 1) {
          if (swapCellZ == dim - 1) { // G face
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
          else if (swapCellX == dim - 1) { // J face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
        else if (swapCellY == dim - 1) {
          if (swapCellX == dim - 1) { // K face
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
          if (swapCellZ == dim - 1) { // M face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 0) { // N face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
        else if (swapCellY == dim - 1) {
          if (swapCellZ == 0) { // O face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == dim - 1) { // P face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) {
          if (swapCellX == dim - 1) { // Q face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // R face
            isBuffer = true;
          }
        }
        else if (swapCellY == dim - 1) {
          if (swapCellX == 0) { // S face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellX == dim - 1) { // T face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellX == 0 && swapCellZ == dim - 1) { // U face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
        }
        else if (swapCellZ == 0) {
          if (swapCellX == dim - 1) { // W face
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
        for (int i = 1; i < cells.length; i++) { // cannot swap with buffer again at index 0
          // only check the corner pieces
          if (cells[i].getColoredFaces().size() == 3) {
            // if the cell is unsolved
            if (!cells[i].isSolved()) {
              swapCellX = cells[i].getCurrentX();
              swapCellY = cells[i].getCurrentY();
              swapCellZ = cells[i].getCurrentZ();
              
              swapCellDir.x = cells[i].getColoredFace(0).getCurrentDir().x;
              swapCellDir.y = cells[i].getColoredFace(0).getCurrentDir().y;
              swapCellDir.z = cells[i].getColoredFace(0).getCurrentDir().z;
              
              break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
}
