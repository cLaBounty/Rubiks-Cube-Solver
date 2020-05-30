class Cell {
  public int solvedX, solvedY, solvedZ;
  public int currentX, currentY, currentZ;
  private PMatrix3D matrix;
  private float len;
  private ArrayList<Face> innerFaces;
  public ArrayList<Face> coloredFaces;
  
  /*
    - Set colors and directions for each side of the cell
    - Ordered: UP, DOWN, FRONT, BACK, LEFT, RIGHT
    - White = UP and Green = FRONT
  */
  final color[] SIDE_COLORS = {
    #FFFFFF, #FFFF00, #00FF00,
    #0000FF, #FF8D1A, #FF0000
  };
  
  final PVector[] DIRECTIONS = {
    new PVector(0, -1, 0), new PVector(0, 1, 0),
    new PVector(0, 0, 1), new PVector(0, 0, -1),
    new PVector(-1, 0, 0), new PVector(1, 0, 0)
  };
  
  // constructor
  Cell(int startX, int startY, int startZ, PMatrix3D matrix, int cubeDim, float len) {
    this.currentX = this.solvedX = startX;
    this.currentY = this.solvedY = startY;
    this.currentZ = this.solvedZ = startZ;
    this.matrix = matrix;
    this.len = len;
    //faces = new Face[6];
    
    // determine which faces are colored and which are black (inside the cube)
    final boolean FACE_CASES[] = {
      (solvedY == 0), (solvedY == (cubeDim - 1)),
      (solvedZ == (cubeDim - 1)), (solvedZ == 0),
      (solvedX == 0), (solvedX == (cubeDim - 1))
    };

    innerFaces = new ArrayList<Face>();
    coloredFaces = new ArrayList<Face>();
    
    for (int i = 0; i < 6; i++) {
      if (FACE_CASES[i]) {
        coloredFaces.add(new Face(DIRECTIONS[i], DIRECTIONS[i], SIDE_COLORS[i], len));
      }
      else {
        innerFaces.add(new Face(DIRECTIONS[i], DIRECTIONS[i], color(0), len));
      }
    }
  }
  
  // member functions
  public void show() {
    noFill();
    stroke(0);
    strokeWeight(7 * (len / 48)); // calculated based on size of each cell
        
    pushMatrix();
        
    applyMatrix(matrix);
        
    box(len);
    
    // display each inner and colored face of the cell
    for (Face f : innerFaces) {
      f.show();
    }
    for (Face f : coloredFaces) {
      f.show();
    }
    
    popMatrix();
  }
  
  public void update(float x, float y, float z, float offset) {
    matrix.reset();
    matrix.translate(x*len, y*len, z*len);
    
    // update current location of the cell
    currentX = round(x + 1 - offset);
    currentY = round(y + 1 - offset);
    currentZ = round(z + 1 - offset);
  }

  public void turnFaces(char fixedAxis, int dirValue) {
    for (Face f : innerFaces) {
      f.turn(fixedAxis, dirValue);
    }
    for (Face f : coloredFaces) {
      f.turn(fixedAxis, dirValue);
    }
  }
}
