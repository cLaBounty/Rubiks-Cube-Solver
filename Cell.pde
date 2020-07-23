class Cell {
  private int solvedX, solvedY, solvedZ;
  private int currentX, currentY, currentZ;
  private PMatrix3D matrix;
  private float len;
  private ArrayList<Face> innerFaces;
  private ArrayList<Face> coloredFaces;
  
  /*
    * Set colors and directions for each side of the cell
    * Ordered: UP, DOWN, FRONT, BACK, LEFT, RIGHT
    * White = UP and Green = FRONT
  */
  private final color[] SIDE_COLORS = {
    #FFFFFF, #FFFF00, #00FF00,
    #0000FF, #FF8D1A, #FF0000
  };
  
  private final PVector[] DIRECTIONS = {
    new PVector(0, -1, 0), new PVector(0, 1, 0),
    new PVector(0, 0, 1), new PVector(0, 0, -1),
    new PVector(-1, 0, 0), new PVector(1, 0, 0)
  };
  
  // getters
  public int getSolvedX() { return solvedX; }
  public int getSolvedY() { return solvedY; }
  public int getSolvedZ() { return solvedZ; }
  public int getCurrentX() { return currentX; }
  public int getCurrentY() { return currentY; }
  public int getCurrentZ() { return currentZ; }
  public ArrayList<Face> getColoredFaces() { return coloredFaces; }
  public Face getColoredFace(int index) { return coloredFaces.get(index); }
  
  // custom constructor
  Cell(int startX, int startY, int startZ, PMatrix3D matrix, int cubeDim, float len) {
    this.currentX = this.solvedX = startX;
    this.currentY = this.solvedY = startY;
    this.currentZ = this.solvedZ = startZ;
    this.matrix = matrix;
    this.len = len;
    this.innerFaces = new ArrayList<Face>();
    this.coloredFaces = new ArrayList<Face>();
    
    // determine which faces are colored and which are black (inside the cube)
    final boolean FACE_CASES[] = {
      (solvedY == 0), (solvedY == (cubeDim - 1)),
      (solvedZ == (cubeDim - 1)), (solvedZ == 0),
      (solvedX == 0), (solvedX == (cubeDim - 1))
    };
    
    for (int i = 0; i < 6; i++) {
      if (FACE_CASES[i])
        coloredFaces.add(new Face(DIRECTIONS[i], SIDE_COLORS[i], len));
      else
        innerFaces.add(new Face(DIRECTIONS[i], color(0), len));
    }
  }
  
  // member functions
  public void show() {
    noFill();
    stroke(0);
    strokeWeight(7 * (len / 48)); // calculated based on size of the cell
    
    pushMatrix();
    applyMatrix(matrix);
    box(len);
    
    // display each inner and colored face
    for (Face f : innerFaces)
      f.show();
    
    for (Face f : coloredFaces)
      f.show();
    
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
    for (Face f : innerFaces)
      f.turn(fixedAxis, dirValue);
      
    for (Face f : coloredFaces)
      f.turn(fixedAxis, dirValue);
  }
  
  // when the faces of the cell are not in the solved direction
  public boolean isWrongDirection() {
    if (coloredFaces.get(0).getCurrentDir().x == coloredFaces.get(0).getSolvedDir().x && coloredFaces.get(0).getCurrentDir().y == coloredFaces.get(0).getSolvedDir().y)
      return false;
    
    return true;
  }
  
  // when the faces of the cell are pointing in the opposite direction as when solved
  public boolean isOppositeDirection() {
    for (Face f : coloredFaces) {
      if (f.getCurrentDir().x != -1 * f.getSolvedDir().x || f.getCurrentDir().y != -1 * f.getSolvedDir().y || f.getCurrentDir().z != -1 * f.getSolvedDir().z)
        return false;
    }
    
    return true;
  }
  
  public boolean isSolved() {
    if (!isWrongDirection() && currentX == solvedX && currentY == solvedY && currentZ == solvedZ)
      return true;
    
    return false;
  }
}
