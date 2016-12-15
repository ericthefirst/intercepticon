// Characters
ArrayList<Alien>             aliens;
ArrayList<InterceptLaserPod> i_pods;
InterceptLaserPod            i_pod;
PImage                       earth;

// Controller
Equation   eqn;
Controller c;
boolean win = false;
boolean lose = false;


// Model
ArrayList<Point> points;
ArrayList<Line>  lines;

// View
View v;


void setup() {
  init_controller();
  init_view();
  init_model();
  init_characters();
}

void draw() {
  if(win) {
    v.display_win();
    return;
  }
  if(lose) {
    v.display_lose();
    return;
  }
  c.update();
//  if(!v.updated)
//    return;
  v.draw();
//  v.updated = false;
}
