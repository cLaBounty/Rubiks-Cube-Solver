class Face {
  public PVector initialDir;
  public PVector dir;
  public color col;
  private float len;
  
  // constructor
  Face(PVector dir, color col, float len) {
    this.initialDir = this.dir = dir;
    this.col = col;
    this.len = len;
  }
  
  // member functions
  public void turn(char fixedAxis, int dirValue) {
     PVector temp = new PVector(); 
     
     switch(fixedAxis) {
       case 'X': {
         temp.y = -dir.z * dirValue;
         temp.z = dir.y * dirValue;
         temp.x = dir.x; // fixed
         break;  
       }
       case 'Y': {
         temp.x = -dir.z * dirValue;
         temp.z = dir.x * dirValue;
         temp.y = dir.y; // fixed
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
    rectMode(CENTER);
    translate((dir.x / 2) * len, (dir.y / 2) * len, (dir.z / 2) * len);
    
    // rotate face relative to the direction
    rotateX(dir.y * HALF_PI);
    rotateY(dir.x * HALF_PI);
    
    square(0, 0, len);
    
    popMatrix();
  }
}
