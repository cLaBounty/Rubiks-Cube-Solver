class TurnAnimation {
  
  protected int sameXPos;
  protected int sameYPos;
  protected int sameZPos;
  private char notationBase;
  protected int dirValue;
  protected float angle;
  
  // getters and setters
  public int getSameXPos() { return sameXPos; }
  public int getSameYPos() { return sameYPos; }
  public int getSameZPos() { return sameZPos; }
  public char getNotationBase() { return notationBase; }
  public int getDirValue() { return dirValue; }
  public float getAngle() { return angle; }
  public void setAngle(float angle) { this.angle = angle; }
  
  // default constructor
  TurnAnimation() {
    this.sameXPos = -1; // invalid X position
    this.sameYPos = -1; // invalid Y position
    this.sameZPos = -1; // invalid Z position
    this.notationBase = '\0';
    this.dirValue = 0;
    this.angle = 0;
  }
  
  // custom constructor for an algorithmic turn
  TurnAnimation(char notationBase, int dirValue) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    this.angle = 0;
    
    // determine which axis of the turn is fixed
    for (int i = 0; i < cube.getDimensions(); i++) {
      if (cube.getTurnXBase(i) == notationBase) {
        this.sameXPos = i;
        this.sameYPos = -1; // invalid Y position
        this.sameZPos = -1; // invalid Z position
        return; // no need to search further
      }
      else if (cube.getTurnYBase(i) == notationBase) {
        this.sameXPos = -1; // invalid X position
        this.sameYPos = i;
        this.sameZPos = -1; // invalid Z position
        return; // no need to search further
      }
      else if (cube.getTurnZBase(i) == notationBase) {
        this.sameXPos = -1; // invalid X position
        this.sameYPos = -1; // invalid Y position
        this.sameZPos = i;
        return; // no need to search further
      }
    }
  }
  
  // member functions
  public void start() {
    cube.isTurning = true;
  }
  
  public void update() {
    // increase the angle gradually until it reaches a full turn
    if (abs(angle) < HALF_PI) {
      if (cube.isScrambling) {
        angle += dirValue * 0.35;
      } else if (cube.isSolving) {
        angle += dirValue * 0.055 * cube.getTurnSpeed();
      }
    } else { // if animation is done, then make chages to cube and stop turning
      angle = 0;
      cube.turn();
      cube.isTurning = false;
    }
  }
}
