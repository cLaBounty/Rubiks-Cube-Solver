class TurnAnimation {
  public int x;
  public int y;
  public int z;
  public float angle;
  private char notationBase;
  protected int dirValue;
  
  // default constructor
  TurnAnimation() {
    this.x = -1;
    this.y = -1;
    this.z = -1;
    this.angle = 0;
    this.notationBase = '\0';
    this.dirValue = 0;
  }
  
  // custom constructor for a normal turn
  TurnAnimation(char notationBase, int dirValue) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    this.angle = 0;
    
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
  
  void update() { //<>//
    if (abs(angle) < HALF_PI) {
      if (rubiksCube.isScrambling)
        angle += dirValue * 0.35;
      else if (rubiksCube.isSolving)
        angle += dirValue * 0.055 * rubiksCube.turnSpeed; //<>// //<>// //<>// //<>// //<>// //<>// //<>//
    }
    else { // if animation is done, then make chages to cube and stop animation
      angle = 0;
      rubiksCube.turn();
      rubiksCube.isTurning = false;
    }
  }
}
