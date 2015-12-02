import peasy.*;
int AXES_DISTANCE = 1000;
float MULT_FACTOR = 100;
float MAX_FORCE = 0.02 * MULT_FACTOR;
float MAX_SPEED = 2 * MULT_FACTOR;
float _RADIUS = 200;
int countTime=0;
PeasyCam camera;
Flock flock;
void setup() {
  size(1024, 1024, P3D);
  camera = new PeasyCam(this, AXES_DISTANCE*3.5);
  flock = new Flock(1000);
}
void draw() {
  background(255);
  draw_environment();
  flock.step();
  flock.display();
}
void draw_environment() { 
  noFill();
  //X Axes - Red
  stroke(255, 0, 0);
  line(0, 0, AXES_DISTANCE, 0);
  //Y Axes - Green
  stroke(0, 255, 0);
  line(0, 0, 0, AXES_DISTANCE);
  //Z Axes - Blue
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, -AXES_DISTANCE);
  //Fish Tank
  stroke(0);
  box(AXES_DISTANCE*2, AXES_DISTANCE*2, AXES_DISTANCE*2);
}
class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  Boid(float x, float y, float z) {
    location = new PVector(x, y, z);
    acceleration = new PVector(0, 0, 0);
    velocity = PVector.random3D();
  }
  PVector steer(PVector target) {
    PVector desired = target.sub(location);
    desired.normalize();
    desired.mult(MAX_SPEED);
    PVector steer = desired.sub(velocity);
    steer.limit(MAX_FORCE);
    return steer;
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void step() {
    velocity.mult(1);
    velocity.add(acceleration);
    velocity.limit(MAX_SPEED);
    location.add(velocity);
    acceleration.mult(0);
  }
  void display() { 
    fill(50);
    pushMatrix();
    translate(location.x, location.y, location.z);
    box(8);
    popMatrix();
  }
  PVector cohesion(Boid[] boids) {
    PVector acc = new PVector();
    int count = 0;
    for (int i = 0; i < boids.length; i++) {
      float d = PVector.dist(this.location, boids[i].location);
      if (d <= _RADIUS && d != 0) {
        acc.add(boids[i].location);
        count++;
      }
    }
    if (count == 0) {
      return location;
    }
    acc.div(count);
    return acc;
  }
}
class Flock {
  Boid[] boids;
  Flock(int size) {
    boids = new Boid[size];
    for (int i = 0; i < boids.length; i++) {
      PVector r = generateRandomPosition();
      boids[i] = new Boid(r.x, r.y, r.z);
    }
  }
  void step() {
    PVector base= new PVector(0, 0, 0);
    for (int i = 0; i < boids.length; i++) {
      PVector cohesion = boids[i].cohesion(boids);
      PVector steerForce = boids[i].steer(cohesion);
      boids[i].applyForce(steerForce);
      PVector baseForce = boids[i].steer(base);
      boids[i].step();
      if (boids[i].location.x>AXES_DISTANCE||
        boids[i].location.y>AXES_DISTANCE||
        boids[i].location.z>AXES_DISTANCE||
        boids[i].location.x<-AXES_DISTANCE||
        boids[i].location.y<-AXES_DISTANCE||
        boids[i].location.z<-AXES_DISTANCE) {
        boids[i].applyForce(baseForce);
      }
    }
  }
  void display() {
    for (int i = 0; i < boids.length; i++) {
      boids[i].display();
    }
  }
  PVector generateRandomPosition() {
    int lowerbound=-(AXES_DISTANCE-10);
    int upperbound=AXES_DISTANCE-10;
    float x=random(lowerbound, upperbound);
    float y=random(lowerbound, upperbound);
    float z=random(lowerbound, upperbound);
    PVector v=new PVector(x, y, z);
    return v;
  }
}