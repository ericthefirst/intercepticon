void init_characters() {
  aliens = new ArrayList<Alien>();
  generate_aliens();
 	//create_test_aliens();
  i_pods = new ArrayList<InterceptLaserPod>();
  i_pods.add(new InterceptLaserPod());
  i_pod = i_pods.get(0);
  earth = loadImage("img/earth_50_50.png");
}

void advance_characters() {
  for(Alien a : aliens) {
    a.clock_tick();
  }
  for(InterceptLaserPod ipod : i_pods)
    ipod.update();
} 

String default_spaceship_filename = "img/spaceship.png";

boolean add_test_alien(float x, float y, float period, float offset_sec) {
	console.log("creating test alien");
  if(abs(x) < 2 || abs(y) < 2)
    return false;
  for(Alien a : aliens)
    if(a.is_near(x,y))
      return false;
	console.log("adding alien at " + x + ", " + y);
  aliens.add(new Alien(x,y,period, offset_sec));
  return true;
}

void generate_aliens() {
	console.log("in generate_aliens()");
 int n_aliens = -2+4*c.level;
  float speed = 30*c.level;
  //float speed = 30-min(c.level, 12);
  for(int i = 0; i < n_aliens; i++) {
    while(!add_test_alien(int(random(v.world_l+1, v.world_r-1)), int(random(v.world_b+1, v.world_t-1)), speed, speed/n_aliens*i))
      ;
  }
}

void create_test_aliens() {
	console.log("in add_test_alien()");
   add_test_alien( 5,  3,  30, .00);
   add_test_alien(-3, -4,  2, .25);
   add_test_alien( -7,  3,  30, .50);
   add_test_alien( 3,  3,  30, .75);
}
public class Alien {
  PImage spaceship;
  float x;
  float y;
  float dx;
  float dy;
  float[] dxs = {-1, 0};
  float[] dys = {0, -1};
  float epsilon = 0.0001;
  int movement_i  = 0;
  int movement_t = 0;
  int movement_period = 0;
  int dt;
  
  boolean exploding = false;
  
  void init() {
    this.dx = dxs[0];
    this.dy = dys[0];
  }
  
  public Alien(float x, float y, float movement_period_seconds, float movement_offset_seconds) {
    this.x = x;
    this.y = y;
    movement_period = int(60 * movement_period_seconds);
    movement_t      = int(60 * movement_offset_seconds);
    spaceship = loadImage(default_spaceship_filename);
    dt = 1;
    init();
  }
  
  public Alien(String spaceship_filename, float x, float y, float[] dxs, float dys[], int movement_dt, int offset, int dt) {
    this.spaceship = loadImage(spaceship_filename);
    this.x = x;
    this.y = y;
    this.dxs = dxs;
    this.dys = dys;
    this.dx = dxs[0];
    this.dy = dys[0];
    this.movement_period = movement_period;
    this.movement_t = offset;
    this.dt = dt;
  } 
  
  void advance_strategy() {
    movement_i = (movement_i + 1) % (dxs.length);
    dx = dxs[movement_i];
    dy = dys[movement_i];
  }
  
  void move() {
    if(exploding)
      return;
    x += dx;
    y += dy;
    if(x < v.world_l) {
      
      x = v.world_r - (v.world_l-x);
    }
    if(x > v.world_r) {
      x = v.world_l + (x - v.world_r);
    }
    if(y < v.world_b)
      y = v.world_t - (v.world_b-y);
    if(y > v.world_t)
      y = v.world_b + (y-v.world_t);
    
    v.updated = true;
  }
  
  void clock_tick() {
    movement_t += dt;
    if(movement_t >= movement_period) {
      move();
      movement_t = 0;
      advance_strategy();
    }
  }
  
  boolean is_near(float x, float y) {
    boolean it_is = dist(x,y,this.x,this.y) < epsilon;
    return it_is;
  } 
  
}



public class InterceptLaserPod {
	int FLYING_BLIND_LEVEL = 5;

  int m_num = 0;
  int m_den = 1;
  int b_num = 0;
  int b_den = 1;
  
  float x = 0;
  float y = 1;
  float theta = PI/4;
  
  int energy = 1000;
  int laser_energy_reqt = 999;
  int energy_max = 1000;
  
  float move_y_coef     = 0.1;
  float move_theta_coef = 0.1;
  float epsilon_y       = 0.001;
  float epsilon_theta   = 0.0001;
  
  boolean active = false;
  boolean b_locked;
  boolean m_locked;
	boolean armed = false;

  void recharge(int de) {
    energy += de;
    if(energy > energy_max)
      energy = energy_max;
  }
  
  float cannon_theta() {
    if(m_den == 0)
      return PI/2;
    return atan(float(m_num)/m_den);
  }
  
  void fire() {
    float laser_x, laser_y;
    c.create_laser(m_num, m_den, b_num, b_den);
    energy -= laser_energy_reqt;
    for(int i = aliens.size()-1; i >= 0; i--)  {
      Alien a = aliens.get(i);
      boolean destroyed = false;
      for(laser_x = 0; laser_x <= v.world_r; laser_x++) {
        laser_y = laser_x * float(m_num)/m_den + float(b_num)/b_den;
        if(a.is_near(laser_x,laser_y)) {
          a.exploding = true;
          c.initiate_explosion();
          destroyed = true;
          break;          
        }
      }
      if(destroyed)
        continue;
      for(laser_x = 0; laser_x >= v.world_l; laser_x--) {
        laser_y = laser_x * float(m_num)/m_den + float(b_num)/b_den;
        if(a.is_near(laser_x,laser_y)) {
          a.exploding = true;
          c.initiate_explosion();
          break;          
        }
      }
    } 
  }
  
  
  void activate() {
    active = true;
    b_locked = false;
    m_locked = false;
  }
  
  void update() {
    if(!active)
      return;
    v.updated = true;
    float dy, dtheta;
    
    
    if(!b_locked) {
      dy = (-y + float(b_num)/b_den) * move_y_coef;
      if(abs(dy) < epsilon_y) {
        y = float(b_num)/b_den;
        b_locked = true;
      } else {
        y += dy;
        return;
      }
      
    } else if(!m_locked) {
      dtheta = (atan(float(-m_num)/m_den)-theta) * move_theta_coef;
      if(abs(dtheta) < epsilon_theta) {
        theta = atan(-float(m_num)/m_den);
        m_locked = true;
      } else {
        theta += dtheta;
      }
    } else if(armed){
      fire();
			disarm();
      deactivate();
    } else {
			deactivate();
		}
  }

	void low_level_activate() {
	  if(c.level < FLYING_BLIND_LEVEL) {
			apply_equation(eqn);
		}
	}
  
	void arm() {
		armed = true;
	}

	void disarm() {
		armed = false;
	}

  void deactivate() {
    active = false;
  }
  
  void apply_equation(Equation eqn) {
    this.m_num = eqn.m_num;
    this.m_den = eqn.m_den;
    this.b_num = eqn.b_num;
    this.b_den = eqn.b_den;
    activate();
  }
}
