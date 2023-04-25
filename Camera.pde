import peasy.*;

class Camera {
  
  private PeasyCam peasyCam;
  private HUD hud;
  
  Camera() {
    peasyCam = new PeasyCam(context, 400);
    hud = new HUD();
  }
  
  public void initialize() {
    peasyCam.rotateX(radians(25));
    peasyCam.rotateY(radians(30));
    peasyCam.rotateZ(radians(-12));
    peasyCam.setRightDragHandler(null);
    peasyCam.setCenterDragHandler(null);
    peasyCam.setWheelHandler(null);
    peasyCam.setResetOnDoubleClick(false);
    hud.initalize();
  }
  
  public void show() {
    peasyCam.beginHUD();
    hud.show();
    peasyCam.endHUD();
  }
  
  public void update() {
    if (allowCameraMovement()) {
      peasyCam.setActive(true);
      cube.isMoveable = false;
      cursor(MOVE);
    } else {
      peasyCam.setActive(false);
      if (hud.anyButtonClicked()) {
        cursor(HAND);
      } else {
        cube.isMoveable = true;
        cursor(CROSS);
      }
    }
  }
  
  public void onMouseClicked() {
    hud.onMouseClicked();
  }
  
  private boolean allowCameraMovement() {
    return (keyPressed && keyCode == CONTROL);
  }
}
