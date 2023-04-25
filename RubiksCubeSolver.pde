import java.util.*;

public RubiksCubeSolver context = this;
private Camera camera;
private Cube cube;

public void setup() {
  size(600, 600, P3D);
  smooth(4);
  camera = new Camera();
  cube = new ThreeDimCube();
  camera.initialize();
  cube.initialize();
}

public void draw() {
  background(48);
  camera.update();
  cube.update();
  camera.show();
  cube.show();
}

public void mouseClicked() {
  if (mouseButton != LEFT) { return; }
  if (keyPressed && keyCode == CONTROL) { return; }
  camera.onMouseClicked();
}

public void mousePressed() {
  if (mouseButton != LEFT) { return; }
  cube.onMousePressed();
}

public void mouseReleased() {
  if (mouseButton != LEFT) { return; }
  cube.onMouseReleased();
}
