class TwoDimCube extends Cube {
  // custom constructor
  TwoDimCube() {
    super();
    
    dim = 2;
    cellLength = CUBE_LENGTH / 2;
    cells = new Cell[8];
    turnOffset = 0.5;
    scrambleTurnNum = 20;
    
    turnXBases = new char[]{'L', 'R'};
    turnYBases = new char[]{'U', 'D'};
    turnZBases = new char[]{'B', 'F'};
  }
  
  // member functions
  public void solve() {
    isSolving = true;
        
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
  }
  
  protected void setNextTurns() {
    if (!isSolved()) {
      // Swapping Algorithm
      final TurnAnimation[] SWAP_ALG = {
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
        swapCellX = 1;
    
      if (bufferUpColor == #FFFFFF || bufferLeftColor == #FFFFFF || bufferBackColor == #FFFFFF)
        swapCellY = 0;
      else if (bufferUpColor == #FFFF00 || bufferLeftColor == #FFFF00 || bufferBackColor == #FFFF00)
        swapCellY = 1;
    
      if (bufferUpColor == #0000FF || bufferLeftColor == #0000FF || bufferBackColor == #0000FF)
        swapCellZ = 0;
      else if (bufferUpColor == #00FF00 || bufferLeftColor == #00FF00 || bufferBackColor == #00FF00)
        swapCellZ = 1;
    
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
      ArrayList<TurnAnimation> setUpSequence = getSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

      // reversed setup moves to put back in it's original place
      ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
      for (int i = setUpSequence.size() - 1; i >= 0; i--) {
        char notationBase = setUpSequence.get(i).getNotationBase();
        int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
        reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
      }
      
      // add all turns to the solve sequence
      solveTurnSequence.addAll(setUpSequence);
      solveTurnSequence.addAll(Arrays.asList(SWAP_ALG));
      solveTurnSequence.addAll(reverseSetUpSequence);
    }
    else {
      isSolving = false; 
    }
  }
  
  private ArrayList<TurnAnimation> getSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
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
          else if (swapCellX == 1) { // B face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
        else if (swapCellZ == 1) {
          if (swapCellX == 1) { // C face
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
          else if (swapCellZ == 1) { // F face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
        else if (swapCellY == 1) {
          if (swapCellZ == 1) { // G face
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
          else if (swapCellX == 1) { // J face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
        else if (swapCellY == 1) {
          if (swapCellX == 1) { // K face
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
          if (swapCellZ == 1) { // M face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 0) { // N face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
        else if (swapCellY == 1) {
          if (swapCellZ == 0) { // O face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 1) { // P face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) {
          if (swapCellX == 1) { // Q face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // R face
            isBuffer = true;
          }
        }
        else if (swapCellY == 1) {
          if (swapCellX == 0) { // S face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellX == 1) { // T face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellX == 0 && swapCellZ == 1) { // U face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
        }
        else if (swapCellZ == 0) {
          if (swapCellX == 1) { // W face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // X face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved or flipped piece
      if (isBuffer) {
        for (int i = 1; i < cells.length; i++) { // cannot swap with buffer again at index 0
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
    } while (isBuffer);
    
    return setUpSequence;
  }
}
