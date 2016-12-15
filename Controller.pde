final int NUM = 0;
final int DEN = 1;

void reset() {
  lose = false;
  println("reset");
  init_controller();
  init_view();
  init_model();
  init_characters();
}

void init_controller() {
  eqn = new Equation();
  c   = new Controller();
}


void keyPressed() {
	if(key == CODED) 
		console.log("key code " + keyCode + " pressed at " + millis());	
	else
		console.log("Key " + key + " pressed at " + millis());

  if(win) {
   win = false;
   c.next_level();
   return;
  }
  if(lose) {
    reset();
    return;
  }
	if(key == ENTER || key == ' ') {
    if(i_pod.energy > i_pod.laser_energy_reqt) {
			i_pod.arm();
      i_pod.apply_equation(eqn);
    } else {
      v.indicate_low_on_energy();
		}
	}
	if(key == CODED) {
    switch(keyCode) {
      case UP: 
        eqn.change_b(NUM, 1);
				i_pod.low_level_activate();
        break;
      case DOWN:
        eqn.change_b(NUM, -1);
				i_pod.low_level_activate();
        break; 
      case LEFT: 
        eqn.change_b(DEN, -1);
				i_pod.low_level_activate();
        break;
      case RIGHT:
        eqn.change_b(DEN, 1);
				i_pod.low_level_activate();
        break; 
    }
		return;
	}
  switch(key) {
    case 'w':
      eqn.change_m(NUM, 1);
			i_pod.low_level_activate();
      break;
    case 's':
      eqn.change_m(NUM, -1);
			i_pod.low_level_activate();
      break;
    case 'a':
      eqn.change_m(DEN, -1);
			i_pod.low_level_activate();
      break;
    case 'd':
      eqn.change_m(DEN, 1);
			i_pod.low_level_activate();
      break;
  }
}



public class Equation {
  int m_num = 1;
  int m_den = 2;
  int b_num = 1;
  int b_den = 2;
  
  public Equation() { }

  void change_b(int type, int d) {
    if(type == DEN) {
      b_den += d;
      if(b_den < 1) {
        b_den = 1;
      }
    } else {
      b_num += d;
      if(b_num == 0)
        b_num += d;
    }
  }

  
  void change_m(int type, int d) {
    if(type == DEN) {
      m_den += d;
      if(m_den < 1) {
        m_den = 1;
      }
    } else {
      m_num += d;
      if(m_num == 0 && c.level > 1)
        m_num += d;
    }
  }  
}



public class Controller {
  int level = 1;
  
  public Controller() {
    this(1);
  }
  
  public Controller(int level) {
    this.level = level;
  }
  
  // lasers
  int laser_timer = 0;
  int laser_max = 30;
  
  int explosion_timer = 0;
  int explosion_max = 120;

  
  void update() {
    check_for_win();
    check_for_lose();
    advance_characters();
    advance_explosion_timer();
    advance_laser_timer();
    advance_low_energy_timer();
    increase_pod_energy();
  }
 
  
  
  void check_for_win() {
    if(aliens.size() == 0) {
      win = true;
    }
  }
  
  void check_for_lose() {
    for(Alien a : aliens) {
      if(a.is_near(0,0) || a.is_near(i_pod.x, i_pod.y)) {
        lose = true;
      }
    }
  }
  
  
  // Handle lasers
  void create_laser(int m_num, int m_den, int b_num, int b_den) {
    lines.add(new Line(float(m_num)/m_den, float(b_num)/b_den));
    laser_timer = laser_max;
  }
  
  void advance_laser_timer() {
    if(laser_timer == 0)
      return;
    laser_timer -= 1;
    if(laser_timer <= 0)
      dequeue_line();
  }
  
  void dequeue_line() {
    if(lines.size() < 1) {
      println("Warning: trying to dequeue from empty arraylist of lines");
      return;  
    }
    lines.remove(0);
  } 
  
  
  
  
  // Handle explosions
  void initiate_explosion() {
    explosion_timer = explosion_max;
  }
  
  void advance_explosion_timer() {
    if(explosion_timer <= 0)
      return;
    explosion_timer -= 1;
    if(explosion_timer <= 0) {
      remove_exploding_aliens();
    }    
  }
  
  void remove_exploding_aliens() {
    for(int i = aliens.size()-1; i >= 0; i--){
      if(aliens.get(i).exploding)
        aliens.remove(i);
    }
  }
  
  void advance_low_energy_timer() {
    if(v.energy_low_timer <= 0)
      return;
    v.energy_low_timer -= 1;
  }
  
  void increase_pod_energy() {
    i_pod.recharge(2+level);
  }
  
  

  void next_level() {
    level += 1;
    generate_aliens();
    i_pod.recharge(i_pod.energy_max);
  }


}
