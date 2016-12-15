void init_model() {
  points = new ArrayList<Point>();
  lines = new ArrayList<Line>();
//  lines.add(new Line(1,2,3,4));
}

public class Point {
  float x, y;
  
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
    
}

public class Line {
  float a, b, c;
  
  public Line(float x0, float y0, float x1, float y1) {
    if(x0 == x1) {
      println("constructing vertical line");
      a = 1;
      b = 0;
      c = -x0;
    } else {
      float M = (y1-y0)/(x1-x0);
      float B = y0-M*x0;
      import_from_slope_intercept(M,B);
    }
  }
  
  public Line(float a, float b, float c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
  
  public Line(float M, float B) {
    import_from_slope_intercept(M,B);
  }
  
  void import_from_slope_intercept(float M, float B) {
    c = -B;
    b = 1;
    a = -M;
  }
  
}
