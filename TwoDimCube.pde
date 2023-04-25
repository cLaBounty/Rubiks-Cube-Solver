class TwoDimCube extends Cube {
  
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
  
  public TwoDimCube newInstance() {
    return new TwoDimCube();
  }
  
  public void solve() {
    isSolving = true;
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
  }
  
  protected void setNextTurns() {
    if (isSolved()) {
      isSolving = false;
    } else {
      solveCorner();
    }
  }
}
