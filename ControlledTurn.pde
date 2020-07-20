class ControlledTurn extends TurnAnimation {
  private int startMouseX;
  private int startMouseY;
  private PVector clickedCellPos;
  private PVector clickedFaceDir;
  private float targetRange;
  private boolean yMouseTurn;
  
  // custom constructor for a user controlled turn
  ControlledTurn(int startMouseX, int startMouseY, PVector clickedCellPos, PVector clickedFaceDir) {
    super();
    this.startMouseX = startMouseX;
    this.startMouseY = startMouseY;
    this.clickedCellPos = clickedCellPos;
    this.clickedFaceDir = clickedFaceDir;
    this.targetRange = 0;
    this.yMouseTurn = false;
  }
  
  @Override
  public void update() {
    if (abs(angle) < HALF_PI) {
      // get the current status of the camera to determine the direction the mouse needs to move
      float[] cameraPos = camera.getPosition();
      float[] cameraRot = camera.getRotations();
      
      // if the angle gets close to 0, then the turn can change directions
      float distToStart = dist(mouseX, mouseY, startMouseX, startMouseY);
      if (abs(angle) < 0.15 && distToStart > 10 && distToStart < rubiksCube.getCellLength()) {
        // reset the turn
        this.sameXPos = -1; // invalid X position
        this.sameYPos = -1; // invalid Y position
        this.sameZPos = -1; // invalid Z position
        this.targetRange = HALF_PI; // default value
        this.yMouseTurn = false;
        
        if (clickedFaceDir.x != 0) { // face on the left or right side is clicked
          // if the mouse is further in the X direction
          if (abs(startMouseX - mouseX) > abs(startMouseY - mouseY)) {
            this.sameYPos = (int)clickedCellPos.y; // turn all with the same Y
          }
          else { // if the mouse is further in the Y direction
            yMouseTurn = true;
            this.sameZPos = (int)clickedCellPos.z;  // turn all with the same Z
            
            // if the face is on the left side, then invert the range
            if (cameraPos[0] > -100)
              targetRange *= -1;
          }
        }
        else if (clickedFaceDir.y == -1) { // face on the top is clicked
          // if the mouse is further in the X direction
          if (abs(startMouseX - mouseX) > abs(startMouseY - mouseY)) {
            // NOTE: The displacement of the cells in the X and Z column change based on the position of the cube
            if (cameraPos[0] > -200 && cameraPos[0] <= 200) {
              if (abs(cameraRot[0]) < 0.75 || abs(cameraRot[0]) > 2.25) // front or back is closest to the screen
                this.sameZPos = (int)clickedCellPos.z; // turn all with the same Z
              
              // invert range when the true front is closest to the screen
              if (abs(cameraRot[0]) < 0.75)
                targetRange *= -1;
            }
            else if (cameraPos[0] > 200 || cameraPos[0] < -200) { // right or left is closest to the screen
              this.sameXPos = (int)clickedCellPos.x; // turn all with the same X
              
              // invert range when the right side is closest to the screen
              if (cameraPos[0] > 200)
                targetRange *= -1;
            }
          }
          else { // if the mouse is further in the Y direction
            yMouseTurn = true;
            
            if (cameraPos[0] > -200 && cameraPos[0] <= 200) {
              if (abs(cameraRot[0]) < 0.75 || abs(cameraRot[0]) > 2.25) // front or back is closest to the screen
                this.sameXPos = (int)clickedCellPos.x; // turn all with the same X
              
              // invert range when the back side is closest to the screen
              if (abs(cameraRot[0]) > 2.25)
                targetRange *= -1;
            }
            else if (cameraPos[0] > 200 || cameraPos[0] < -200) { // right or left is closest to the screen
              this.sameZPos = (int)clickedCellPos.z; // turn all with the same Z
              
              // invert range when the right side is closest to the screen
              if (cameraPos[0] > 200)
                targetRange *= -1;
            }
          }
        }
        else if (clickedFaceDir.z != 0) { // face on the front or back side is clicked
          // if the mouse is further in the X direction
          if (abs(startMouseX - mouseX) > abs(startMouseY - mouseY)) {
            this.sameYPos = (int)clickedCellPos.y; // turn all with the same Y
          }
          else { // if the mouse is further in the Y direction
            yMouseTurn = true;
            this.sameXPos = (int)clickedCellPos.x; // turn all with the same X
            
            // if the face is on the back side, then invert the range
            if (cameraPos[2] < -100)
              targetRange *= -1;
          }
        }
      }
      
      // change the angle based on the direction and distance from the starting point
      if (yMouseTurn) // map to the mouse's Y coordinates
        angle = map(mouseY, startMouseY + rubiksCube.CUBE_LENGTH, startMouseY - rubiksCube.CUBE_LENGTH, -targetRange, targetRange);
      else // map to the mouse's X coordinates
        angle = map(mouseX, startMouseX + rubiksCube.CUBE_LENGTH, startMouseX - rubiksCube.CUBE_LENGTH, -targetRange, targetRange);
    }
    else { // if animation is done, then make chages to cube and stop animation
      rubiksCube.isBeingMoved = false;
      
      // set the direction based on the angle the user chose
      if (angle > 0)
        dirValue =  1;
      else
        dirValue =  -1;
      
      angle = 0;
      rubiksCube.turn();
      rubiksCube.isTurning = false;
    }
  }
}
