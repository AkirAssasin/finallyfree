/* @pjs font='fonts/induction.ttf' */ 

var myfont = loadFont("fonts/induction.ttf"); 

ArrayList blocks;

ArrayList missiles;

ArrayList parts;

float width;
float height;

float gw = 700;

float px;
float py;

float vy;

float t;

float dist;

int score;

color bg;

color nbg;

color og;

color pg;

int ptl = 10;

Boolean dead = false;

float[] ptx = new float[ptl];
float[] pty = new float[ptl];

void setup() {
    //noCursor();
    width = window.innerWidth;
    height = window.innerHeight;
    size(width,height);
    
    noCursor();
    
    px = width/2;
    py = height/2;
    
    blocks = new ArrayList();
    missiles = new ArrayList();
    parts = new ArrayList();
    
    bg = color(random(150,255),random(150,255),random(150,255));
    nbg = color(random(150,255),random(150,255),random(150,255));
    og = color((255 - red(bg)),(255 - green(bg)),(255 - blue(bg)));
    
    textFont(myfont,width/50);
    textAlign(CENTER,BOTTOM);
}
 
Number.prototype.between = function (min, max) {
    return this > min && this < max;
}; 

void draw() {
    pg = color(red(og)*.96,green(og)*.96,blue(og)*.96);
    
    dist += 1;
    if (dead) {dist += 1;}
    
    if (dist > 100) {bg = lerpColor(bg,nbg,0.01);}
    if (dist > 200) {
      dist = 0;
      nbg = color(random(150,255),random(150,255),random(150,255));
      score += 1;
      if (dead) {
        score = 0;
        dead = false;
      }
    }
    
    background(og);
    
    fill(bg);
    strokeWeight(1);
    stroke(og);
    rect(width/2 - gw/2,0,gw,height);
    
    fill(pg);
    if (!dead) {
      if (score == 0) {
        text("I'm finally free",width/2,(height + 100)*dist/200);
      } else {
        text("Distance " + score,width/2,(height + 100)*dist/200);
      }
    } else {
      text("one day I'll escape",width/2,(height + 100)*dist/200);
    }
    
    stroke(pg);
    
    if (!dead) {
      for (int i=0; i<ptl; i++) {
          if (i != ptl-1) {
            strokeWeight(i);
            line(ptx[i],pty[i],ptx[i+1],pty[i+1]);
          }
      }
      
      for (int i=0; i<ptl; i++) {
          if (i != ptl-1) {
            ptx[i] = ptx[i+1];
            pty[i] = pty[i+1];
          } else {
            ptx[i] = px;
            pty[i] = py;
          }
      }
    } else {
      for (int i=0; i<ptl; i++) {
        ptx[i] = px;
        pty[i] = py;
      }
    }
    vy += 0.5;
    vy *= 0.96;
    
    px = mouseX;
    py = mouseY;
    
    t += 1;
    
    if (width != window.innerWidth || height != window.innerHeight) {
      width = window.innerWidth;
      height = window.innerHeight;
      size(width, height);
    }
    
    if (blocks.size() < 50 && t > 30 && !dead) {blocks.add(new Block());}
    
    if (missiles.size() <= 5 && random(1) > 0.9 && !dead) {
      missiles.add(new Missile());
    }
    
    if (t > 30) {t = 0;}
    
    for (int i=parts.size()-1; i>=0; i--) {
      Particle p = (Part) parts.get(i);
      p.draw();
      p.update();
      if (p.y > height + width/2) {parts.remove(i);}
    }
    
    for (int i=missiles.size()-1; i>=0; i--) {
      Particle m = (Missile) missiles.get(i);
      m.draw();
    }
    
    for (int i=blocks.size()-1; i>=0; i--) {
      Particle b = (Block) blocks.get(i);
      b.draw();
      b.update();
      if (b.y > height + gw) {blocks.remove(i);}
    }
    
    for (int i=missiles.size()-1; i>=0; i--) {
      Particle m = (Missile) missiles.get(i);
      m.update();
      if (!m.h || dead) {
        for (int pp=0; pp < 5; pp++) {parts.add(new Part(m.x,m.y));}
        missiles.remove(i);
      } //missiles.add(new Missile());
    }
    
    fill(0,0);
    stroke(pg);
    strokeWeight(5);
    if (get(px,py) == og && !dead) {
      dead = true; 
      dist = 0;
      for (int i=0; i < 5; i++) {parts.add(new Part(px,py));}
    }
    
    if (dead) {og = color(200,0,0);} else {og = color((255 - red(bg)),(255 - green(bg)),(255 - blue(bg)));}
    ellipse(px,py,10,10);
}

void mouseDragged() {
    
}

void keyPressed() {
}

void saw(float x,float y,float w,float s,float l, float sp) {
  translate(x,y);
  //rotate(radians(millis()/sp));
  ellipse(0,0,w,w);
  for(int i=0; i < s; i++) {
    rotate(radians(360*i/s));
    triangle(0,w/2 + l,l/2,w/2 - l/2,-l/2,w/2 - l/2);
    rotate(radians(-360*i/s));
  }
  //rotate(0 - radians(millis()/sp));
  translate(-x,-y);
}



class Block {
    float x;
    float y;
    int limb;
    float[] dir;
    Boolean[] hasSaw;
    float[] length;
    float[] s;
    int[] spike;
    float[] slength;
    float[] spin;
    float[] r;
    float[] sw;
    
    Block() {
      x = width/2 + chance.pick([-gw/2,gw/2]);
      y = -gw;
      limb = round(random(1,3));
      hasSaw = new Boolean[limb];
      length = new float[limb];
      s = new float[limb];
      spike = new int[limb];
      slength = new float[limb];
      spin = new float[limb];
      r = new float[limb];
      sw = new float[limb];
      for(int i=0; i < limb; i++) {
        hasSaw[i] = chance.bool();
        length[i] = chance.pick([gw/4,gw/2,gw/1.5]);
        spike[i] = round(random(5,20));
        slength[i] = random(2,20);
        spin[i] = random(2,10);
        r[i] = chance.pick([270,90]);
        s[i] = chance.pick([-1,1]) * random(1);
        sw[i] = random(50,110);
      }
    }
    
    void draw() {
      fill(bg);
      stroke(og);
        
      strokeWeight(5);
      ellipse(x,y,50,50);
      fill(og);
        
      for (int i=0; i < limb; i++) {
        r[i] += s[i];
        strokeWeight(10);
        line(x,y,x + cos(r[i]/180*PI)*length[i], y + sin(r[i]/180*PI)*length[i]);
        strokeWeight(1);
        if (hasSaw[i]) {
          saw(x + cos(r[i]/180*PI)*length[i], y + sin(r[i]/180*PI)*length[i],sw[i],spike[i],slength[i],spin[i]);
        }
      }
    }
    
    void update() {
      y += vy;
    }
}

class Missile {
    float x;
    float y;
    float mvx;
    float mvy;
    float[] tx;
    float[] ty;
    int tl;
    Boolean h = true;
    Boolean a;
    
    Missile() {
      x = chance.pick([0,width]);
      y = random(height);
      a = chance.bool();
      mvx = 0;
      mvy = 0;
      tl = 10;
      tx = new float[tl];
      ty = new float[tl];
      for (int i=0; i<tl; i++) {
        tx[i] = x;
        ty[i] = y;
      }
    }
    
    void draw() {
      stroke(og);
      for (int i=0; i<tl; i++) {
        if (i != tl-1) {
          strokeWeight(i);
          line(tx[i],ty[i],tx[i+1],ty[i+1]);
        }
      }
        
      if (x.between(width/2-gw/2,width/2+gw/2)) {
        strokeWeight(tl/2);
        stroke(bg);
        line(tx[tl-1],ty[tl-1],tx[tl-1],ty[tl-1]);
      }
    }

    void update() {
      if (get(x,y) != bg && x.between(width/2-gw/2,width/2+gw/2)) {h = false;}
        
      if (!a) {
        if (px + random(-60,60) > x) {mvx += random(0.8); mvx *= .96;}
        if (px + random(-60,60) < x) {mvx -= random(0.8); mvx *= .96;}
        if (py + random(-60,60) > y) {mvy += random(0.8); mvy *= .96;}
        if (py + random(-60,60) < y) {mvy -= random(0.8); mvy *= .96;}
      } else {
        if (px > x) {mvx += random(0.5); mvx *= .96;}
        if (px < x) {mvx -= random(0.5); mvx *= .96;}
        if (py > y) {mvy += random(0.5); mvy *= .96;}
        if (py < y) {mvy -= random(0.5); mvy *= .96;}
      }
          
      x += mvx;
      y += mvy;
        
      for (int i=0; i<tl; i++) {
        if (i != tl-1) {
          tx[i] = tx[i+1];
          ty[i] = ty[i+1];
        } else {
          tx[i] = x;
          ty[i] = y;
        }
      }
    }
}

class Part {
    float x;
    float y;
    float sz;
    Boolean a;
    
    Part(ox,oy) {
      x = ox;
      y = oy;
      a = false;
      sz = 0;
    }
    
    void draw() {
      stroke(pg);
      fill(0,0);
      strokeWeight(2);
      ellipse(x,y,sz,sz);
    }

    void update() {
      if (!a) {sz += (100 - sz)/5;} else {sz += (sz - 101)/10;}
      y += vy;
    }
}