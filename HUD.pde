class HUD {
  
  private ArrayList<Button> buttons;
  
  HUD() {
    buttons = new ArrayList<Button>();
  }

  public void initalize() {
    PFont font = loadFont("Arial-BoldMT-32.vlw");
    textFont(font);
    
    buttons.add(new ScrambleButton());
    buttons.add(new ResetButton());
    buttons.add(new SolveButton());
    buttons.add(new TwoByTwoButton());
    buttons.add(new ThreeByThreeButton());
    buttons.add(new FourByFourButton());
    buttons.add(new Speed025xButton());
    buttons.add(new Speed05xButton());
    buttons.add(new Speed1xButton());
    buttons.add(new Speed2xButton());
    buttons.add(new Speed5xButton());
    buttons.add(new Speed10xButton());
  }
  
  public void show() {
    fill(120);
    stroke(0);
    strokeWeight(3);
    rectMode(CENTER);
    
    for (Button button : buttons) {
      button.show();
    }
  }
  
  public void onMouseClicked() {
    for (Button button : buttons) {
      button.onMouseClicked();
    }
  }

  public boolean anyButtonClicked() {
    for (Button button : buttons) {
      if (button.isClicked()) {
        return true;
      }
    }
    return false;
  }
}
