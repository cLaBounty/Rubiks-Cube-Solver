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
  
  
  ////////////////////////////////////////////////////////////////////
  
  private int startMouseX;
  private int startMouseY;
  private int cellXPos;
  private int cellYPos;
  private int cellZPos;
  
  // custom constructor
  TurnAnimation(int startMouseX, int startMouseY, int cellXPos, int cellYPos, int cellZPos) {
    
    this.startMouseX = startMouseX;
    this.startMouseY = startMouseY;
    
    this.cellXPos = cellXPos;
    this.cellYPos = cellYPos;
    this.cellZPos = cellZPos;    
    
    // default values
    this.x = -1; // invalid X location
    this.y = -1; // invalid Y location
    this.z = -1; // invalid Z location
    
    this.notationBase = '\0';
    this.dirValue = 0;
    angle = 0;
  }
  
  
  ///////////////////////////////////////////////////////////////////
  
  
  // getters
  public char getNotationBase() { return notationBase; }
  public int getDirValue() { return dirValue; }
  
  void start() {
    rubiksCube.isTurning = true;
  }
  
  void update() {
    
    // for debugging
    if (keyPressed && keyCode == ENTER)
      println(); //<>//
    
    if (abs(angle) < HALF_PI) {
      if (rubiksCube.isScrambling)
        angle += dirValue * 0.35;
      else if (rubiksCube.isSolving)
        angle += dirValue * 0.055 * rubiksCube.turnSpeed;
      else if (rubiksCube.isBeingMoved) {
        // if the angle gets close to 0, then the turn can change directions
        float distToStart = dist(mouseX, mouseY, startMouseX, startMouseY);
        if (abs(angle) < 0.1 && distToStart > 10 && distToStart < rubiksCube.CUBE_LENGTH) {
          // if the mouse is further in thew X direction, then make changes to the Y
          if (abs(startMouseX - mouseX) > abs(startMouseY - mouseY)) {
            this.x = -1; // invalid X location
            this.y = cellYPos;
            this.z = -1; // invalid Z location
          }
          else { // if the mouse is further in thew Y direction, then make changes to the X
            this.x = cellXPos;
            this.y = -1; // invalid Y location
            this.z = -1; // invalid Z location
          }
          
          /*
          this.x = -1; // invalid X location
          this.y = -1; // invalid Y location
          this.z = cellZPos;
          */
        }
        
        //float[] cameraPos = camera.getPosition();
        
        // if it is not an X turn, then map the mouse along the X axis
        if (this.x == -1) {
          angle = map(mouseX, startMouseX + rubiksCube.CUBE_LENGTH, startMouseX - rubiksCube.CUBE_LENGTH, -HALF_PI, HALF_PI); 
        }
        else if (this.y == -1) { // if it is not an Y turn, then map the mouse along the Y axis
          angle = map(mouseY, startMouseY + rubiksCube.CUBE_LENGTH, startMouseY - rubiksCube.CUBE_LENGTH, -HALF_PI, HALF_PI); 
        }

        // set the direction that the turn is made based on if the angle is positive or negative
        if (angle > 0)
          dirValue =  1;
        else
          dirValue =  -1;
      }
    }
    else { // if animation is done, then make chages to cube and stop animation
    
      rubiksCube.isBeingMoved = false;
    
      angle = 0;
      rubiksCube.turn();
      rubiksCube.isTurning = false;
    }
  }
}
