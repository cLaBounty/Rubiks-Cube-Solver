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
  
  // custom constructor
  TurnAnimation(char notationBase, int dirValue) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    this.angle = 0;
    
    // get the X, Y, or Z that is fixed
    for (int i = 0; i < rubiksCube.getDimensions(); i++) {
      if (rubiksCube.getTurnXBase(i) == notationBase) {
        this.sameXPos = i;
        this.sameYPos = -1; // invalid Y position
        this.sameZPos = -1; // invalid Z position
        return; // no need to search further
      }
      else if (rubiksCube.getTurnYBase(i) == notationBase) {
        this.sameXPos = -1; // invalid X position
        this.sameYPos = i;
        this.sameZPos = -1; // invalid Z position
        return; // no need to search further
      }
      else if (rubiksCube.getTurnZBase(i) == notationBase) {
        this.sameXPos = -1; // invalid X position
        this.sameYPos = -1; // invalid Y position
        this.sameZPos = i;
        return; // no need to search further
      }
    }
  }
  
  // member functions
  public void start() {
    rubiksCube.isTurning = true;
  }
  
  public void update() {
    if (abs(angle) < HALF_PI) {
      if (rubiksCube.isScrambling)
        angle += dirValue * 0.35;
      else if (rubiksCube.isSolving)
        angle += dirValue * 0.055 * rubiksCube.getTurnSpeed();
    }
    else { // if animation is done, then make chages to cube and stop animation
      angle = 0;
      rubiksCube.turn();
      rubiksCube.isTurning = false;
    }
  }
}
