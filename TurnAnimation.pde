class TurnAnimation {
   
  int x;
  int y;
  int z;
  
  float angle;
  char notationBase;
  int dirValue;
  int turnSpeed;

  // default constructor
  TurnAnimation() {
    this.notationBase = '\0';
    this.dirValue = 0;
    this.turnSpeed = 0;
    angle = 0;
  }
  
  // custom constructor
  TurnAnimation(char notationBase, int dirValue, int turnSpeed) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    this.turnSpeed = turnSpeed;
    angle = 0;
    rubiksCube.isTurning = true;
    
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
    
    // if not found
    this.x = -1;
    this.y = -1;
    this.z = -1;
  }
  
  void update() {
      angle += dirValue * 0.07 * turnSpeed;
    
      // if animation is done, then make chages to cube and stop animation
      if (abs(angle) > HALF_PI) {
        angle = 0;
        rubiksCube.turn();
        rubiksCube.isTurning = false;
      }
  }
}
