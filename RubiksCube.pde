import peasy.*;

PeasyCam camera;

// creating 3x3 rubik's cube
Cube rubiksCube = new Cube(3);

boolean isCubeMoveable;

// HUD font
PFont font;

// HUD button constants
final int BTN_HEIGHT = 50;
final int TOP_BTN_Y = 60;
final int BOT_BTN_Y = 540;
final int TOP_BTN_WIDTH = 160;
final int BOT_BTN_WIDTH = 100;
final int TOP_BTN_GAP = 30;
final int BOT_BTN_GAP = 50;
final int MIDDLE_BTN_X = 300;
final int SCRAMBLE_BTN_X = MIDDLE_BTN_X - TOP_BTN_WIDTH - TOP_BTN_GAP;
final int SOLVE_BTN_X = MIDDLE_BTN_X + TOP_BTN_WIDTH + TOP_BTN_GAP;
final int TWO_BY_TWO_X = MIDDLE_BTN_X - BOT_BTN_WIDTH - BOT_BTN_GAP;
final int FOUR_BY_FOUR_X = MIDDLE_BTN_X + BOT_BTN_WIDTH + BOT_BTN_GAP;

void setup() {
  // window size
  size(600, 600, P3D);
  
  // camera setup
  camera = new PeasyCam(this, 400);
  camera.rotateX(radians(25));
  camera.rotateY(radians(30));
  camera.rotateZ(radians(-12));
  camera.setRightDragHandler(null); // disable right click functionality
  camera.setCenterDragHandler(null); // disable scroll wheel click functionality
  camera.setWheelHandler(null); // disable scroll wheel zoom
  camera.setResetOnDoubleClick(false); // disable reset on double click
  
  // load HUD font
  font = loadFont("Arial-BoldMT-32.vlw");
  textFont(font);
  
  // build the rubik's cube
  rubiksCube.build();
}

void draw() {
  // reset background
  background(51);
  
  // show and update cube
  rubiksCube.show();
  rubiksCube.update();
  
  // only allow camera movement when ctrl is pressed
  if (!checkButtonHover()) {
    if (keyPressed && keyCode == CONTROL) {
      // able to move camera
      camera.setActive(true);
      cursor(MOVE);
    
      // unable to edit cube
      isCubeMoveable = false;
    }
    else {
      // unable to move camera
      camera.setActive(false);
      cursor(CROSS);
    
      // able to edit cube
      isCubeMoveable = true;
    }
  }
  
  // HUD
  camera.beginHUD();

  fill(120);
  stroke(0);
  strokeWeight(3);
  rectMode(CENTER);
  
  // top buttons
  rect(SCRAMBLE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT);
  rect(MIDDLE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT);
  rect(SOLVE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT);
  
  // bottom buttons
  rect(TWO_BY_TWO_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  rect(MIDDLE_BTN_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  rect(FOUR_BY_FOUR_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  
  fill(0);
  textAlign(CENTER, CENTER);
  
  // top button text
  textSize(28);
  text("Scramble", SCRAMBLE_BTN_X, TOP_BTN_Y);
  text("Reset", MIDDLE_BTN_X, TOP_BTN_Y);
  text("Solve", SOLVE_BTN_X, TOP_BTN_Y);
  
  // bottom button text
  textSize(32);
  text("2x2", TWO_BY_TWO_X, BOT_BTN_Y);
  text("3x3", MIDDLE_BTN_X, BOT_BTN_Y);
  text("4x4", FOUR_BY_FOUR_X, BOT_BTN_Y);
  
  camera.endHUD();
}

boolean checkButtonHover() {
  // check if the mouse if hovering over any of the buttons
  if ((mouseY < (TOP_BTN_Y + (BTN_HEIGHT / 2)) &&
       mouseY > (TOP_BTN_Y - (BTN_HEIGHT / 2)) &&
       
      (mouseX < (SCRAMBLE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
       mouseX > (SCRAMBLE_BTN_X - (TOP_BTN_WIDTH / 2)) ||
       
       mouseX < (MIDDLE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
       mouseX > (MIDDLE_BTN_X - (TOP_BTN_WIDTH / 2)) ||
       
       mouseX < (SOLVE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
       mouseX > (SOLVE_BTN_X - (TOP_BTN_WIDTH / 2)))) ||
       
      (mouseY < (BOT_BTN_Y + (BTN_HEIGHT / 2)) &&
       mouseY > (BOT_BTN_Y - (BTN_HEIGHT / 2)) &&
       
      (mouseX < (TWO_BY_TWO_X + (BOT_BTN_WIDTH / 2)) &&
       mouseX > (TWO_BY_TWO_X - (BOT_BTN_WIDTH / 2)) ||
       
       mouseX < (MIDDLE_BTN_X + (BOT_BTN_WIDTH / 2)) &&
       mouseX > (MIDDLE_BTN_X - (BOT_BTN_WIDTH / 2)) ||
       
       mouseX < (FOUR_BY_FOUR_X + (BOT_BTN_WIDTH / 2)) &&
       mouseX > (FOUR_BY_FOUR_X - (BOT_BTN_WIDTH / 2)))))
      {
        cursor(HAND);
        return true;
      }
  
  return false;
}
 //<>//
void mousePressed() {
  if (mouseButton == LEFT) {
    if (
      mouseY < (TOP_BTN_Y + (BTN_HEIGHT / 2)) &&
      mouseY > (TOP_BTN_Y - (BTN_HEIGHT / 2))) {
        if ( // scramble button
          mouseX < (SCRAMBLE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
          mouseX > (SCRAMBLE_BTN_X - (TOP_BTN_WIDTH / 2))) {
            if (!rubiksCube.isTurning)
              rubiksCube.scramble();
        }
        else if ( // reset button
          mouseX < (MIDDLE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
          mouseX > (MIDDLE_BTN_X - (TOP_BTN_WIDTH / 2))) {
            if (!rubiksCube.isTurning) {
              rubiksCube = new Cube(rubiksCube.getDimensions());
              rubiksCube.build();
            }
        }
        else if ( // solve button
          mouseX < (SOLVE_BTN_X + (TOP_BTN_WIDTH / 2)) &&
          mouseX > (SOLVE_BTN_X - (TOP_BTN_WIDTH / 2))) {
            if (!rubiksCube.isTurning)
              rubiksCube.solve();
        }
  }
  else if (
    mouseY < (BOT_BTN_Y + (BTN_HEIGHT / 2)) &&
    mouseY > (BOT_BTN_Y - (BTN_HEIGHT / 2))) {
      if ( // 2x2 button
        mouseX < (TWO_BY_TWO_X + (BOT_BTN_WIDTH / 2)) &&
        mouseX > (TWO_BY_TWO_X - (BOT_BTN_WIDTH / 2))) {
          if (!rubiksCube.isTurning && rubiksCube.getDimensions() != 2) {
            rubiksCube = new Cube(2);
            rubiksCube.build();
          }
      }
      else if ( // 3x3 button
        mouseX < (MIDDLE_BTN_X + (BOT_BTN_WIDTH / 2)) &&
        mouseX > (MIDDLE_BTN_X - (BOT_BTN_WIDTH / 2))) {
          if (!rubiksCube.isTurning && rubiksCube.getDimensions() != 3) {
            rubiksCube = new Cube(3);
            rubiksCube.build();
          }
      }
      else if ( // 4x4 button
        mouseX < (FOUR_BY_FOUR_X + (BOT_BTN_WIDTH / 2)) &&
        mouseX > (FOUR_BY_FOUR_X - (BOT_BTN_WIDTH / 2))) {
          if (!rubiksCube.isTurning && rubiksCube.getDimensions() != 4) {
            rubiksCube = new Cube(4);
            rubiksCube.build();
          }
      }
    }
    else if (isCubeMoveable) {
      // edit cube by clicking
    }
  }
}
