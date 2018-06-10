float inc = 0.1;
float scl = 10;
int cols, rows;
float zoff = 0;
Particle[] particles;
PVector[] flowField;

void setup() 
{
  size(1300, 900, P3D);
  cols = floor(width / scl);
  rows = floor(height / scl);
  
  particles = new Particle[1000];
  for(int i = 0; i < particles.length; ++i)
    particles[i] = new Particle();
    
  flowField = new PVector[cols * rows];
  
  background(255);
}

void draw()
{
  float yoff = 0;
  for(int y = 0; y < rows; y++) {
    float xoff = 0;
    for(int x = 0; x < cols; x++) {
      // set the vector in the flow field
      int index = x + y * cols; 
      float angle = noise(xoff, yoff, zoff) * TWO_PI * 2;
      PVector v = PVector.fromAngle(angle);
      v.setMag(1); // set the power of the field on the particle
      flowField[index] = v;
      
      xoff += inc;
    }
    yoff += inc;
    zoff += 0.0003; // rate the flow field changes
  }
  
  // update and draw the particles
  for(int i = 0; i < particles.length; ++i) {
    particles[i].follow(flowField);
    particles[i].update();
    particles[i].show();
  }
}

class Particle {
  PVector pos = new PVector(random(width - 1), random(height - 1)); // position
  PVector vel = new PVector(0, 0); // velocity
  PVector acc = new PVector(0, 0); // acceleration
  PVector prevPos = pos.copy(); // previous position
  float maxSpeed = 2;
  
  void update() {
    // keep current position
    prevPos.x = pos.x; 
    prevPos.y = pos.y; 
    
    // apply acceleration and velocitiy
    vel.add(acc); 
    vel.limit(maxSpeed); // limit velocity
    pos.add(vel); 
    
    // handle window edges
    if(pos.x >= width) pos.x = prevPos.x = 0;
    if(pos.x < 0) pos.x = prevPos.x = width - 1;
    if(pos.y >= height) pos.y = prevPos.y = 0;
    if(pos.y < 0) pos.y = prevPos.y = height - 1;
    
    // reset acceleration
    acc.mult(0); 
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  void show() {
    stroke(0, 50);
    strokeWeight(1);
    line(pos.x, pos.y, prevPos.x, prevPos.y);
  }
  
  void follow(PVector[] flowField) {
    // get the index in the flow field
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);
    int index = x + y * cols;
    
    // get the force and apply it
    PVector force = flowField[index];
    applyForce(force);
  }
}
