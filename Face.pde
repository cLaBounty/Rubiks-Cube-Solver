class Face {
  public PVector initialDir;
  public PVector dir;
  public color col;
  private float len;
  private float trueXLength;
  private float trueYLength;
  public PVector centerScrnPos;
  
  // constructor
  Face(PVector dir, color col, float len) {
    this.initialDir = this.dir = dir;
    this.col = col;
    this.len = len;
    trueXLength = len;
    trueYLength = len;
    centerScrnPos = new PVector();
  }
  
  // member functions
  public void turn(char fixedAxis, int dirValue) {
     PVector temp = new PVector(); 
     
     switch(fixedAxis) {
       case 'X': {
         temp.x = dir.x; // fixed
         temp.y = -dir.z * dirValue;
         temp.z = dir.y * dirValue;
         break;  
       }
       case 'Y': {
         temp.x = -dir.z * dirValue;
         temp.y = dir.y; // fixed
         temp.z = dir.x * dirValue;
         break;  
       }
       case 'Z': {
         temp.x = -dir.y * dirValue;
         temp.y = dir.x * dirValue;
         temp.z = dir.z; // fixed
         break;
       }
     }
     
     this.dir = temp;
  }
  
  public void show() {
    pushMatrix();
    fill(col);
    noStroke();
    
    translate((dir.x / 2) * len, (dir.y / 2) * len, (dir.z / 2) * len);
    
    // rotate face relative to the direction
    rotateX(dir.y * HALF_PI);
    rotateY(dir.x * HALF_PI);
    
    square(0, 0, len);
    
    // NOTE: This must be done after the matrix is pushed and before it is popped
    // using the corners to get the vertical and horizontial length of the face
    float topLeftScrnXPos = screenX(-len/2, -len/2);
    float topLeftScrnYPos = screenY(-len/2, -len/2);
    float topRightScrnXPos = screenX(len/2, -len/2);
    float topRightScrnYPos = screenY(len/2, -len/2);
    float botLeftScrnXPos = screenX(len/2, len/2);
    float botLeftScrnYPos = screenY(len/2, len/2);
    
    // updating the center point's position
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
    if (distance < trueXLength/sqrt(2) && distance < trueYLength/sqrt(2))
      return true; 
    
    return false;
  }
}
