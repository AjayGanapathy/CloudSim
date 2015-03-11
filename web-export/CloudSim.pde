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

/*
advancing clouds algorithm

place markdown here
*/

class AdvancingClouds{
  
  //vars go here
  private float[][] cloudArray;
  private int numberOfProperties = 5;
  private float vanishingPointX = 400;
  private float vanishingPointY = -200;
  private int windowWidth = 800;
  private int windowHeight = 600;
  private int radiusMin = 10;
  private int radiusMax = 200;
  private float wrapAmount = 600;
  private int xSpawnMin = 0;
  private int xSpawnMax = windowWidth;
  private int ySpawnMin = 400;
  private int ySpawnMax = 600;
  private int initialVelocityMin = 2;
  private int initialVelocityMax = 4;
  private int wrapClamp;
  private int backgroundGray = 210;
  private int cloudGray = 255;
  private float rampConst;
  private float rampSlope = 0.75;
  private PhysicsModel physics;
  private float forceArray = new float[4];
  private float forceVelocityX = 0;
  private float forceVelocityY = 0;
  private float forcePositionX = 0;
  private float forcePositionY = 0;  
  private int inertia = 10;
  
  //constructor goes here
  AdvancingClouds(int numberOfClouds, PhysicsModel physicsIn){
    //initialize physics
    physics = physicsIn;
    //initialize clouds
    cloudArray = new float[numberOfClouds][numberOfProperties];
    for(int cloud=0; cloud<numberOfClouds; cloud++){
      cloudArray[cloud][0] = setInitialX();
      cloudArray[cloud][1] = setInitialY();
      cloudArray[cloud][2] = setInitialRadius();
      cloudArray[cloud][3] = setInitialZIndex();
      cloudArray[cloud][4] = setInitialVelocity();
    }
    
    //make sure all minimums are less than maximums
    if(radiusMin>radiusMax){
      int temp = radiusMax;
      radiusMax = radiusMin;
      radiusMin = temp;
    }
    if(xSpawnMin>xSpawnMax){
      int temp = xSpawnMax;
      xSpawnMax = xSpawnMin;
      xSpawnMin = temp;
    }
    if(ySpawnMin>ySpawnMax){
      int temp = ySpawnMax;
      ySpawnMax = ySpawnMin;
      ySpawnMin = temp;
    }
    if(initialVelocityMin>initialVelocityMax){
      int temp = initialVelocityMax;
      initialVelocityMax = initialVelocityMin;
      initialVelocityMin = temp;
    }
    
    //initialize constants based on the position of the vanishing point
    if(vanishingPointY<ySpawnMin){
      wrapClamp = ySpawnMin;
      rampConst = windowHeight-ySpawnMin;
    }
    else{
      if(vanishingPointY>ySpawnMax){
        wrapClamp = ySpawnMax;
        rampConst = ySpawnMax;
      }
      else{
        wrapClamp = vanishingPointY;
        rampConst = ((windowHeight-ySpawnMax)+ySpawnMin)/2;
      };
    };
  }
  
  //public methods go here
  public void update(){
    forceArray = physics.getForces();
    forceVelocityX = forceArray[0];
    forceVelocityY = forceArray[1]; 
    forcePositionX = forceArray[2];
    forcePositionY = forceArray[3];
    println(forceVelocityX+" "+forceVelocityY+" "+forcePositionX+" "+forcePositionY);
    moveClouds();
    drawClouds();
  }
  
  //private methods go here
  private float setInitialX(){
    return random(xSpawnMin,xSpawnMax);
  }
  
  private float setInitialY(){
    return random(ySpawnMin,ySpawnMax);
  }
  
  private float setInitialRadius(){
    return random(radiusMin,(2*radiusMin));
  }
  
  private float setInitialZIndex(){
    return 0;
  }
  
  private float setInitialVelocity(){
    return random(initialVelocityMin,initialVelocityMax);
  }
  
  private int rampGray(int zIndexIn){
    float intermediateGray = backgroundGray+(cloudGray-backgroundGray)*(zIndexIn*rampSlope/rampConst);
    if(intermediateGray>cloudGray){
      intermediateGray = cloudGray;
    }
    return int(intermediateGray);
  }
  
  private void moveClouds(){
    for(int cloud=0; cloud<cloudArray.length; cloud++){
      //first, cache values that will be used more than once, so as to decrease array lookups
      float oldX = cloudArray[cloud][0];
      float oldY = cloudArray[cloud][1];
      float oldRadius = cloudArray[cloud][2];
      float oldZIndex = cloudArray[cloud][3];
      //check if the cloud is out of bounds
      if((oldX+oldRadius)<0 || (oldX-oldRadius)>windowWidth || oldY+oldRadius<0 || oldY-oldRadius>windowHeight || oldRadius>(windowWidth+windowHeight)){
        //if the cloud is out of bounds, respawn it in bounds
        cloudArray[cloud][0] = setInitialX();
        cloudArray[cloud][1] = setInitialY();
        cloudArray[cloud][2] = setInitialRadius();
        cloudArray[cloud][3] = setInitialZIndex();
        cloudArray[cloud][4] = setInitialVelocity();
        //then, update cached values
        oldX = cloudArray[cloud][0];
        oldY = cloudArray[cloud][1];
        oldRadius= cloudArray[cloud][2];
        oldZIndex= cloudArray[cloud][3];
      };
      //now, start velocity calculations
      float velocity = cloudArray[cloud][4];
      float velocityX;
      float yVelocityWrapAdjustment = (wrapAmount-wrapClamp)/(oldZIndex+20);
      float velocityY = velocity-yVelocityWrapAdjustment;
      float newRadius;
      //check if cloud is on horizon line
      if(oldY == vanishingPointY){
        //if cloud is on horizon line, then let it expand outward along it. 
            //in the rare case that a cloud is directly on top of the vanishing point, it will slide off to the right
        velocityX = velocity;
        if(oldX<vanishingPointX){
          velocityX = -1*velocityX;
        }
        velocityY = 0;
        newRadius = oldRadius;
      }
      else{
        velocityX = velocity*(oldX-vanishingPointX)/(oldY-vanishingPointY);
      };
      //check if cloud is above the horizon line
      if(oldY<vanishingPointY){
        velocityY = -1*velocityY;
        velocityX = -1*velocityX;
      };
      float newX = oldX+velocityX;
      float newY = oldY+velocityY;
      if(oldRadius>radiusMax){
        newRadius = oldRadius;
      }
      else{
        newRadius = oldRadius+(abs(velocityX)+abs(velocityY))/2;
      }
      cloudArray[cloud][0]=newX+forceVelocityX*inertia/(inertia+abs(oldX-forcePositionX));
      cloudArray[cloud][1]=newY+forceVelocityY*inertia/(inertia+abs(oldY-forcePositionY));
      //increase radius by the amount set by velocity
      cloudArray[cloud][2] = newRadius;
      float newZIndex = oldZIndex+velocity;
      cloudArray[cloud][3]=newZIndex;
    };
  }
  
  private void drawClouds(){ 
    for(int cloud=0; cloud<cloudArray.length; cloud++){
      float xIn = cloudArray[cloud][0];
      float yIn = cloudArray[cloud][1];
      float rIn = cloudArray[cloud][2];
      float diameter = rIn*2;
      //now perform force adjustments
      xIn = xIn;
      yIn = yIn;
      noStroke();
      fill(rampGray(cloudArray[cloud][3]));
      ellipse(xIn,yIn,diameter,diameter);
    }
  };
}
class PhysicsModel{
//physics model takes user input in, and interprets it as forces, which it stores in an array.
//the forces are stored in an array, and are used as an input to affect the X and Y position
//step 1: take user input in on each frame. 
//step 2: convert user input to an array of force constants
  //the array is [velocityX][velocityY][positionX][positionY]
  //always add a trailing decay to the end of the force constants array
  //use a current index and modulo operator to cycle through the array and avoid queue ops
//step 3: send force constants to advancing clouds for calculations

//vars go here
  private int forceDecay = 50; //on every frame, calculate the next 25 frames of decay. The decay keeps the clouds moving after the initial frame of force
  private float[][] forceArray = new float[forceDecay][2];
  private float[] positionArray = new float[2];
  private int forceArrayCurrentIndex = 0;
  private float initialVelocityX = 0;
  private float initialVelocityY = 0;
  private float initialPositionX = 0;
  private float initialPositionY = 0;

  PhysicsModel(){
    //initialize forceArray with zeroes to start
    for(int index=0; index<forceDecay; index++){
      forceArray[index][0] = initialVelocityX;
      forceArray[index][1] = initialVelocityY;
    };
    positionArray[0] = initialPositionX;
    positionArray[0] = initialPositionY;
  }

  public void addForces(){
    //get initial input
    forceArrayCurrentIndex = 0;
    float velocityX = mouseX-pmouseX;
    float velocityY = mouseY-pmouseY;
    positionArray[0] = pmouseX;
    positionArray[1] = pmouseY;
    for(int decayIndex=0; decayIndex<forceDecay; decayIndex++){
      forceArray[decayIndex][0] = decayLinear(velocityX, decayIndex);
      forceArray[decayIndex][1] = decayLinear(velocityY, decayIndex);
    }
  }
  
  private float decayLinear(float start, int decayIndex){
    return start-(decayIndex/forceDecay)*(start);
  };
  
  public float[] getForces(){
    float[] returnArray = new float[4];
    if(forceArrayCurrentIndex<forceDecay){
      returnArray[0] = forceArray[forceArrayCurrentIndex][0];
      returnArray[1] = forceArray[forceArrayCurrentIndex][1];
      returnArray[2] = positionArray[0];
      returnArray[3] = positionArray[1];
    }
    else{
      returnArray[0] = initialVelocityX;
      returnArray[1] = initialVelocityY;
      returnArray[2] = initialPositionX;
      returnArray[3] = initialPositionY;
    };
    forceArrayCurrentIndex++;
    return returnArray;
  }
}

