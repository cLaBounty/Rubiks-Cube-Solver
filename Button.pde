abstract class Button {
  private int x;
  private int y;
  private int w;
  private int h;
  private String text;
  private int fontSize;
  
  Button(int x, int y, int w, int h, String text, int fontSize) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
    this.fontSize = fontSize;
  }
  
  abstract public void onClick();

  public void show() {
    fill(120);
    stroke(0);
    strokeWeight(3);
    rectMode(CENTER);
    rect(x, y, w, h);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(fontSize);
    text(text, x, y);
  }
  
  public void onMouseClicked() {
    if (!isClicked()) { return; }
    onClick();
  }
  
  public boolean isClicked() {
    return (mouseY < (y + (h / 2)) && mouseY > (y - (h / 2))) && 
            (mouseX < (x + (w / 2)) && mouseX > (x - (w / 2)));
  }
}
