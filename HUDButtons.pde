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

class ScrambleButton extends Button {
  
  ScrambleButton() {
    super(SCRAMBLE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT, "Scramble", 28);
  }
  
  @Override
  public void onClick() {
    if (cube.isScrambling || cube.isSolving) { return; }
    cube.scramble();
  }
}

class ResetButton extends Button {
  
  ResetButton() {
    super(MIDDLE_BTN, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT, "Reset", 28);
  }
  
  @Override
  public void onClick() {
    camera = new Camera();
    camera.initialize();
    
    if (cube.isSolved()) { return; }
    
    Cube newCube = cube.newInstance();
    newCube.initialize();
    cube = newCube;
  }
}

class SolveButton extends Button {
  
  SolveButton() {
    super(SOLVE_BTN_X, TOP_BTN_Y, TOP_BTN_WIDTH, BTN_HEIGHT, "Solve", 28);
  }
  
  @Override
  public void onClick() {
    if (cube.isSolved() || cube.isScrambling || cube.isSolving) { return; }
    cube.solve();
  }
}

class TwoByTwoButton extends Button {
  
  TwoByTwoButton() {
    super(TWO_BY_TWO_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT, "2x2", 32);
  }
  
  @Override
  public void onClick() {
    if (cube.getDimensions() == 2) { return; }
    if (cube.isScrambling || cube.isSolving) { return; }
    
    cube = new TwoDimCube();
    cube.initialize();
  }
}

class ThreeByThreeButton extends Button {
  
  ThreeByThreeButton() {
    super(MIDDLE_BTN, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT, "3x3", 32);
  }
  
  @Override
  public void onClick() {
    if (cube.getDimensions() == 3) { return; }
    if (cube.isScrambling || cube.isSolving) { return; }
    
    cube = new ThreeDimCube();
    cube.initialize();
  }
}

class FourByFourButton extends Button {
  
  FourByFourButton() {
    super(FOUR_BY_FOUR_X, BOT_BTN_Y, BOT_BTN_WIDTH, BTN_HEIGHT, "4x4", 32);
  }
  
  @Override
  public void onClick() {
    if (cube.getDimensions() == 4) { return; }
    if (cube.isScrambling || cube.isSolving) { return; }
    
    cube = new FourDimCube();
    cube.initialize();
  }
}

class Speed025xButton extends Button {
  
  Speed025xButton() {
    super(LEFT_BTN_X, TOP_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT, "0.25x", 23);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(0.25);
  }
}

class Speed05xButton extends Button {
  
  Speed05xButton() {
    super(LEFT_BTN_X, MIDDLE_BTN, SIDE_BTN_WIDTH, BTN_HEIGHT, "0.5x", 23);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(0.5);
  }
}

class Speed1xButton extends Button {
  
  Speed1xButton() {
    super(LEFT_BTN_X, BOT_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT, "1x", 23);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(1);
  }
}

class Speed2xButton extends Button {
  
  Speed2xButton() {
    super(RIGHT_BTN_X, TOP_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT, "2x", 26);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(2);
  }
}

class Speed5xButton extends Button {
  
  Speed5xButton() {
    super(RIGHT_BTN_X, MIDDLE_BTN, SIDE_BTN_WIDTH, BTN_HEIGHT, "5x", 26);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(5);
  }
}

class Speed10xButton extends Button {
  
  Speed10xButton() {
    super(RIGHT_BTN_X, BOT_SIDE_BTN_Y, SIDE_BTN_WIDTH, BTN_HEIGHT, "10x", 26);
  }
  
  @Override
  public void onClick() {
    cube.setTurnSpeed(10);
  }
}
