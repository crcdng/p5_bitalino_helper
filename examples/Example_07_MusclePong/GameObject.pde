enum Direction { DOWN, LEFT, RIGHT, UP }

enum Boundary { CONSTRAIN, NONE, REFLECT, SCORE }

class GameObject {
  int dx, dy, x, y, w, h;
  
  GameObject(int x, int y, int w, int h) { this(x, y, w, h, 0, 0); } 
  GameObject(int x, int y, int w, int h, int dx, int dy) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.dx = dx;
    this.dy = dy;
  }
  
  Direction directionHorizontal() {
    if (dx <= 0) { return Direction.LEFT; } else { return Direction.RIGHT; } 
  }
  
  Direction directionVertical() {
    if (dy <= 0) { return Direction.UP; } else { return Direction.DOWN; } 
  }
  
  void draw() { 
    stroke(255);
    fill(255);
    rect(x, y, w, h); 
  }
  
  int update() { return update(Boundary.NONE, Boundary.NONE); }
  int update(Boundary collideX, Boundary collideY) {
    x = x + dx;
    y = y + dy;
    if (collideX == Boundary.CONSTRAIN) { 
      constrain(x, 0, width-w); 
    } else if (collideX == Boundary.REFLECT) {
      if (x < 0 || x + w > width) { dx = -dx; }
      update();
    } else if (collideX == Boundary.SCORE) {
      if (x < 0) { return 0; } else if (x + w > width) { return 1; } 
    }
    
    if (collideY == Boundary.CONSTRAIN) { 
      constrain(y, 0, height-h); 
     } else if (collideY == Boundary.REFLECT) {
      if (y < 0 || y + h > height) { dy = -dy; }
      update();
    }
    return -1;
  }
}
