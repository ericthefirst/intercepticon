void init_view() {
  size(1200, 700);
  //size(1200, 800);
  ellipseMode(RADIUS); 
  v = new View(-12.5, 12.5, -5.5, 5.5);
  textFont(createFont("Helvetica", 30));
  imageMode(CENTER);
  strokeCap(SQUARE);
}

public class View {
  color BG_C     = color(0);
  color MARGIN_C = color(64);
  //color EQN_BG_C = color(216);

  float MARGIN = 20;
  boolean updated = true;
  
  final int WORLD    = 0;
  final int SCR      = 1;
  final int TO_WORLD = 0;
  final int TO_SCR   = 1;
  
  final int X_AXIS = 0;
  final int Y_AXIS = 1;

  float world_l, world_r, world_t, world_b;
  float scr_l,   scr_r,   scr_t,   scr_b;
  float eqn_l,   eqn_r,   eqn_t,   eqn_b;
  float ctrl_l,  ctrl_r,  ctrl_t,  ctrl_b;
  
  
  
  color eqn_text_c       = color(192);
  float eqn_text_h       = 40;
  float eqn_text_margin; // defined in constructor
  float eqn_text_kern    = 10;
  float eqn_coef_kern    = 5;
  
  float eqn_frac_text_h  = 30;
  float eqn_frac_sw      = 4;
  float eqn_frac_pad_top = -3;
  float eqn_frac_pad_bot = 2;
  float eqn_frac_len_ext = 5;
  float eqn_vertical_ff  = -5; 
  
  
  
  color pt_c = color(0,0,255);
  float pt_r = 3;

  color line_c  = color(225,20,0);
  float line_sw = 1;
  
  
  
  color axis_c  = color(255);
  float axis_sw = 3;
  
  color tick_c         = color(255);
  float tick_sw        = 1;
  float tick_len       = 8;
  float tick_spacing_x = 1;
  float tick_spacing_y = 1;
  
  color tick_text_c  = color(255);
  float tick_text_h   = 15;
  float tick_text_pad = 10;
  


  color explosion_c         = color(255, 0, 0);
  int   num_explosion_lines = 8;
  float explosion_line_len  = 10;
  float explosion_start_r   = 10;
  float explosion_end_r     = 50;
  
  
  
  color ipod_c  = color(255,128,0);
  float ipod_r  = 10;
  
  color ipod_cannon_c = color(0,0,255);
  float ipod_cannon_w = 3,
        ipod_cannon_l = 15;
  
  color ctrl_m_text_updn_c = color(0,50,255),
        ctrl_m_text_ltrt_c = color(135,0,255),
        ctrl_b_text_updn_c = color(245,108,0),
        ctrl_b_text_ltrt_c = color(255,0,0);
        
  float ctrl_w_x, 
        ctrl_up_x,
        ctrl_w_y, 
        ctrl_s_y, ctrl_text_pad;
  
  float ctrl_text_h = 30;
  float ctrl_arrow_len = 20,
        ctrl_arrow_head = 5,
        ctrl_arrow_sw   = 3;
        
  float stats_text_h = 20;
  color stats_text_c = color(255),
        energy_c     = color(0,0,255);
  float energy_bar_w = 100,
        energy_bar_h = 30;
  
  int   energy_low_timer = 0;


  public View(float world_l, float world_r, float world_b, float world_t) {
    set_window(WORLD, world_l, world_r, world_b, world_t);
    float asp = aspect_ratio(WORLD);
    set_window(SCR, MARGIN, width-MARGIN, width/asp-MARGIN, MARGIN);
  }

  public View() {
    set_window(SCR, MARGIN , width-MARGIN, height-MARGIN, MARGIN);
    float asp = aspect_ratio(SCR);
    set_window(WORLD, -10*asp, 10*asp, -10, 10);
  }
  
  
 
  /////////////
  // DRAWING //
  /////////////

  void draw() {
    draw_bg();
    draw_axes();
    for(Point p : points)
      draw_point(p);
    for(Alien a : aliens)
      draw_alien(a);
    draw_earth();
    draw_equation(eqn);
    draw_ipod(i_pod);
    draw_lines();
    draw_controls();
    draw_stats();
  }
  
  
  void draw_earth() {
    float scr_x = scale_x(0, TO_SCR);
    float scr_y = scale_y(0, TO_SCR);
    image(earth, scr_x, scr_y); 
  }
  
  
  
  void draw_bg() {
    background(MARGIN_C);
    noStroke();
    fill(BG_C);
    rect(scr_l, scr_t, scr_r-scr_l, scr_b-scr_t);
    rect(eqn_l, eqn_t, eqn_r-eqn_l, eqn_b-eqn_t);
    rect(ctrl_l, ctrl_t, ctrl_r-ctrl_l, ctrl_b-ctrl_t);  
  }
  
  
  
  

  void draw_axes() {
    draw_line(0, world_b, 0, world_t, axis_c, axis_sw);
    draw_line(world_l, 0, world_r, 0, axis_c, axis_sw);
    draw_ticks();
  }
  
  void draw_ticks() {
    textAlign(CENTER, BOTTOM);   // later, handle axis off screen
    textSize(tick_text_h);
    strokeWeight(tick_sw);
    fill(tick_text_c);
    String lbl;

    // X_AXIS
    float y = max(0, world_b);
    textAlign(CENTER, TOP);
    for(float x = round_to_multiple(world_l, tick_spacing_x); x <= world_r; x += tick_spacing_x) {
      if(abs(x-int(x)) < 0.001)
        lbl = ""+int(x);
      else
        lbl = ""+x;
      draw_tick(x,y, X_AXIS, lbl);
    }

    // Y_AXIS
    float x = max(0, world_l);
    textAlign(RIGHT, CENTER);
    for(y = round_to_multiple(world_b, tick_spacing_y); y <= world_t; y += tick_spacing_y) {
      lbl = (abs(y-int(y)) < 0.001) ?  ""+int(y): ""+y;
      draw_tick(x,y, Y_AXIS, lbl);
    }
    
  }
  
  void draw_tick(float x, float y, int type, String label) {
    float scr_x = scale_x(x, TO_SCR);
    float scr_y = scale_y(y, TO_SCR);
    if(type == X_AXIS) {
      stroke(tick_c);
      line(scr_x, scr_y - tick_len/2, scr_x, scr_y+tick_len/2);
      noStroke();
      if(x != 0)
        text(label, scr_x, scr_y + tick_len/2 + tick_text_pad); 
    } else {
      stroke(tick_c);
      line(scr_x-tick_len/2, scr_y, scr_x+tick_len/2, scr_y);
      noStroke();
      if(y != 0)
        text(label, scr_x - tick_text_pad, scr_y);
    }
  }
  
  
  void draw_point(Point p) {
    float x = scale_x(p.x, TO_SCR);
    float y = scale_y(p.y, TO_SCR);
    fill(pt_c);  
    noStroke();
    ellipse(x,y,pt_r, pt_r);    
  }
  
  
  
  void draw_lines() {
    for(Line l : lines) {
      draw_line(l);
    }
  }

  void draw_line(Line l) {
    //println("drawing line " + l.a + "x + " + l.b + "y + " + l.c + " = 0");
    draw_line_segment(l, world_l, world_r);
  }
  
  void draw_line_segment(Line l, float x_l, float x_r) {
    if(l.b == 0) {
      float x = -l.c/l.a;
      if(x > x_r || x < x_l)
        return;
      draw_line(x, world_b, x, world_t);
      return;
    }
    float m = -l.a/l.b;
    float b = -l.c/l.b;
    //println("Drawing line with world coordinates (" + x_l + "," + (m*x_l+b) + ") - (" + x_r + "," + (m*x_r+b) + ")");
    draw_line(x_l, m*x_l+b, x_r, m*x_r+b);
  }
  
  // TODO: Rename this mess
  void draw_line(float x0, float y0, float x1, float y1) {
    draw_line(x0, y0, x1, y1, line_c, line_sw);
  }
  
  void draw_line(float x0, float y0, float x1, float y1, color c, float sw) {
    x0 = scale_x(x0, TO_SCR);
    y0 = scale_y(y0, TO_SCR);
    x1 = scale_x(x1, TO_SCR);
    y1 = scale_y(y1, TO_SCR);
    stroke(c);
    strokeWeight(sw);
    line(x0, y0, x1, y1);
  }
  
  
  
  
  
  
  void draw_alien(Alien a) {
    float scr_x = scale_x(a.x, TO_SCR);
    float scr_y = scale_y(a.y, TO_SCR);
    if(a.exploding)
      draw_explosion(scr_x, scr_y, c.explosion_timer);
    else
      image(a.spaceship, scr_x, scr_y);
  }
  
  void draw_explosion(float scr_x, float scr_y, int timer) {
    float r = (explosion_end_r-explosion_start_r)/c.explosion_max * (c.explosion_max-timer);
    stroke(explosion_c);
    for(int i = 0; i < num_explosion_lines; i++) {
      float x0 = scr_x + r*cos(2*PI*i/num_explosion_lines);
      float y0 = scr_y + r*sin(2*PI*i/num_explosion_lines);
      float x1 = scr_x + (r+explosion_line_len)*cos(2*PI*i/num_explosion_lines);
      float y1 = scr_y + (r+explosion_line_len)*sin(2*PI*i/num_explosion_lines);
      //println("line from (" + x0 + "," + y0 + ") to (" + x1 + "," + y1 + ")");
      line(x0,y0,x1,y1);
    }
  }
  
  void draw_ipod(InterceptLaserPod ipod) {
    float scr_x = scale_x(ipod.x, TO_SCR);
    float scr_y = scale_y(ipod.y, TO_SCR);
    noStroke();
    fill(ipod_c);
    ellipse(scr_x, scr_y, ipod_r, ipod_r);
    
    float x0 = scr_x - ipod_cannon_l * cos(ipod.theta);
    float y0 = scr_y - ipod_cannon_l * sin(ipod.theta);

    float x1 = scr_x + ipod_cannon_l * cos(ipod.theta);
    float y1 = scr_y + ipod_cannon_l * sin(ipod.theta);
    stroke(ipod_cannon_c);
    strokeWeight(ipod_cannon_w);
    line(x0, y0, x1, y1);    
  }

  void draw_equation(Equation eqn) {
    float eqn_y = (eqn_t + eqn_b)/2 + eqn_vertical_ff; 
    float eqn_x;
     
    textSize(eqn_text_h);
    noStroke();
    fill(eqn_text_c);
    textAlign(CENTER, CENTER);
    
    eqn_x = eqn_l + eqn_text_margin + textWidth("y")/2;
    text("y", eqn_x, eqn_y);
    
    eqn_x +=  textWidth("y")/2 + eqn_text_kern + textWidth("=")/2;
    text("=", eqn_x, eqn_y);
    eqn_x += textWidth("=")/2 + eqn_text_kern; 
    
    if(eqn.m_num != 0) {
      if(eqn.m_den != 1) {
        eqn_y -= eqn_vertical_ff;
        float m_width = textWidth(""+eqn.m_num);
        if(m_width < textWidth(""+eqn.m_den))
          m_width = textWidth(""+eqn.m_den);
        m_width += eqn_frac_len_ext;
        
        eqn_x += m_width / 2;
        strokeWeight(eqn_frac_sw);
        stroke(eqn_text_c);
        line(eqn_x-m_width/2, eqn_y, eqn_x+m_width/2, eqn_y);
        noStroke();
        
        
        
        textSize(eqn_frac_text_h);
        textAlign(CENTER, BOTTOM);
        fill(ctrl_m_text_updn_c);
        text(eqn.m_num, eqn_x, eqn_y - eqn_frac_pad_top - eqn_frac_sw/2);
        textAlign(CENTER, TOP);
        fill(ctrl_m_text_ltrt_c);
        text(eqn.m_den, eqn_x, eqn_y + eqn_frac_pad_bot + eqn_frac_sw/2);
        
        eqn_x += m_width/2 + eqn_coef_kern + textWidth("x") / 2;
        textAlign(CENTER, CENTER); 
        eqn_y += eqn_vertical_ff;
      } else {
        eqn_x += textWidth(""+eqn.m_num)/2;
        fill(ctrl_m_text_updn_c);
        text(eqn.m_num, eqn_x, eqn_y);
        eqn_x += textWidth(""+eqn.m_num)/2 + eqn_coef_kern + textWidth("x")/2;
      }
      textSize(eqn_text_h);
      fill(eqn_text_c);
      text("x", eqn_x, eqn_y);
      if(eqn.b_num == 0)
        return;
      eqn_x += textWidth("x")/2 + eqn_text_kern + textWidth("+")/2;
      text("+", eqn_x, eqn_y);
      eqn_x += textWidth("+")/2 + eqn_text_kern;
    }
    
    if(eqn.b_den != 1 && eqn.b_num != 0) {   
     eqn_y -= eqn_vertical_ff;     
      float b_width = textWidth(""+eqn.b_num);
      if(b_width < textWidth(""+eqn.b_den))
        b_width = textWidth(""+eqn.b_den);
      b_width += eqn_frac_len_ext;
      
      eqn_x += b_width / 2;
      strokeWeight(eqn_frac_sw);
      stroke(eqn_text_c);
      line(eqn_x-b_width/2, eqn_y, eqn_x+b_width/2, eqn_y);
      noStroke();

      textSize(eqn_frac_text_h);
      textAlign(CENTER, BOTTOM);
      fill(ctrl_b_text_updn_c);
      text(eqn.b_num, eqn_x, eqn_y - eqn_frac_pad_top - eqn_frac_sw/2);
      textAlign(CENTER, TOP);
      fill(ctrl_b_text_ltrt_c);
      text(eqn.b_den, eqn_x, eqn_y + eqn_frac_pad_bot + eqn_frac_sw/2);
      eqn_y += eqn_vertical_ff; 
    } else {
      fill(ctrl_b_text_updn_c);
      eqn_x += textWidth(""+eqn.b_num)/2;
      text(eqn.b_num, eqn_x, eqn_y);
    }
  }
  
  
  
  void draw_controls() {
    textAlign(CENTER,CENTER);
    textSize(ctrl_text_h);
    noStroke();
        
    noStroke();
    fill(ctrl_m_text_updn_c);
    text("w", ctrl_w_x, ctrl_w_y);
    text("s", ctrl_w_x, ctrl_s_y);
    fill(ctrl_m_text_ltrt_c);
    text("a", ctrl_w_x-ctrl_text_pad, ctrl_s_y);
    text("d", ctrl_w_x+ctrl_text_pad, ctrl_s_y);
    
    strokeWeight(ctrl_arrow_sw);
    stroke(ctrl_b_text_updn_c);
    draw_ctrl_arrow(ctrl_up_x, ctrl_w_y, UP);
    draw_ctrl_arrow(ctrl_up_x, ctrl_s_y, DOWN);
    stroke(ctrl_b_text_ltrt_c);
    draw_ctrl_arrow(ctrl_up_x-ctrl_text_pad, ctrl_s_y, LEFT);
    draw_ctrl_arrow(ctrl_up_x+ctrl_text_pad, ctrl_s_y, RIGHT);
    
    
  }
  void draw_ctrl_arrow(float x, float y, int ortn) {
    float x_lt, x_rt, y_bot, y_top;
    switch(ortn) {
      case UP:
        y_top = y-ctrl_arrow_len/2;
        y_bot = y+ctrl_arrow_len/2;
        line(x, y_bot, x, y_top);
        line(x-ctrl_arrow_head, y_top+ctrl_arrow_head, x, y_top);
        line(x+ctrl_arrow_head, y_top+ctrl_arrow_head, x, y_top);
        break;
      case DOWN:
        y_top = y-ctrl_arrow_len/2;
        y_bot = y+ctrl_arrow_len/2;
        line(x, y_bot, x, y_top);
        line(x-ctrl_arrow_head, y_bot-ctrl_arrow_head, x, y_bot);
        line(x+ctrl_arrow_head, y_bot-ctrl_arrow_head, x, y_bot);
        break;
      case LEFT:
        x_lt = x - ctrl_arrow_len/2;
        x_rt = x + ctrl_arrow_len/2;
        line(x_lt, y, x_rt, y);
        line(x_lt+ctrl_arrow_head, y-ctrl_arrow_head, x_lt, y);
        line(x_lt+ctrl_arrow_head, y+ctrl_arrow_head, x_lt, y);
        break;
      case RIGHT:
        x_lt = x - ctrl_arrow_len/2;
        x_rt = x + ctrl_arrow_len/2;
        line(x_lt, y, x_rt, y);
        line(x_rt-ctrl_arrow_head, y-ctrl_arrow_head, x_rt, y);
        line(x_rt-ctrl_arrow_head, y+ctrl_arrow_head, x_rt, y);
        break;

    } 
  }
  
  //////////////////////////
  // GAME OVER CONDITIONS //
  //////////////////////////
  
  void display_win() {
    background(0);
    textSize(200);
    textAlign(CENTER, CENTER);
    fill(5, 255, 255);
    text("LEVEL UP!", width/2, height/2);
    fill(2, 26, 255);
    text("LEVEL UP!", width/2+3, height/2+3);
  }

  void display_lose() {
    background(0);
    fill(90);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("you lost...", width/2, height/2);
  }
  
  // TODO: Make this look decent
  void draw_stats() {
    textSize(stats_text_h);
    textAlign(LEFT, TOP);
    
    fill(128, 128, 128, .4);
    stroke(0);
    strokeWeight(4);
    //rect(MARGIN+10,MARGIN+10,energy_bar_w + 20, 10+stats_text_h+10+energy_bar_h+10);
    
    fill(stats_text_c); 
    text("Level " + c.level, MARGIN+20, MARGIN+20);
    
    fill(255);
    stroke(0);
    strokeWeight(2);
    rect(MARGIN+20, MARGIN+20+stats_text_h+10, energy_bar_w, energy_bar_h);
    stroke(0,0,0,0); 
    if(energy_low_timer > 0)
      fill(255,0,0);
    else
      fill(energy_c);
    rect(MARGIN+20 + 1, MARGIN+20+stats_text_h+10 + 1,energy_bar_w * i_pod.energy / i_pod.energy_max - 1, energy_bar_h-1);
  }

  void indicate_low_on_energy() {
    energy_low_timer = 30;
  }
  
  
  ///////////////////////
  // COORDINATE SYSTEM //
  ///////////////////////  
  
  void set_window(int type, float l, float r, float b, float t) {
    if(type == WORLD) {
      world_l = l; 
      world_r = r; 
      world_b = b; 
      world_t = t; 
    } else if (type == SCR) {
      scr_l = l; 
      scr_r = r; 
      scr_b = b;
      scr_t = t; 
      
      eqn_l = l;
      eqn_r = (l+r)/2-MARGIN/2;
      eqn_t = scr_b  + MARGIN;
      eqn_b = height - MARGIN;
      
      eqn_text_margin = (eqn_b-eqn_t - eqn_text_h) / 2;
      
      
      
      ctrl_l = (l+r)/2+MARGIN/2;
      ctrl_r = r;
      ctrl_t = eqn_t;
      ctrl_b = eqn_b;
      
      ctrl_w_x  = ctrl_l + (ctrl_r-ctrl_l) / 4;
      ctrl_up_x = ctrl_l + (ctrl_r-ctrl_l) / 4 * 3;
      ctrl_w_y  = ctrl_t + (ctrl_b-ctrl_t) / 3;
      ctrl_s_y  = ctrl_t + (ctrl_b-ctrl_t) / 3 * 2;
      
      ctrl_text_pad = (ctrl_s_y-ctrl_w_y);
      
    }  
  }
  
  
  float aspect_ratio(int type) {
    if(type == SCR)
      return abs((scr_r-scr_l)/(scr_t-scr_b));
    else
      return abs((world_r-world_l)/(world_t-world_b));
  }

  float scale_x(float x0, int type) {
    if(type == TO_WORLD) {
      float extent = (x0-scr_l) / (scr_r-scr_l);
      return extent * (world_r-world_l) + world_l;
    } else {
      float extent = (x0-world_l) / (world_r-world_l);
      return extent * (scr_r-scr_l) + scr_l;
    }
  }

  float scale_y(float y0, int type) {
    if(type == TO_WORLD) {
      float extent = (y0-scr_b) / (scr_t-scr_b);
      return extent * (world_t-world_b) + world_b;
    } else {
      float extent = (y0-world_b) / (world_t-world_b);
      return extent * (scr_t-scr_b) + scr_b;
    }
  }

    
  
}
