/*
  new TurnAnimation('L', -1); // L
  new TurnAnimation('l', -1); // l
  new TurnAnimation('R', 1); // R
  new TurnAnimation('r', 1); // r
  
  new TurnAnimation('U', 1); // U
  new TurnAnimation('u', 1); // u
  new TurnAnimation('D', -1); // D
  new TurnAnimation('d', -1); // d
  
  new TurnAnimation('B', -1); // B
  new TurnAnimation('b', -1); // b
  new TurnAnimation('F', 1); // F
  new TurnAnimation('f', 1); // f
*/

import java.util.*;
import peasy.*;

PeasyCam camera;

// creating the initial 3x3 rubik's cube
Cube rubiksCube = new ThreeDimCube();

boolean isCubeMoveable;

// HUD button constants
final int BTN_HEIGHT = 50;
final int TOP_BTN_Y = 60;
final int BOT_BTN_Y = 540;
final int LEFT_BTN_X = 70;
final int RIGHT_BTN_X = 515;
final int TOP_BTN_WIDTH = 160;
final int BOT_BTN_WIDTH = 100;
final int SIDE_BTN_WIDTH = 80;
final int TOP_BTN_GAP = 30;
final int BOT_BTN_GAP = 60;
final int SIDE_BTN_GAP = 35;
final int MIDDLE_BTN = 300;
final int SCRAMBLE_BTN_X = MIDDLE_BTN - TOP_BTN_WIDTH - TOP_BTN_GAP;
final int SOLVE_BTN_X = MIDDLE_BTN + TOP_BTN_WIDTH + TOP_BTN_GAP;
final int TWO_BY_TWO_X = MIDDLE_BTN - BOT_BTN_WIDTH - BOT_BTN_GAP;
final int FOUR_BY_FOUR_X = MIDDLE_BTN + BOT_BTN_WIDTH + BOT_BTN_GAP;
final int TOP_SIDE_BTN_Y = MIDDLE_BTN - BTN_HEIGHT - SIDE_BTN_GAP;
final int BOT_SIDE_BTN_Y = MIDDLE_BTN + BTN_HEIGHT + SIDE_BTN_GAP;

void setup() {
  // window size and 3D renderer
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
  
  // HUD font
  PFont font;
  font = loadFont("Arial-BoldMT-32.vlw");
  textFont(font);
  
  // build the rubik's cube
  rubiksCube.build();
}

void draw() {
  // reset background
  background(48);
  
  // show and update cube
  rubiksCube.show();
  rubiksCube.update();
  
  // only allow camera movement when ctrl is pressed
  if (keyPressed && keyCode == CONTROL) {
    // able to move camera
    camera.setActive(true);
    cursor(MOVE);
    
    // unable to edit cube
    isCubeMoveable = false;
  }
  else {
    if (!checkButtonHover()) {
      // unable to move camera
      camera.setActive(false);
      cursor(CROSS);
    
      // able to edit cube
      isCubeMoveable = true;
    }
    else {
      cursor(HAND);
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
  rect(MIDDLE_BTN, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT);
  rect(SOLVE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT);
  
  // bottom buttons
  rect(TWO_BY_TWO_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  rect(MIDDLE_BTN, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  rect(FOUR_BY_FOUR_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT);
  
  // left side buttons
  rect(LEFT_BTN_X, TOP_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT);
  rect(LEFT_BTN_X, MIDDLE_BTN, SIDE_BTN_WIDTH, BTN_HEIGHT);
  rect(LEFT_BTN_X, BOT_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT);
  
  // right side buttons
  rect(RIGHT_BTN_X, TOP_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT);
  rect(RIGHT_BTN_X, MIDDLE_BTN, SIDE_BTN_WIDTH, BTN_HEIGHT);
  rect(RIGHT_BTN_X, BOT_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT);
  
  fill(0);
  textAlign(CENTER, CENTER);
  
  // top button text
  textSize(28);
  text("Scramble", SCRAMBLE_BTN_X, TOP_BTN_Y);
  text("Reset", MIDDLE_BTN, TOP_BTN_Y);
  text("Solve", SOLVE_BTN_X, TOP_BTN_Y);
  
  // bottom button text
  textSize(32);
  text("2x2", TWO_BY_TWO_X, BOT_BTN_Y);
  text("3x3", MIDDLE_BTN, BOT_BTN_Y);
  text("4x4", FOUR_BY_FOUR_X, BOT_BTN_Y);
  
  // left side button text
  textSize(23);
  text("0.25x", LEFT_BTN_X, TOP_SIDE_BTN_Y);
  text("0.5x", LEFT_BTN_X, MIDDLE_BTN);
  textSize(25);
  text("1x", LEFT_BTN_X, BOT_SIDE_BTN_Y);
  
  // right side button text
  textSize(26);
  text("2x", RIGHT_BTN_X, TOP_SIDE_BTN_Y);
  text("5x", RIGHT_BTN_X, MIDDLE_BTN);
  text("10x", RIGHT_BTN_X, BOT_SIDE_BTN_Y);
  
  camera.endHUD();
}

boolean checkButtonHover() {
  // check if the mouse if hovering over any of the buttons
  if ((mouseY < (TOP_BTN_Y + (BTN_HEIGHT / 2)) && mouseY > (TOP_BTN_Y - (BTN_HEIGHT / 2)) &&
      (mouseX < (SCRAMBLE_BTN_X + (TOP_BTN_WIDTH / 2)) && mouseX > (SCRAMBLE_BTN_X - (TOP_BTN_WIDTH / 2)) ||
       mouseX < (MIDDLE_BTN + (TOP_BTN_WIDTH / 2)) && mouseX > (MIDDLE_BTN - (TOP_BTN_WIDTH / 2)) ||
       mouseX < (SOLVE_BTN_X + (TOP_BTN_WIDTH / 2)) && mouseX > (SOLVE_BTN_X - (TOP_BTN_WIDTH / 2)))) ||
       
      (mouseY < (BOT_BTN_Y + (BTN_HEIGHT / 2)) && mouseY > (BOT_BTN_Y - (BTN_HEIGHT / 2)) &&
      (mouseX < (TWO_BY_TWO_X + (BOT_BTN_WIDTH / 2)) && mouseX > (TWO_BY_TWO_X - (BOT_BTN_WIDTH / 2)) ||
       mouseX < (MIDDLE_BTN + (BOT_BTN_WIDTH / 2)) && mouseX > (MIDDLE_BTN - (BOT_BTN_WIDTH / 2)) ||
       mouseX < (FOUR_BY_FOUR_X + (BOT_BTN_WIDTH / 2)) && mouseX > (FOUR_BY_FOUR_X - (BOT_BTN_WIDTH / 2)))) ||
       
      (mouseX > (LEFT_BTN_X - (SIDE_BTN_WIDTH / 2)) && mouseX < (LEFT_BTN_X + (SIDE_BTN_WIDTH / 2)) &&
      (mouseY > (TOP_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (TOP_SIDE_BTN_Y + (BTN_HEIGHT / 2)) ||
       mouseY > (MIDDLE_BTN - (BTN_HEIGHT / 2)) && mouseY < (MIDDLE_BTN + (BTN_HEIGHT / 2)) ||
       mouseY > (BOT_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (BOT_SIDE_BTN_Y + (BTN_HEIGHT / 2)))) ||
       
      (mouseX > (RIGHT_BTN_X - (SIDE_BTN_WIDTH / 2)) && mouseX < (RIGHT_BTN_X + (SIDE_BTN_WIDTH / 2)) &&
      (mouseY > (TOP_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (TOP_SIDE_BTN_Y + (BTN_HEIGHT / 2)) ||
       mouseY > (MIDDLE_BTN - (BTN_HEIGHT / 2)) && mouseY < (MIDDLE_BTN + (BTN_HEIGHT / 2)) ||
       mouseY > (BOT_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (BOT_SIDE_BTN_Y + (BTN_HEIGHT / 2)))))
      {
        return true;
      }
  
  return false;
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (mouseY < (TOP_BTN_Y + (BTN_HEIGHT / 2)) && mouseY > (TOP_BTN_Y - (BTN_HEIGHT / 2))) {
      // scramble button
      if (mouseX < (SCRAMBLE_BTN_X + (TOP_BTN_WIDTH / 2)) && mouseX > (SCRAMBLE_BTN_X - (TOP_BTN_WIDTH / 2))) {
        if (!rubiksCube.isScrambling && !rubiksCube.isSolving)
          rubiksCube.scramble();
      }
      // reset button
      else if (mouseX < (MIDDLE_BTN + (TOP_BTN_WIDTH / 2)) && mouseX > (MIDDLE_BTN - (TOP_BTN_WIDTH / 2))) {
        // reset camera
        camera = new PeasyCam(this, 400);
        camera.rotateX(radians(25));
        camera.rotateY(radians(30));
        camera.rotateZ(radians(-12));
        camera.setRightDragHandler(null); // disable right click functionality
        camera.setCenterDragHandler(null); // disable scroll wheel click functionality
        camera.setWheelHandler(null); // disable scroll wheel zoom
        camera.setResetOnDoubleClick(false); // disable reset on double click
           
        if (!rubiksCube.isSolved()) {
          float prevTurnSpeed = rubiksCube.getTurnSpeed();
          
          switch(rubiksCube.getDimensions()) {
            case 2: {
              rubiksCube = new TwoDimCube();
              break;
            }
            case 3: {
              rubiksCube = new ThreeDimCube();
              break;
            }
            case 4: {
              rubiksCube = new FourDimCube();
              break;
            }
          }
          
          rubiksCube.build();
          rubiksCube.setTurnSpeed(prevTurnSpeed);
        }
      }
      // solve button
      else if (mouseX < (SOLVE_BTN_X + (TOP_BTN_WIDTH / 2)) && mouseX > (SOLVE_BTN_X - (TOP_BTN_WIDTH / 2))) {
        if (!rubiksCube.isSolved() && !rubiksCube.isScrambling && !rubiksCube.isSolving)
          rubiksCube.solve();
      }
    }
    else if (mouseY < (BOT_BTN_Y + (BTN_HEIGHT / 2)) && mouseY > (BOT_BTN_Y - (BTN_HEIGHT / 2))) {
      // 2x2 button
      if (mouseX < (TWO_BY_TWO_X + (BOT_BTN_WIDTH / 2)) && mouseX > (TWO_BY_TWO_X - (BOT_BTN_WIDTH / 2))) {
        if (!rubiksCube.isScrambling && !rubiksCube.isSolving && rubiksCube.getDimensions() != 2) {
          float prevTurnSpeed = rubiksCube.getTurnSpeed();
          rubiksCube = new TwoDimCube();
          rubiksCube.build();
          rubiksCube.setTurnSpeed(prevTurnSpeed);
        }
      }
      // 3x3 button
      else if (mouseX < (MIDDLE_BTN + (BOT_BTN_WIDTH / 2)) && mouseX > (MIDDLE_BTN - (BOT_BTN_WIDTH / 2))) {
        if (!rubiksCube.isScrambling && !rubiksCube.isSolving && rubiksCube.getDimensions() != 3) {
          float prevTurnSpeed = rubiksCube.getTurnSpeed();
          rubiksCube = new ThreeDimCube();
          rubiksCube.build();
          rubiksCube.setTurnSpeed(prevTurnSpeed);
        }
      }
      // 4x4 button
      else if (mouseX < (FOUR_BY_FOUR_X + (BOT_BTN_WIDTH / 2)) && mouseX > (FOUR_BY_FOUR_X - (BOT_BTN_WIDTH / 2))) {
        if (!rubiksCube.isScrambling && !rubiksCube.isSolving && rubiksCube.getDimensions() != 4) {
          float prevTurnSpeed = rubiksCube.getTurnSpeed();
          rubiksCube = new FourDimCube();
          rubiksCube.build();
          rubiksCube.setTurnSpeed(prevTurnSpeed);
        }
      }
    }
    else if (mouseX > (LEFT_BTN_X - (SIDE_BTN_WIDTH / 2)) && mouseX < (LEFT_BTN_X + (SIDE_BTN_WIDTH / 2))) {
      // 0.25x speed button
      if (mouseY > (TOP_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (TOP_SIDE_BTN_Y + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(0.25);
      }
      // 0.5x speed button
      else if (mouseY > (MIDDLE_BTN - (BTN_HEIGHT / 2)) && mouseY < (MIDDLE_BTN + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(0.5);
      }
      // 1x speed button
      else if (mouseY > (BOT_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (BOT_SIDE_BTN_Y + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(1);
      }
    }
    else if (mouseX > (RIGHT_BTN_X - (SIDE_BTN_WIDTH / 2)) && mouseX < (RIGHT_BTN_X + (SIDE_BTN_WIDTH / 2))) {
      // 2x speed button
      if (mouseY > (TOP_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (TOP_SIDE_BTN_Y + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(2);
      }
      // 5x speed button
      else if (mouseY > (MIDDLE_BTN - (BTN_HEIGHT / 2)) && mouseY < (MIDDLE_BTN + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(5);
      }
      // 10x speed button
      else if (mouseY > (BOT_SIDE_BTN_Y - (BTN_HEIGHT / 2)) && mouseY < (BOT_SIDE_BTN_Y + (BTN_HEIGHT / 2))) {
        rubiksCube.setTurnSpeed(10);
      }
    }
    else if (isCubeMoveable) {
      // edit cube by clicking
      //println("MOVEABLE");
      int editIndex = getCellIndex();
    }
  }
}

void keyPressed() {
  if (keyCode == ENTER) {
    if (rubiksCube.isSolved())
      rubiksCube.scramble(); 
    else
      rubiksCube.solve(); 
  }
}

int getCellIndex() {
  
  return -1;
}
