class TurnAnimation {
  public int x;
  public int y;
  public int z;
  public float angle;
  private char notationBase;
  private int dirValue;

  // default constructor
  TurnAnimation() {
    this.notationBase = '\0';
    this.dirValue = 0;
    angle = 0;
  }
  
  // custom constructor
  TurnAnimation(char notationBase, int dirValue) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    angle = 0;
    
    // get the X, Y, or Z that is fixed
    for (int i = 0; i < rubiksCube.turnXBases.length; i++) {
      if (rubiksCube.turnXBases[i] == notationBase) {
        this.x = i;
        this.y = -1; // invalid Y location
        this.z = -1; // invalid Z location
        return; // no need to search further
      }
      else if (rubiksCube.turnYBases[i] == notationBase) {
        this.x = -1; // invalid X location
        this.y = i;
        this.z = -1; // invalid Z location
        return; // no need to search further
      }
      else if (rubiksCube.turnZBases[i] == notationBase) {
        this.x = -1; // invalid X location
        this.y = -1; // invalid Y location
        this.z = i;
        return; // no need to search further
      }
    }
  }
  
  // getters
  public char getNotationBase() { return notationBase; }
  public int getDirValue() { return dirValue; }
  
  void start() {
    rubiksCube.isTurning = true; 
  }
  
  void update() {
    if (rubiksCube.isSolving)
      angle += dirValue * 0.065 * rubiksCube.turnSpeed;
    else
      angle += dirValue * 0.35;
    
      // if animation is done, then make chages to cube and stop animation
      if (abs(angle) > HALF_PI) {
        angle = 0;
        rubiksCube.turn();
        rubiksCube.isTurning = false;
      }
  }
}
