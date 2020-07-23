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
    // solve one cell at a time until the cube is solved
    if (!isSolved())
      solveCorner();
    else
      isSolving = false;
  }
}
