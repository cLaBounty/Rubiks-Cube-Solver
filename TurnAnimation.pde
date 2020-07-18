class TurnAnimation {
  public int x;
  public int y;
  public int z;
  public float angle;
  private char notationBase;
  private int dirValue;
  private int startMouseX;
  private int startMouseY;
  private PVector clickedCellPos;
  private PVector clickedFaceDir;
  
  // default constructor
  TurnAnimation() {
    this.x = -1;
    this.y = -1;
    this.z = -1;
    this.angle = 0;
    this.notationBase = '\0';
    this.dirValue = 0;
    this.startMouseX = 0;
    this.startMouseY = 0;
    this.clickedCellPos = null;
    this.clickedFaceDir = null;
  }
  
  // custom constructor for a normal turn
  TurnAnimation(char notationBase, int dirValue) {
    this.notationBase = notationBase;
    this.dirValue = dirValue;
    this.angle = 0;
    
    // default values
    this.startMouseX = 0;
    this.startMouseY = 0;
    this.clickedCellPos = null;
    this.clickedFaceDir = null;
    
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
  
  // custom constructor for a user controlled turn
  TurnAnimation(int startMouseX, int startMouseY, PVector clickedCellPos, PVector clickedFaceDir) {
    
    this.startMouseX = startMouseX;
    this.startMouseY = startMouseY;
    
    this.clickedCellPos = clickedCellPos;
    this.clickedFaceDir = clickedFaceDir;
    
    // default values
    this.x = -1;
    this.y = -1;
    this.z = -1;
    this.angle = 0;
    this.notationBase = '\0';
    this.dirValue = 0;
  }
  
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
        if (abs(angle) < 0.15 && distToStart > 10 && distToStart < rubiksCube.cellLength) {
          // reset the turn positions
          this.x = -1; // invalid X location
          this.y = -1; // invalid X location
          this.z = -1; // invalid Z location
          
          // if the mouse is further in the X direction
          if (abs(startMouseX - mouseX) > abs(startMouseY - mouseY)) {
            if (clickedFaceDir.x != 0) // the face is on the left or right side of the cube
              this.y = (int)clickedCellPos.y;
            else if (clickedFaceDir.y != 0) // the face is on the top or bottom of the cube
              this.z = (int)clickedCellPos.z;
            else if (clickedFaceDir.z != 0) // the face is on the front or back side of the cube
              this.y = (int)clickedCellPos.y;
          }
          else { // if the mouse is further in the Y direction
            if (clickedFaceDir.x != 0) // the face is on the left or right side of the cube
              this.z = (int)clickedCellPos.z;
            else if (clickedFaceDir.y != 0) // the face is on the top or bottom of the cube
              this.x = (int)clickedCellPos.x;
            else if (clickedFaceDir.z != 0) // the face is on the front or back side of the cube
              this.x = (int)clickedCellPos.x;
          }
        }
        
        //float[] cameraPos = camera.getPosition();
        //println(cameraPos);
        
        // if the face is on the oppostie side of the cube, then some target ranges will need to be inverted
        int inverted = 1;
        if (clickedFaceDir.x == -1 || clickedFaceDir.y == -1 || clickedFaceDir.z == -1)
          inverted = -1;
        
        // abs of the range that the mouse will be mapped to
        float targetRange = 0;
        boolean yMouseTurn = false;
        
        //
        if (clickedFaceDir.x != 0) {
          if (this.y != -1)
            targetRange = HALF_PI;
          else {
            yMouseTurn = true;
            targetRange = -1 * inverted * HALF_PI;
          }
        }
        else if (clickedFaceDir.y != 0) {
          if (this.z != -1)
            targetRange = inverted * HALF_PI;
          else {
            yMouseTurn = true;
            targetRange = HALF_PI;
          }
        }
        else if (clickedFaceDir.z != 0) {
          if (this.y != -1)
            targetRange = HALF_PI;
          else {
            yMouseTurn = true;
            targetRange = inverted * HALF_PI;
          }
        }
        
        if (yMouseTurn) // map to the mouse's Y coordinates
          angle = map(mouseY, startMouseY + rubiksCube.CUBE_LENGTH, startMouseY - rubiksCube.CUBE_LENGTH, -targetRange, targetRange);
        else // map to the mouse's X coordinates
          angle = map(mouseX, startMouseX + rubiksCube.CUBE_LENGTH, startMouseX - rubiksCube.CUBE_LENGTH, -targetRange, targetRange);
      }
    }
    else { // if animation is done, then make chages to cube and stop animation
      // is user just controller the turn then also set the direction
      if (rubiksCube.isBeingMoved) {
        rubiksCube.isBeingMoved = false;
        
        // set the direction based on the angle the user chose
        if (angle > 0)
          dirValue =  1;
        else
          dirValue =  -1;
      }
      
      angle = 0;
      rubiksCube.turn();
      rubiksCube.isTurning = false;
    }
  }
}
