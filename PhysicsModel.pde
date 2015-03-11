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
