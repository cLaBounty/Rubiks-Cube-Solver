class Face {
  private PVector solvedDir;
  private PVector currentDir;
  private color col;
  private float len;
  private float trueXLength;
  private float trueYLength;
  private PVector centerScrnPos;
  
  // getters
  public PVector getSolvedDir() { return solvedDir; }
  public PVector getCurrentDir() { return currentDir; }
  public color getColor() { return col; }
  public PVector getCenterScrnPos() { return centerScrnPos; }
  
  // custom constructor
  Face(PVector dir, color col, float len) {
    this.solvedDir = this.currentDir = dir;
    this.col = col;
    this.len = this.trueXLength = this.trueYLength = len;
    this.centerScrnPos = new PVector();
  }
  
  // member functions
  public void show() {
    pushMatrix();
    fill(col);
    noStroke();
    translate((currentDir.x / 2) * len, (currentDir.y / 2) * len, (currentDir.z / 2) * len);
    
    // rotate face relative to the direction
    rotateX(currentDir.y * HALF_PI);
    rotateY(currentDir.x * HALF_PI);
    
    square(0, 0, len);
    
    // NOTE: This must be done after the matrix is pushed and before it is popped
    // using the corners to get the vertical and horizontial length of the face
    float topLeftScrnXPos = screenX(-len/2, -len/2);
    float topLeftScrnYPos = screenY(-len/2, -len/2);
    float topRightScrnXPos = screenX(len/2, -len/2);
    float topRightScrnYPos = screenY(len/2, -len/2);
    float botLeftScrnXPos = screenX(len/2, len/2);
    float botLeftScrnYPos = screenY(len/2, len/2);
    
    // updating the position of the center point
    centerScrnPos.x = screenX(0, 0);
    centerScrnPos.y = screenY(0, 0);
    centerScrnPos.z = screenZ(0, 0, 0);
    
    // updating the true vertical and horizontial length of the face
    if (topRightScrnXPos > botLeftScrnXPos)
      trueXLength = abs(topLeftScrnXPos - topRightScrnXPos);
    else
      trueXLength = abs(topLeftScrnXPos - botLeftScrnXPos);
    
    if (topRightScrnYPos > botLeftScrnYPos)
      trueYLength = abs(topLeftScrnYPos - topRightScrnYPos);
    else
      trueYLength = abs(topLeftScrnYPos - botLeftScrnYPos);
    
    popMatrix();
  }

  public boolean checkIfClicked() {
    float distance = dist(mouseX, mouseY, centerScrnPos.x, centerScrnPos.y);
    if (distance < trueXLength/2 && distance < trueYLength/2)
      return true; 
    
    return false;
  }
  
  public void turn(char fixedAxis, int dirValue) {
     PVector temp = new PVector(); 
     
     switch(fixedAxis) {
       case 'X': {
         temp.x = currentDir.x; // fixed
         temp.y = -currentDir.z * dirValue;
         temp.z = currentDir.y * dirValue;
         break;  
       }
       case 'Y': {
         temp.x = -currentDir.z * dirValue;
         temp.y = currentDir.y; // fixed
         temp.z = currentDir.x * dirValue;
         break;  
       }
       case 'Z': {
         temp.x = -currentDir.y * dirValue;
         temp.y = currentDir.x * dirValue;
         temp.z = currentDir.z; // fixed
         break;
       }
     }
     
     this.currentDir = temp;
  }
}
