/*
Globals: this section contains environment variables and config options. 

The environment variables help the sketch communicate with the host environment
(i.e. the web browser or processing window)
  
  ---list of environment variables, and what they do ---
    *  var 1
    *  var 2
    *  var 3
    *  var 4

The config options affect the behavior of the sketch

  ---list of config options, and what they do ---
    *  option 1
    *  option 2
    *  option 3
    *  option 4

*/
//environment variables

//Config options
int numberOfClouds = 100;
//color zenith
//color sky
//color ground
//color nadir
//color sun
//angle sun
//boolean silverLining (controls ref light from ground)
//boolean pitchOnScroll = true

AdvancingClouds clouds;
//Setup
void setup(){
  size(800,600, OPENGL);
  clouds = new AdvancingClouds(numberOfClouds);
}
//Draw Loop
void draw(){
  //clear frame
  background();
  //draw clouds at updated positons
  clouds.update();
}

//Input listeners
