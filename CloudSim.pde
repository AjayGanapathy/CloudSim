//Config options
int numberOfClouds = 100;
AdvancingClouds clouds;
PhysicsModel physics;
//Setup
void setup(){
  size(800,600, OPENGL);
//  frameRate(5);
  physics = new PhysicsModel();
  clouds = new AdvancingClouds(numberOfClouds, physics);
}
//Draw Loop
void draw(){
  //clear frame
  background();
  //draw clouds at updated positons
  clouds.update();
}

//Input listeners
void mouseMoved(){
  physics.addForces();
}

